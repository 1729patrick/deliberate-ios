# Upgrading your SwiftUI
In this article we’re going to build part of a SwiftUI app that helps users find designers for work. The goal here isn’t to build a full app, but instead to explore lesser-known SwiftUI features in a practical way.

# Up and running with a simple UI
Our first step will be to define some data, based on the following JSON: https://hws.dev/designers.json. This will mostly be straightforward, with two exceptions:

1. Designers have skills, and we’ll be making these a dedicated type rather than just strings so that we can add an Identifiable conformance.
1. That dedicated Skill type needs to be decoded by hand, because it will be provided as strings. This is very simple, though, because it’s just a single-value container.
Create a new Swift file called Person.swift, then give it this code:

```
struct Person: Comparable, Decodable, Identifiable {
    var id: Int
    var photo: URL
    var thumbnail: URL
    var firstName: String
    var lastName: String
    var email: String
    var experience: Int
    var rate: Int
    var bio: String
    var details: String
    var skills: Set<Skill>
    var tags: [String]

    static func <(lhs: Person, rhs: Person) -> Bool {
        lhs.lastName < rhs.lastName
    }

    static let example = Person(id: 1, photo: URL(string: "https://hws.dev/img/user-1-full.jpg")!, thumbnail: URL(string: "https://hws.dev/user-1-thumb.jpg")!, firstName: "Jaime", lastName: "Rove", email: "jrove1@huffingtonpost.com", experience: 10, rate: 300, bio: "A few lines about this person go here.", details: "A couple more sentences about this person go here.", skills: [Skill("Illustrator"), Skill("Photoshop")], tags: ["ideator", "aligned", "manager", "excitable"])
}

struct Skill: Comparable, Decodable, Hashable, Identifiable {
    var id: String

    init(_ id: String) {
        self.id = id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.id = try container.decode(String.self)
    }

    static func <(lhs: Skill, rhs: Skill) -> Bool {
        lhs.id < rhs.id
    }
}
```
Now, when dealing with the names of people it’s generally a good idea to format them neatly, which Foundation can do for using a computed property in Person:

```
var displayName: String {
    let components = PersonNameComponents(givenName: firstName, familyName: lastName)
    return components.formatted()
}
```

Next, we can handle loading and manipulating our app’s data using an observable object class. This will start simple, but we’ll add more to it over time.

Create a new Swift file called DataModel.swift, change its Foundation import for SwiftUI, then give it this code:

```
@MainActor
class DataModel: ObservableObject {
    @Published var people = [Person]()

    func fetch() async throws {
        let url = URL(string: "https://hws.dev/designers.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        people = try JSONDecoder().decode([Person].self, from: data)
    }
}
```
And now we can write a trivial version of ContentView, just to make sure everything is working:

```
struct ContentView: View {
    @StateObject private var model = DataModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(model.people) { person in
                        Text(person.displayName)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Design4u")
        }
        .task {
            do {
                try await model.fetch()
            } catch {
                print("Error handling is great!")
            }
        }
    }
}
```

That’s just enough to prove our data model is working correctly – make sure you give the app a quick run to verify there are no little typos in property names, etc.

All being well you should see a simple list of names, but really we want something that shows much more information. This is best spun off into a separate SwiftUI view to handle individual rows, so create a new SwiftUI view called DesignerRow.swift, and give it this code:

```
struct DesignerRow: View {
    var person: Person

    @ObservedObject var model: DataModel

    var body: some View {
        HStack {
            Button {
                // select this designer
            } label: {
                HStack {
                    AsyncImage(url: person.thumbnail, scale: 3)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading) {
                        Text(person.displayName)
                            .font(.headline)

                        Text(person.bio)
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                    }
                }
            }
            .tint(.primary)

            Spacer()

            Button {
                // show details
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.borderless)
        }
    }
}

struct DesignerRow_Previews: PreviewProvider {
    static var previews: some View {
        DesignerRow(person: .example, model: DataModel())
    }
}
```

Tip: Specifying a tint of .primary overrides the default blue color of text inside buttons.

Now we can bring the whole UI to life by replacing the Text(person.displayName) code in ContentView with this:

```
ForEach(model.people) { person in
    DesignerRow(person: person, model: model)
}
```
Much better!

# Making a better search experience
What we have so far is a solid start, but from here on I want to explore some or the more interesting parts of SwiftUI that I think don’t get enough use.

We’ll start with searching, which is common enough at least to begin with. If we want to upgrade our app to support searching, we’d introduce a new property into our view model to store some search text, and also create a filtered [Person] array taking that search into account.

