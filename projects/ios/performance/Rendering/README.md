# Performance: the art of doing as little as possible
If you ever wondered why we write func and var rather than function and variable, it’s simple: programmers love being lazy! In this article we’re going to look at a handful of ways to make your projects faster by doing as little work as possible, just the way I like it…

# Debounce everything!
In my book Pro SwiftUI, I walk readers through creating a simple debouncer class that is able to delay emitting updates for a binding to help minimize expensive work being done.

The code for it is fairly simple:

```
import Combine

class Debouncer<T>: ObservableObject {
    @Published var input: T
    @Published var output: T

    private var debounce: AnyCancellable?

    init(initialValue: T, delay: Double = 1) {
        self.input = initialValue
        self.output = initialValue

        debounce = $input
            .debounce(for: .seconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.output = $0
            }
    }
}
```

That’s the entire code for the debouncer: it’s generic over some kind of value, it has @Published properties for both the new data coming and the debounced data going back out, and it simply adds a small delay between reading the new input value and updating the output.

Even though it’s small, such a debouncer can have a pretty significant impact on our code, as can be seen in the code example I used:

```
struct ContentView: View {
    @StateObject private var text = Debouncer(initialValue: "", delay: 0.5)
    @StateObject private var slider = Debouncer(initialValue: 0.0, delay: 0.1)

    var body: some View {
        VStack {
            TextField("Search for something", text: $text.input)
                .textFieldStyle(.roundedBorder)
            Text(text.output)

            Spacer().frame(height: 50)

            Slider(value: $slider.input, in: 0...100)
            Text(slider.output.formatted())
        }
    }
}
```

You’ll see that the Text view updates only half a second after you stop typing, and the slider won’t update the UI until you stop moving. Keep in mind that the iOS UI will normally update 60 or even 120 times a second, so if your slider is triggering a lot of work you might find your UI grinds to a halt without a debouncer.

Just having a simple debouncer is great for simple projects, but for more serious work you’ll inevitably find you need to debounce more complex values. As an example, you might have a SaveData class that stores some kind of data:

```
class SaveData: ObservableObject {
    @Published var highScore = 0
}
```

We can use that in a simple ContentView such as this one:

```
struct ContentView: View {
    @StateObject var saveData = SaveData()

    var body: some View {
        Button("High Score: \(saveData.highScore)") {
            saveData.highScore += 1
        }
    }
}
```

That kind of code works great in small projects, but again it will really suffer if you make frequent changes – if you were storing a string attached to a TextField, for example, then you might be triggered a dozen view reloads for every letter you type.

This is where debouncing comes in, except rather than debouncing a single object we can in fact debounce the whole observable object so that all changes to all values get debounced by some number of seconds.

This takes some fairly advanced Swift code, so I’m going to implement it in three steps.

First, we’re going to create a new DebouncedObservedObject class that is generic over some kind of ObservableObject, but also itself conforms to ObservableObject. In other words, it’s able to watch an observable object for changes, but also issue change notifications itself.

Start by making a new Swift file called DebouncedObservedObject.swift, add an import for Combine, then give it this code:

```
class DebouncedObservedObject<Wrapped: ObservableObject>: ObservableObject {
    var wrappedValue: Wrapped
    private var subscription: AnyCancellable?
}
```

That won’t compile yet, but it does at least show you the double ObservableObject conformance: the class conforms to the protocol, but also works with a wrapped value of the same protocol.

The magic happens in our initializer, which is similar to the simple debouncer class from before. The main difference is that rather than updating a single output property when another property changes, we instead attach some Combine operators to the objectWillChange publisher of the thing we’re wrapping so that we can debounce the announcement then issue our own change announcement.

Here’s how that looks:

```
init(wrappedValue: Wrapped, delay: Double = 1) {
    self.wrappedValue = wrappedValue

    subscription = wrappedValue.objectWillChange
        .debounce(for: .seconds(delay), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.objectWillChange.send()
        }
}
```

And that’s it! That’s the first draft of our debouncer complete, so we can put it to use:

```
struct ContentView: View {
    @StateObject var saveData = DebouncedObservedObject(wrappedValue: SaveData())

    var body: some View {
        Button("High Score: \(saveData.wrappedValue.highScore)") {
            saveData.wrappedValue.highScore += 1
        }
    }
}
```

As you can see, the SaveData object now gets placed inside in a DebouncedObservedObject, which means we need to read and write its wrappedValue property when we want to access the high score integer.

That’s a good start, but we can do better. One of Swift’s power features is @dynamicMemberLookup, which allows us to dynamically add properties rather than hard-coding them all. In this case, we can tell Swift we want to bridge the properties from our wrapped type up to our DebouncedObservedObject class, so we can access them directly rather than always having to read the wrapped value.

First, add the @dynamicMemberLookup attribute before the DebouncedObservedObject class, like this:

```
@dynamicMemberLookup
class DebouncedObservedObject<Wrapped: ObservableObject>: ObservableObject {
  ```

And now add a custom subscript that is generic over some kind of value, and accepts a key path into our wrapped type:

```
subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, Value>) -> Value {
    get { wrappedValue[keyPath: keyPath] }
    set { wrappedValue[keyPath: keyPath] = newValue }
}
 ```


It’s a small change, but it means our ContentView code becomes much simpler because we no longer need to worry about wrappedValue:

```
Button("High Score: \(saveData.highScore)") {
    saveData.highScore += 1
}
 ```

That’s a big improvement, but we can do even better. Yes, @dynamicMemberLookup is neat, but you know what’s even better? Replacing @dynamicMemberLookup with @propertyWrapper to make our debouncing less ugly – while also actually being less code.

You see, adding our own subscript is required to handle @dynamicMemberLookup, so Swift knows to read the wrapped value when access properties on the parent type. But with @propertyWrapper that requirement for a subscript goes away: property wrappers are automatically transparent to the type system by design, so Swift effectively provides a subscript that does the same thing.

So, start by changing the attribute @dynamicMemberLookup for @propertyWrapper, like this:

```
@propertyWrapper
class DebouncedObservedObject<Wrapped: ObservableObject>: ObservableObject {
 ```

Now comment out the whole subscript method – the property wrapper takes care of that for us.

Finally, change the property declaration in ContentView to this:

```
@StateObject @DebouncedObservedObject var saveData = SaveData()
```

Yes, that’s two property wrappers in one. This makes a nested property wrapper: the debounced observable object creates and owns the save data object, then gets wrapped inside a state object to store and observe it all for change announcements.

This approach has the advantage that our debouncer is now completely invisible in our code: we can use the SaveData object as if it weren’t wrapped by anything at all. When it comes to passing it into other views, we can either use our property wrapper like this:

```
@DebouncedObservedObject var saveData: SaveData
```

Or if we want that view to see changes directly, we can use a simple @ObservedObject, like this:

```
@ObservedObject var saveData: SaveData
```

We get to choose on a case-by-case basis just by changing the property wrapper – it’s a really nice approach.

Now, the reason I asked you to comment out the subscript rather than delete it is because we can actually combine both approaches: we can reinstate the subscript code, then mark the class as being both @propertyWrapper and @dynamicMemberLookup, so that you can use it as a property wrapper or use it as a regular class depending on which approach you think works best.

Everyone will prefer different approaches here, but regardless of which you choose the result is the same: we now debounce the entire observable object, meaning that we significantly reduce the amount of work our code does.

# Writing but not reading
SwiftUI loves property wrappers, and we use them so often it’s actually surprisingly easy to use them without thinking – we just add them into our code, see that it works correctly, but don’t stop to think whether we made the right choice.

To demonstrate this, I want to show a trivial example of how we might structure some data.

**Comment out most of the code we used already, or make a new project if you prefer, but regardless please leave the SaveData class around as some example data.

Here are three simple SwiftUI views: one that displays the high score, one that updates the high score, and one that creates a SaveData instance and places it into the environment:

```
struct DisplayingView: View {
    @EnvironmentObject var saveData: SaveData

    var body: some View {
        Text("Your high score is: \(saveData.highScore)")
    }
}

struct UpdatingView: View {
    @EnvironmentObject var saveData: SaveData

    var body: some View {
        Button("Add to High Score") {
            saveData.highScore += 1
        }
    }
}

struct ContentView: View {
    @StateObject var saveData = SaveData()

    var body: some View {
        VStack {
            DisplayingView()
            UpdatingView()
        }
        .environmentObject(saveData)
    }
}
```

That code is all correct, and fairly common. But it’s not ideal, and to see why I’d like you to add some print() calls to the code in the body property of each view and also in an initializer.

The result should look like this:

```
struct DisplayingView: View {
    @EnvironmentObject var saveData: SaveData

    var body: some View {
        print("In DisplayingView.body")
        return Text("Your high score is: \(saveData.highScore)")
    }

    init() {
        print("In DisplayingView.init")
    }
}

struct UpdatingView: View {
    @EnvironmentObject var saveData: SaveData

    var body: some View {
        print("In UpdatingView.body")
        return Button("Add to High Score") {
            saveData.highScore += 1
        }
    }

    init() {
        print("In UpdatingView.init")
    }
}

struct ContentView: View {
    @StateObject var saveData = SaveData()

    var body: some View {
        print("In ContentView.body")

        return VStack {
            DisplayingView()
            UpdatingView()
        }
        .environmentObject(saveData)
    }

    init() {
        print("In ContentView.init")
    }
}
```

When you run the app now you’ll see the following:

1. The initializer for ContentView
2. The body of ContentView
3. The initializers for both DisplayingView and UpdatingView
4. The body of DisplayView and UpdatingView
   
Now click the button, and you’ll see all the same messages printed again except for the first one – SwiftUI is doing a surprising amount of work for one button press. This is why you’ll hear folks say repeatedly that it’s important to keep your initializers and body properties as fast as you can, because they can be called lots of times.

However, sometimes your apps can’t be so simple. Yes, in this test app the initializers and body properties are trivial, but in a larger app you might load some data in the initializer, or your body property might be 50 lines long and embed multiple other SwiftUI views. What then?

