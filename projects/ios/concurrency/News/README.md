# Pausing tasks
Swift’s tasks can be paused in one of two ways: if we call sleep() they will pause for at least a certain amount of time, and if we called yield() they will voluntarily suspend themselves so that the system can do any work it considers more important. Both are useful, although probably not as often as you might imagine.

First, let’s try sleeping: you can sleep the current task by calling Task.sleep(), passing in some number of nanoseconds. Yes, nanoseconds: you need to write 1_000_000_000 to get 1 second. It’s a little clumsy, but it’s all we have until Swift gets its own time API.

Anyway, in the meantime we can add a small extension to make sleeping work with a Double of seconds instead, like this:

```
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await sleep(nanoseconds: duration)
    }
}
```

Tip: That’s extending the non-generic Task statically, hence the constraints for Success and Failure.

We could put that to work straight away, perhaps by making our sentTask work sleep just a little before doing its work so the requests are staggered:

```
let sentTask = Task { () -> [Message] in
    try await Task.sleep(seconds: 1)
    let url = URL(string: "https://hws.dev/sent.json")!
    return try await URLSession.shared.decode([Message].self, from: url)
}
```

If you preferred to avoid using our little extension, you can also sleep for a billion nanoseconds:

```
try await Task.sleep(nanoseconds: 1_000_000_000)
```

Important: Calling Task.sleep() will make the current task sleep for at least the amount of time you ask, not exactly the time you ask. There is a little drift involved because the system might be busy doing other work when the sleep ends, but you are at least guaranteed it won’t end before your time has elapsed.

Before we look at suspending rather than sleeping a task, there are two more helpful features of sleep() that are worth pointing out:

If you call sleep() on a cancelled task, or if you cancel a task while it’s sleeping, it will immediately end the sleep and throw an error.
Unlike making a thread sleep, Task.sleep() does not block the underlying thread, allowing it pick up work from elsewhere if needed.
Important: If you’re following along in Xcode, you should remove the sleep() call – we don’t need it.

Okay, let’s talk about suspending a task. You’ve already seen how await marks a potential suspension point in our code, but what happens if one of your tasks is going over a large, tight loop? Well, it will basically hog its thread, potentially holding back lots of other pieces of work that could be executed in the meantime.

Swift provides a solution to this in the form of await Task.yield(), which is effectively the equivalent of calling a fictional await Task.doNothing() – it introduces an artificial suspension point so that Swift can adjust the execution of its tasks without actually creating any real work.

This doesn’t always mean the current task will pause for a while – Swift might look at the other scheduled work and decide the current task is still more important, and immediately resume it. But that’s okay, because at least it’s had the chance to execute something else.

To demonstrate this, we could write a simple function to calculate the factors for a number – numbers that divide another number equally. For example, the factors for 12 are 1, 2, 3, 4, 6, and 12. A simple version of this function might look like this:

```
func factors(for number: Int) async -> [Int] {
    var result = [Int]()

    for check in 1...number {
        if number.isMultiple(of: check) {
            result.append(check)
        }
    }

    return result
}
```

Despite being a pretty inefficient implementation, in release builds that will still execute quite fast even for numbers such as 100,000,000. But if you try something even bigger you’ll notice it struggles – running hundreds of millions of checks is really going to make the task chew up a lot of CPU time, which might mean other tasks are left sitting around unable to make even the slightest progress forward.

Keep in mind that there could be other tasks waiting that might be able to kick off some work then suspend immediately, such as making network requests. So, a simple improvement is to force our factors() method to pause every so often so that Swift can run other tasks if it wants – we’re effectively asking it to come up for air and let another task have a go.

Over to you: For our factors() function, where might be a good place to call Task.yield() so that Swift gives other tasks the chance to run?

One possible solution is this:

```
func factors(for number: Int) async -> [Int] {
    var result = [Int]()

    for check in 1...number {
        if check.isMultiple(of: 100_000) {
            await Task.yield()
        }

        if number.isMultiple(of: check) {
            result.append(check)
        }
    }

    return result
}
```

However, that has the downside of now having twice as much work in the loop. Personally I’d be tempted to eliminate to do this instead:

```
func factors(for number: Int) async -> [Int] {
    var result = [Int]()

    for check in 1...number {   
        if number.isMultiple(of: check) {
            result.append(check)
            await Task.yield()
        }
    }

    return result
}
```

That offers Swift the chance to pause every time a multiple is found. Of course, you should always make sure you instrument your code to see what impact calling yield() has – I’m taking a best guess here!