First, add this to ViewModel:
```
@Published var searchText = ""
```
And now add this computed property to filter based on various properties:
```
var searchResults: [Person] {
    people.filter { person in
        guard searchText.isEmpty == false else { return true }

        for string in [person.firstName, person.lastName, person.bio, person.details] {
            if string.localizedCaseInsensitiveContains(searchText) {
                return true
            }
        }

        return false
    }
}
```

Bringing that into ContentView means making two small changes, starting with a change to the ForEach so we read from the computed property rather than the stored one:

```
ForEach(model.searchResults) { person in
```

And now adding a searchable() modifier to the ScrollView:

```
.searchable(text: $model.searchText)
```
Done! That works great, but let’s face it: a simple searchable() modifier is a lovely feature of SwiftUI, but it’s also really common.

What’s less common – and what I want to add next – is the ability to add tokens to our search, which are filters that appear in the search box. This is why our designer skills were created as a separate type: even though they look and act like strings, SwiftUI needs them to conform to the Identifiable protocol.

This takes a few small steps. First, we need an array to store the list of search tokens the user currently has active. This should use @Published so SwiftUI updates as the token list changes - add this to DataModel now:

```
@Published var tokens = [Skill]()
```

Second, we need an array of all search tokens the user can select from. We’ll be creating this from the data we download, so we can start with an empty array:

```
private var allSkills = [Skill]()
```

Third, we need to give that allSkills array a value in our fetch() method. This needs to bring together all the arrays of skills from all the people into a single array, remove any duplicates, then sort the results, which is all just one line of code – add this to the end of fetch():

```
allSkills = Set(people.map(\.skills).joined()).sorted()
```

Fourth, we need to upgrade our searchResults property to take the list of tokens into account: a designer should only be returned if their skills include all the tokens from the user.

This means changing the start of the property so that we make a Set from the list of tokens they have activated, then taking that set into account in the filter() call:

```
let setTokens = Set(tokens)

return people.filter { person in
    guard person.skills.isSuperset(of: setTokens) else { return false }
    guard searchText.isEmpty == false else { return true }
```

Fifth, we need to know what tokens we should suggest to SwiftUI. Now, you might think that’s easy because we already have the allSkills array containing the tokens the user can choose from, but if we always return that then the tokens will always be suggested – it leaves no scope for a simple text search any more.

So, rather than always returning all skills, we’ll instead return all the skill only when the user’s search starts with a # symbol, making the skills like hashtags. SwiftUI wants these tokens to be returned as a binding, so we can just wrap either allSkills or an empty array in a constant binding.

Add this property to DataModel now:

```
var suggestedTokens: Binding<[Skill]> {
    if searchText.starts(with: "#") {
        return .constant(allSkills)
    } else {
        return .constant([])
    }
}
```

And now all that remains is to upgrade searchable() in ContentView so that we pass in the list of tokens the user has enabled, the list of tokens we want to show, and also a closure that knows how to convert one search token into something for the UI:

```
.searchable(text: $model.searchText, tokens: $model.tokens, suggestedTokens: model.suggestedTokens, prompt: Text("Search, or use # to select skills")) { token in
    Text(token.id)
}
```

Tip: I added a prompt there to let users know about skill hashtags.

That’s our first improvement done: if you run the app now you’ll see you can mix plain text searches with hashtags to filter users really nicely.

# Selecting designers
The next improvement we’re going to add lets user select designers they might want to work with. At the very least this means adding an array to our DataModel class to track which people are currently selected:

```
@Published private(set) var selected = [Person]()
```

We can then add small methods to add or remove people:

```
func select(_ person: Person) {
    selected.append(person)
}

func remove(_ person: Person) {
    if let index = selected.firstIndex(of: person) {
        selected.remove(at: index)
    }
}
```

There’s one last small change I want to make to DataModel, which is to automatically exclude selected designers from our search results, so they get removed when selected. This can be done by adding a third guard check inside the filter() method, before the searchText.isEmpty check:

```
guard selected.contains(person) == false else { return false }
```

That’s all simple stuff, but over in our SwiftUI code things get more interesting. First, we need to update DesignerRow so that our button action has something more interesting than its current // select this designer comment.

We’re going to make it call select() on our data model inside an animation, but only if they haven’t already selected five or more designers. Replace the comment with this:

```
guard model.selected.count < 5 else { return }
withAnimation {
    model.select(person)
}
```

If you remember, our data model automatically excludes selected designers from the search results, so we need a separate place to show them in ContentView. An easy way to do this using the safeAreaInset() modifier, which automatically pulls one edge of the safe area in by enough room to accommodate some other views – it’s perfect for our list of selected designers.

For reasons known only to Apple, the code we want inside that view will trigger some warnings unless we write it directly into the safeAreaInset() modifier – trying to spin this off into its own view works great at runtime, but issues a rather annoying warning. This means the code here is much longer than I would like, so to make things easier we’ll implement it in three stages.