Well, in this case we need to rethink our code, because we’ve actually asked for all that extra work to happen – it’s our fault that SwiftUI is jumping through so many hoops, even though the amount of code is very small.

We can dramatically reduce the amount of work done, and in fact it involves less code. First, delete this from ContentView:

```
@StateObject var saveData = SaveData()
```

And now adjust the environmentObject() modifier to this:

```
.environmentObject(SaveData())
```

The result is identical: both views have access to the shared SaveData object, and can read and write it freely. However, if you look at the log messages now you’ll see that clicking the button in UpdatingView no longer calls the body property of ContentView and no longer calls the initializers of the two child views – SwiftUI keeps the existing view structs alive rather than reinitializing them again and again.

The problem with the old code was that we used @StateObject inside ContentView: we were telling SwiftUI to observe an object that we didn’t actually use inside ContentView. SwiftUI doesn’t care that ContentView doesn’t explicitly use the data, so it goes ahead and reinvokes its body property and in doing so recreates its two child views.

Our fix relies on one important feature of environment objects: SwiftUI automatically retains the objects we post into the environment for as long as they are used. This means we can post the SaveData instance into the environment without actually observing it – we can inject it for our child views to use, without making our own view get reloaded when it posts a change notification.

That’s already a big improvement, but – as you might have guessed – we can do better. Our ContentView struct never needs to read or write the SaveData instance, so we don’t add any property for it at all. But our UpdatingView only needs to write the data – it’s never actually read there.

So, I want to show you an important trick: using @Environment rather than @EnvironmentObject. These two do very similar things, but with an important distinction: @Environment is used for value types, and @EnvironmentObject is used for reference types.

In practice, this difference exists because @Environment looks for the whole value changing before reinvoking the body properties of any observing views, whereas @EnvironmentObject looks for change notifications such as @Published or objectWillChange.send().

However, there’s nothing stopping us from placing a reference type into the environment as a value type rather than a reference type – the environment effectively just sees a pointer to some memory, but if we change a property on that object it won't trigger an invalidation because the object isn’t being observed for changes.

To make this happen we need to define a new environment key and value for our data, providing a default value:

```
struct SaveDataKey: EnvironmentKey {
    static var defaultValue = SaveData()
}

extension EnvironmentValues {
    var saveData: SaveData {
        get { self[SaveDataKey.self] }
        set { self[SaveDataKey.self] = newValue }
    }
}
```

Everywhere we want to use that SaveData instance while also being notified of any changes, we use @EnvironmentObject as before. But in UpdatingView we only want to write data without watching for changes, so we can instead use @Environment like this:

```
@Environment(\.saveData) var saveData
```

This creates an interesting problem: now we need to inject our SaveData instance as both an environment value and an environment object. So, this code isn’t sufficient any more:

```
.environmentObject(SaveData())
```

You might think that means going back to the same problem we had initially, which was using @StateObject in ContentView` like this:

```
@StateObject var saveData = SaveData()
```

However, we can use the same technique to avoid undoing all our hard work: rather than using @StateObject we can use @State in ContentView. Yes, that’s designed to hold value types rather than reference types, but in this instance it does exactly the same as using environment values rather than environment objects: it holds a reference to the object, but doesn’t watch it for changes.

So, change your ContentView code to this:

```
struct ContentView: View {
    @State var saveData = SaveData()

    var body: some View {
        print("In ContentView.body")

        return VStack {
            UpdatingView()
            DisplayingView()
        }
        .environmentObject(saveData)
        .environment(\.saveData, saveData)
    }

    init() {
        print("In ContentView.init")
    }
}
```

With that change now we have the optimal form of our code: whenever the button is pressed SwiftUI reinvokes the body property of DisplayingView, but nothing else – we’ve removed two initializer calls and two body calls, just by adjusting our code a little.

Yes, it takes a little more work, but you’d be amazed at how much work you can avoid by making just a handful of changes!

# One last thing…
Here’s an array of names, along with three functions to transform them somehow:

```
let names = ["John", "Paul", "George", "Ringo"]

func uppercase(_ string: String) -> String {
    print("Uppercasing \(string)")
    return string.uppercased()
}

func reverse(_ string: String) -> String {
    print("Reversing \(string)")
    return String(string.reversed())
}

func countLetters(in string: String) -> Int {
    print("Counting \(string)")
    return string.count
}
```

If we wanted to uppercase and reverse the names, then count their letters, we’d write this:

```
let result = names.map(uppercase).map(reverse).map(countLetters)
```

When that code runs, it uppercases John, then Paul, then George, then Ringo, then reverses the four names, then counts their letters.

Now try changing the last line to use lazy, like this:

```
let result = Array(names.lazy.map(uppercase).map(reverse).map(countLetters))
```

You’ll see it applies all three transforms to John, then Paul, then George, then Ringo in that order – rather than going over the array multiple times, it coalesces the transformations.

Even better, if you remove the Array cast it will stay as lazy, which means it will compute the values lazily – that can be helpful if you only need a handful of results, rather than the whole array being transformed.