# Cancelling tasks
I already mentioned that calling Task.sleep() respects the cancellation status of the current task, meaning that it won’t sleep if the task has already ended. Well, task cancellation goes much further, giving us fine-grained control over a single task’s behavior and also whole groups of tasks.

The most important thing to know here is that Swift’s tasks use cooperative cancellation, which means that although we can tell a task to stop work the task itself is free to completely ignore that instruction and carry on for as long as it wants. If you think about it, this behavior makes a lot of sense – if we could force a task to stop immediately, it could leave our program in an inconsistent state.

Cancelling a task – well, marking a task as being cancelled – is done by calling its cancel() method. Inside the task you can either read the Task.isCancelled Boolean to check your current cancellation state, or call Task.checkCancellation(), which will automatically throw a CancellationError if the task is cancelled – if your code continues, you can safely assume the task was not cancelled.

Whether you check the Boolean or call the method depends on what you think the correct behavior should be when cancellation happens. Take for example our factors() function – if that finds out it’s cancelled part-way, should it return the numbers it already has, return an empty array, or throw an error?

This is a personal choice, but I think I’d rather it send back whatever it had so far, like this:

```
func factors(for number: Int) async -> [Int] {
    var result = [Int]()

    for check in 1...number {   
        if number.isMultiple(of: check) {
            result.append(check) 
            await Task.yield()
        }

        if Task.isCancelled {
            return result
        }
    }

    return result
}
```

Beyond just calling cancel() on a task directly, there are two situations you need to be aware of regarding cancellation:

Some parts of Apple’s APIs automatically check for task cancellation and will throw their own cancellation error even without your input. A good example of this is fetching a URL – URLSession will immediately bail out if the task is cancelled.
If you have started a task using SwiftUI’s task() modifier, that task will automatically be cancelled when the view disappears.
So, we have implicit cancellation checks when APIs check for cancellation automatically, and explicit cancellation checks when we read isCancelled or checkCancellation() manually.

Here’s an example I’ve used elsewhere, which fetches an array of doubles from a server then calculates the average value:

```
func getAverageTemperature() async {
    let fetchTask = Task { () -> Double in
        let url = URL(string: "https://hws.dev/readings.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let readings = try JSONDecoder().decode([Double].self, from: data)
        let sum = readings.reduce(0, +)
        return sum / Double(readings.count)
    }

    do {
        let result = try await fetchTask.value
        print("Average temperature: \(result)")
    } catch {
        print("Failed to get data.")
    }
}
```

Now, that code has no explicit cancellation check, but the data(from:) call is an implicit cancellation check: if the task has been cancelled, data(from:) will automatically throw a URLError and the rest of the task won’t execute.

However, it’s unlikely to be an actual cancellation point in practice because it happens right at the beginning of the task. Instead, we could add an explicit cancellation check after the network request, which is more likely – our users might be on a poor connection and get bored waiting for something to complete, and in that situation we should exit the task as soon as the download actually finishes.

Here’s the new function:

```
func getAverageTemperature() async {
    let fetchTask = Task { () -> Double in
        let url = URL(string: "https://hws.dev/readings.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        try Task.checkCancellation()
        let readings = try JSONDecoder().decode([Double].self, from: data)
        let sum = readings.reduce(0, +)
        return sum / Double(readings.count)
    }

    do {
        let result = try await fetchTask.value
        print("Average temperature: \(result)")
    } catch {
        print("Failed to get data.")
    }
}
```

As you can see, it just takes one call to Task.checkCancellation() to make sure our task isn’t wasting time calculating data that’s no longer needed.

# Moving up to task groups
Swift’s task groups are collections of tasks that work together to produce a single result. Each task inside the group must return the same kind of data, but if you use enum associated values you can make them send back different kinds of data – it’s a little clumsy, but it works.

Creating a task group is done in a very precise way to avoid us creating problems for ourselves: rather than creating a TaskGroup instance directly, we do so by calling the withTaskGroup(of:) function and telling it the data type the task group will return. We give this function the code for our group to execute, and Swift will pass in the TaskGroup that was created, which we can then use to add tasks to the group.

First, I want to look at the simplest possible example of task groups, which is returning 5 constant strings, adding them into a single array, then joining that array into a string:

```
func printMessage() async {
    let string = await withTaskGroup(of: String.self) { group -> String in
        group.addTask { "Hello" }
        group.addTask { "From" }
        group.addTask { "A" }
        group.addTask { "Task" }
        group.addTask { "Group" }

        var collected = [String]()

        for await value in group {
            collected.append(value)
        }

        return collected.joined(separator: " ")
    }

    print(string)
}
```

I know it’s trivial, but it demonstrates several important things:

We must specify the exact type of data our task group will return, which in our case is String.self so that each child task can return a string.
We need to specify exactly what the return value of the group will be using group -> String in – Swift finds it hard to figure out the return value otherwise.
We call addTask() once for each task we want to add to the group, passing in the work we want that task to do.
Task groups send back children as soon as they are ready, so we can read all the values from their children using for await until we’ve read them all.
Because the whole task group executes asynchronously, we must call it using await.
Out of all those, the most important thing is that task results are sent back in completion order and not creation order. That is, our code above might send back “Hello From A Task Group”, but it also might send back “Task From A Hello Group”, “Group Task A Hello From”, or any other possible variation – the return value is likely to be different every time.

Tasks created using withTaskGroup() cannot throw errors. If you want them to be able to throw errors that bubble upwards – i.e., that are handled outside the task group – you should use withThrowingTaskGroup() instead.

To demonstrate this, and also to demonstrate a more real-world example of TaskGroup in action, we could use a slightly different API to fetch our inbox messages – one where we need to make several paged requests to get our inbox:

```
inbox = try await withThrowingTaskGroup(of: [Message].self) { group -> [Message] in
    for i in 1...3 {
        group.addTask {
            let url = URL(string: "https://hws.dev/inbox-\(i).json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([Message].self, from: data)
        }
    }

    let allStories = try await group.reduce(into: [Message]()) { $0 += $1 }
    return allStories.sorted { $0.id < $1.id }
}
```

Tip: That sets inbox directly, so we no longer need to await the value later on.

There’s a lot in that one chunk of code, so let’s break it down:

Fetching and decoding news items might throw errors, and those errors are not handled inside the tasks, so we need to use withThrowingTaskGroup() to create the group.
One of the main advantages of task groups is being able to add tasks inside a loop – we can loop from 1 through 3 and call addTask() repeatedly.
Call the group’s reduce() method boils all its task results down to a single value, which in this case is a single array of news stories.
As I said earlier, tasks in a group can complete in any order, so we need to sort the resulting array of messages to get them all in the correct order.
Regardless of whether you’re using throwing or non-throwing tasks, all tasks in a group must complete before the group returns. You have three options here:

Awaiting all individual tasks in the group.
Calling waitForAll() will automatically wait for tasks you have not explicitly awaited, discarding any results they return.
If you do not explicitly await any child tasks, they will be implicitly awaited – Swift will wait for them anyway, even if you aren’t using their return values.

# Over to you
Here is a struct that stores one item of news:

```
struct NewsStory: Identifiable, Decodable {
    let id: Int
    let title: String
    let strap: String
    let url: URL
}
```

And here are five URLs:

https://hws.dev/news-1.json
https://hws.dev/news-2.json
https://hws.dev/news-3.json
https://hws.dev/news-4.json
https://hws.dev/news-5.json
Your task is to write a SwiftUI app that fetches all five of those feeds and displays them somehow.

Looking for a solution? Try this:

```
struct NewsStory: Identifiable, Decodable {
    let id: Int
    let title: String
    let strap: String
    let url: URL
}

struct ContentView: View {
    @State private var stories = [NewsStory]()

    var body: some View {
        NavigationView {
            List(stories) { story in
                VStack(alignment: .leading) {
                    Text(story.title)
                        .font(.headline)

                    Text(story.strap)
                }
            }
            .navigationTitle("Latest News")
        }
        .task(loadStories)
    }

    func loadStories() async {
        do {
            try await withThrowingTaskGroup(of: [NewsStory].self) { group -> Void in
                for i in 1...5 {
                    group.addTask {
                        let url = URL(string: "https://hws.dev/news-\(i).json")!
                        let (data, _) = try await URLSession.shared.data(from: url)
                        try Task.checkCancellation()
                        return try JSONDecoder().decode([NewsStory].self, from: data)
                    }
                }

                for try await result in group {
                    stories.append(contentsOf: result)
                }

                stories.sort { $0.id > $1.id }
            }
        } catch {
            print("Failed to load stories: \(error.localizedDescription)")
        }
    }
}
```

Tip: Keep this NewsStory code around for a bit longer – we’ll experiment with it some more in the next chapter.