First, add this modifier to the ScrollView, which has a tiny bit of styling plus two comments we’re going to fill in:

```
.safeAreaInset(edge: .bottom) {
    if model.selected.isEmpty == false {
        VStack {
            // selected designers

            // continue button
        }
        .frame(maxWidth: .infinity)
        .padding([.horizontal, .top])
        .background(.ultraThinMaterial)
    }
}
```

The first comment, // selected designers, will be replaced with the pictures of the avatars the user has chosen. They’ll be the same size and shape as the original list of designers, but I’ll add a white stroke around their edge plus some negative spacing on our HStack so they overlap neatly:

```
HStack(spacing: -10) {
    ForEach(model.selected) { person in
        Button {
            withAnimation {
                model.remove(person)
            }
        } label: {
            AsyncImage(url: person.thumbnail, scale: 3)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}
```

As you can see, each picture is a button that removes the selected designer.

Below the list of designers will be a button to continue on to another screen, which is best done using a navigation link. Add this in place of the // continue button comment:

```
NavigationLink {
    // go to the next screen
} label: {
    Text("Select \(model.selected.count) Person")
        .frame(maxWidth: .infinity, minHeight: 44)
}
.buttonStyle(.borderedProminent)
.contentTransition(.identity)
```

There are three modifiers that deserve explanation in there:

Having an infinite maximum width means this button will stretch nice and large across the bottom of the screen.
44 points is the recommended minimum height for buttons on iOS, so enforcing that is usually a good idea.
Using .identity for the content transition tells SwiftUI not to animate changes to the text. It’s a small thing, but it’s distracting to see the text fade a little every time you add or remove a designer.
That looks pretty good, I think – selecting designers now removes them from the list and adds them to the list at the bottom. But we can do better!

To improve this new UI a lot, we’re going to rely on two marvelous SwiftUI features, starting with matched geometry effects. These little wonders can help us move the designer’s photo smoothly from the list to the selected area, rather than just fading in and out.

This takes six one-line changes, starting with declaring an animation namespace in ContentView. This is just a place where SwiftUI expects all identified views to exist only once, and it’s done with a new property:

```
@Namespace var namespace
```

Second, we need to add the matchedGeometryEffect() modifier to the selected designers images – put this directly after the buttonStyle(.plain):

```
.matchedGeometryEffect(id: person.id, in: namespace)
```

The third part is where folks sometimes get confused, because we need the same matchedGeometryEffect() modifier in DesignerRow. That means adding the same modifier to the AsyncImage in DesignerRow.swift:

```
.matchedGeometryEffect(id: person.id, in: namespace)
```

…and that code won’t compile, because namespace is a property of ContentView and not DesignerRow. It’s very common to see matched geometry effects working between views inside a single parent, but here things are a little more complex because our list rows have been carved off into separate views.

Fortunately, the fix is straightforward: we need to tell DesignerRow to expect a property specifying which animation namespace to use, like this:

```
var namespace: Namespace.ID
```

That does not use the @Namespace property wrapper, because we’re asking to be given an existing namespace rather than making a new one.

The fifth change is to make the DesignerRow previews compile again, because Swift expects us to pass a namespace in. To fix this, declare a static namespace in your preview, then send that in like so:

```
struct DesignerRow_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        DesignerRow(person: .example, model: DataModel(), namespace: namespace)
    }
}
```

The final change is in ContentView, where we need to change the DesignerRow() code to pass in the namespace we made earlier:

DesignerRow(person: person, model: model, namespace: namespace)
And now I think our screen looks much nicer: tapping on a designer causes them to move smoothly to and from the selected area, rather than just fading. Honestly, matched geometry effect feels like magic sometimes, and I wish more folks knew how easy it is to pass `Namespace.ID` objects around to get animations working smoothly across views.

But there’s another change I want to make here, which is in the select person button. When you add 2 people it reads “Select 2 Person”, which isn’t correct. Really we want this to show the correct plural form of “people” in that situation, so let’s make that change:

```
Text("Select ^[\(model.selected.count) Person](inflect: true)")
```

That’s all it takes! What you’re seeing here is called automatic grammar agreement: iOS will automatically move between “Person” and “People” based on the number we have selected. When this was announced in iOS 15 this was available for English and Spanish, but iOS 16 added another four languages.

# Showing more details
To finish up our SwiftUI work, we’re going to add some functionality for the information button that exists on the trailing edge of each row. We’ll put a few lovely little SwiftUI features into here, so you might see a few things you haven’t used before.

First, create a new SwiftUI view called DesignerDetails.swift, then give it this code:

```
struct DesignerDetails: View {
    var person: Person

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                AsyncImage(url: person.photo, scale: 3)
                    .overlay(
                        Rectangle()
                            .strokeBorder(.primary.opacity(0.2), lineWidth: 4)
                    )
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 10) {
                    Text(person.displayName)
                        .font(.largeTitle.bold())

                    Text(person.bio)
                    Text(person.details)
                }
                .padding()
            }
            .padding(.vertical)
        }
    }
}
```

All of that is pretty simple SwiftUI code, so there are no surprises. You’ll need to edit your preview code to keep it compiling, like this:

```
static var previews: some View {
    DesignerDetails(person: .example)
}
```

We want that screen to appear when the user taps a designer’s info button, but that takes a little thinking because only want one selected designer at a time.

What we need to do is give ContentView one centralized property to store the currently selected designer, then make that view responsible for showing a sheet at the right time. That means adding a new property to ContentView:

```
@State private var selectedDesigner: Person?
```

Then adding a sheet() modifier next to searchable():

```
.sheet(item: $selectedDesigner, content: DesignerDetails.init)
```

Now for the cunning part: we need to make DesignerRow write to that same value, which means adding an @Binding property to that view:

```
@Binding var selectedDesigner: Person?
```

Adding an extra property will cause the compiler to throw up errors, because we now need to pass in a binding for that property everywhere we create a DesignerRow. That means adjusting the preview code to this:

```
DesignerRow(person: .example, model: DataModel(), namespace: namespace, selectedDesigner: .constant(nil))
```

And adjusting the ForEach in ContentView to this:

```
ForEach(model.searchResults) { person in
    DesignerRow(person: person, model: model, namespace: namespace, selectedDesigner: $selectedDesigner)
}
```

Now the code compiles again, the last step is to replace the button’s // show details comment with code to set that binding to the current person:

```
selectedDesigner = person
```

That works well enough – you can now tap on the "i" button for any designer to see more information about them. But once again we do better!

First, iOS 16.1 introduced the ability to customize the exactly style of fonts with just one modifier. In this app, we can make our designer’s name use a rounded font so it looks a little friendlier by adding this to the Text view in DesignerDetails:

```
.fontDesign(.rounded)
```

Second, we can tell SwiftUI that our sheet doesn’t need to occupy the whole screen by adding presentation detents for medium and large sizes. To do that, add the following code to the ScrollView in DesignerDetail:

```
.presentationDetents([.medium, .large])
```

Third, each designer has a list of business buzzwords called “tags”, and we can display those in a horizontally scrolling list below the inner VStack. In fact, that’s the reason there’s an inner VStack at all: we haven’t added padding to the whole view so that this inner tags ScrollView goes edge to edge horizontally.

Add this after the inner VStack:

```
ScrollView(.horizontal, showsIndicators: false) {
    HStack {
        ForEach(person.tags, id: \.self) { tag in
            Text(tag)
                .padding(5)
                .padding(.horizontal)
                .background(.blue.gradient)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
    .padding(.horizontal)
}
```

It’s a tiny thing, but that code shows off my single most favorite SwiftUI feature from iOS 16: being able to add .gradient to any to color to get a very gentle color gradient is just brilliant!

Below that nested scroll view we’re going to add another VStack with some extra information about the user. This is another great place to use automatic grammar agreement, but we can also mix in some Markdown to get nicer formatting.

Add this below the previous code:

```
VStack(alignment: .leading, spacing: 10) {
    Text("**Experience:** ^[\(person.experience) years](inflect: true)")
    Text("**Rate:** $\(person.rate)")
    Text("**Contact:** \(person.email)")
}
.padding()
```

When you run that code you might notice that the email address displays correctly, but isn’t tappable. Fixing this is trivial with a little workaround: we can tell SwiftUI that the string is actually a LocalizedStringKey, which triggers interactive Markdown parsing:

```
Text(.init("**Contact:** \(person.email)"))
```

Now you’ll see the email address is tappable, although if you’re using the simulator it’s unlikely to do anything other than print a warning!

Before we’re done with this screen, I want to add one tiny extra thing to it. This isn’t new or even uncommon SwiftUI code, but it does a lot to make the screen better: we’re going to add a transparency mask to the tags scroll view so that the leading and trailing edges fade away neatly.

Doing this means adding a linear gradient with four stops: transparent at 0, fully white at 0.05, still fully white at 0.95, then back to transparent at 1. This ensures the translucency gradient only happens at the very edges of the scroll view.

Add this modifier to the ScrollView where we show each designer’s tags:

```
.mask(
    LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .white, location: 0.05), .init(color: .white, location: 0.95), .init(color: .clear, location: 1)], startPoint: .leading, endPoint: .trailing)
)
```

It’s a small change but I encourage you to see how it looks in the app. Sometimes a designer’s tags happen to line up perfectly at or near the trailing screen edge, so it’s not clear to users that they can scroll to see more. Adding just that hint of fading is a great hint that there’s more just out of view.