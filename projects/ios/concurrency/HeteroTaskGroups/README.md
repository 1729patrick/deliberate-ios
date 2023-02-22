# How to cancel a task group
Swift’s task groups can be cancelled in one of three ways:

If the parent task of the task group is cancelled.
If you explicitly call cancelAll() on the group.
If one of your child tasks throws an uncaught error, all remaining tasks will be implicitly cancelled.
The first of those happens outside of the task group, but the other two are worth investigating.

First, calling cancelAll() will cancel all remaining tasks. As with standalone tasks, cancelling a task group is cooperative – your child tasks can check for cancellation using Task.isCancelled or Task.checkCancellation(), but they can ignore cancellation entirely if they want.

I’ll show you a real-world example of cancelAll() in action in a moment, but before that I want to show you some toy examples so you can see how it works.

We could write a simple printMessage() function like this one, creating three tasks inside a group in order to generate a string:

```
func printMessage() async {
    let result = await withThrowingTaskGroup(of: String.self) { group -> String in
        group.addTask {
            return "Testing"
        }

        group.addTask {
            return "Group"
        }

        group.addTask {
            return "Cancellation"
        }

        group.cancelAll()
        var collected = [String]()

        do {
            for try await value in group {
                collected.append(value)
            }
        } catch {
            print(error.localizedDescription)
        }

        return collected.joined(separator: " ")
    }

    print(result)
}
```

As you can see, that calls cancelAll() immediately after creating all three tasks, and yet when the code is run you’ll still see all three strings printed out. I’ve said it before, but it bears repeating and this time in bold: cancelling a task group is cooperative, so unless the tasks you add implicitly or explicitly check for cancellation calling cancelAll() by itself won’t do much.

To see cancelAll() actually working, try replacing the first addTask() call with this:

```
group.addTask {
    try Task.checkCancellation()
    return "Testing"
}
```

And now our behavior will be different: you might see “Cancellation” by itself, “Group” by itself, “Cancellation Group”, “Group Cancellation”, or nothing at all.

To understand why, keep the following in mind:

Swift will start all three tasks immediately. They might all run in parallel; it depends on what the system things will work best at runtime.
Although we immediately call cancelAll(), some of the tasks might have started running.
All the tasks finish in completion order, so when we first loop over the group we might receive the result from any of the three tasks.
When you put those together, it’s entirely possible the first task to complete is the one that calls Task.checkCancellation(), which means our loop will exit, we’ll print an error message, and send back an empty string. Alternatively, one or both of the other tasks might run first, in which case we’ll get our other possible outputs.

Remember, calling cancelAll() only cancels remaining tasks, meaning that it won’t undo work that has already completed. Even then the cancellation is cooperative, so you need to make sure the tasks you add to the group check for cancellation.

With that toy example out of the way, we could alter our news app so that if any of the fetches throws an error the whole group will throw an error and end, but if a fetch somehow succeeds while ending up with an empty array it means our data quota has run out and we should stop trying any other feed fetches.

Here’s how we’d need to change the loop:

```
for try await result in group {
    if result.isEmpty {
        group.cancelAll()
    } else {
        stories.append(contentsOf: result)
    }
}
```

As you can see, that calls cancelAll() as soon as any feed sends back an empty array, thus aborting all remaining fetches. Inside the child tasks there is an explicit call to Task.checkCancellation(), but the data(from:) also runs check for cancellation to avoid doing unnecessary work.

Tip: Calling addTask() on your group will unconditionally add a new task to the group, even if you have already cancelled the group. If you want to avoid adding tasks to a cancelled group, use the addTaskUnlessCancelled() method instead – it works identically except will do nothing if called on a cancelled group. Calling addTaskUnlessCancelled() returns a Boolean that will be true if the task was successfully added, or false if the task group was already cancelled.

# How to handle different result types in a task group
Each task in a Swift task group must return the same type of data as all the other tasks in the group, which is often problematic – what if you need one task group to handle several different types of data?

In this situation you should consider using async let for your concurrency if you can, because every async let expression can return its own unique data type. So, the first might result in an array of strings, the second in an integer, and so on, and once you’ve awaited them all you can use them however you please.

However, if you need to use task groups – for example if you need to create your tasks in a loop – then there is a solution: create an enum with associated values that wrap the underlying data you want to return. Using this approach, each of the tasks in your group still return a single data type – one of the cases from your enum – but inside those cases you can place the unique data types you’re actually using.

This is best demonstrated with some example code, but because it’s quite a lot I’m going to add inline comments so you can see what’s going on:

```
// A struct we can decode from JSON, storing news stories
struct NewsStory: Decodable {
    let id: Int
    let title: String
    let strap: String
}

// Another struct we can decode from JSON, storing high scores
struct Score: Decodable {
    let name: String
    let score: Int
}

// The combined view model for our app
struct ViewModel {
    let stories: [NewsStory]
    let scores: [Score]
}

// A single enum we'll be using for our tasks, each containing a different associated value.
enum FetchResult {
    case newsStories([NewsStory])
    case scores([Score])
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .task(loadData)
    }

    func loadData() async {
        // Each of our tasks will return one FetchResult, and the whole group will send back a ViewModel.
        let viewModel = await withThrowingTaskGroup(of: FetchResult.self) { group -> ViewModel in
            // Fetch our news stories
            group.addTask {
                let url = URL(string: "https://hws.dev/headlines.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode([NewsStory].self, from: data)

                // Send back FetchResult.newsStory, placing the array inside.
                return .newsStories(result)
            }

            // Fetch our latest high test scores
            group.addTask {
                let url = URL(string: "https://hws.dev/scores.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode([Score].self, from: data)

                // Send back FetchResult.scores, placing the array inside.
                return .scores(result)
            }

            // At this point we've started all our tasks,
            // so now we need to stitch them together into
            // a single ViewModel instance. First, we set
            // up some default values:
            var newsStories = [NewsStory]()
            var scores = [Score]()

            // Now we read out each value, figure out
            // which case it represents, and copy its
            // associated value into the right variable.
            do {
                for try await value in group {
                    switch value {
                    case .newsStories(let value):
                        newsStories = value
                    case .scores(let value):
                        scores = value
                    }
                }
            } catch {
                // If any of the fetches went wrong, we might
                // at least have partial data we can send back.
                print("Fetch at least partially failed; sending back what we have so far. \(error.localizedDescription)")
            }

            // Send back our view model, either filled with
            // default values or using the data we
            // fetched from the server.
            return ViewModel(stories: newsStories, scores: scores)
        }

        // Now do something with the finished user data.
        print(viewModel.stories)
        print(viewModel.scores)
    }
}
```

I know it’s a lot of code, but really it boils down to two things:

Creating an enum with one case for each type of data you’re expecting, with each case having an associated value of that type.
Reading the results from your group’s tasks using a switch block that reads each case from your enum, extracts the associated value inside, and acts on it appropriately.
So, it’s not impossible to handle heterogeneous results in a task group, it just requires a little extra thinking.

# Over to you
Try writing code to fetch three different URLs containing user data, and stitching them together into a single User struct.

Here’s what your finished User struct should look like:

```
struct User {
    let username: String
    let messages: [Message]
    let favorites: Set<Int>
}
```

And here are the three URLs you’ll need to use:

1. https://hws.dev/username.json – you can decode this directly as a string.
2. https://hws.dev/user-messages.json
3. https://hws.dev/user-favorites.json – you can decode this as a Set<Int> or an array.
Looking for a solution? Try something like this:

```
// A struct we can decode from JSON, storing one message from a contact.
struct Message: Decodable {
    let id: Int
    let from: String
    let message: String
}

// A user, containing their name, favorites list, and messages array.
struct User {
    let username: String
    let favorites: Set<Int>
    let messages: [Message]
}

// A single enum we'll be using for our tasks, each containing a different associated value.
enum FetchResult {
    case username(String)
    case favorites(Set<Int>)
    case messages([Message])
}

func loadUser() async {
    // Each of our tasks will return one FetchResult, and the whole group will send back a User.
    let user = await withThrowingTaskGroup(of: FetchResult.self) { group -> User in
        // Fetch our username string
        group.addTask {
            let url = URL(string: "https://hws.dev/username.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = String(decoding: data, as: UTF8.self)

            // Send back FetchResult.username, placing the string inside.
            return .username(result)
        }

        // Fetch our favorites set
        group.addTask {
            let url = URL(string: "https://hws.dev/user-favorites.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(Set<Int>.self, from: data)

            // Send back FetchResult.favorites, placing the set inside.
            return .favorites(result)
        }

        // Fetch our messages array
        group.addTask {
            let url = URL(string: "https://hws.dev/user-messages.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode([Message].self, from: data)

            // Send back FetchResult.messages, placing the message array inside
            return .messages(result)
        }

        // At this point we've started all our tasks,
        // so now we need to stitch them together into
        // a single User instance. First, we set
        // up some default values:
        var username = "Anonymous"
        var favorites = Set<Int>()
        var messages = [Message]()

        // Now we read out each value, figure out
        // which case it represents, and copy its
        // associated value into the right variable.
        do {
            for try await value in group {
                switch value {
                case .username(let value):
                    username = value
                case .favorites(let value):
                    favorites = value
                case .messages(let value):
                    messages = value
                }
            }
        } catch {
            // If any of the fetches went wrong, we might
            // at least have partial data we can send back.
            print("Fetch at least partially failed; sending back what we have so far. \(error.localizedDescription)")
        }

        // Send back our user, either filled with
        // default values or using the data we
        // fetched from the server.
        return User(username: username, favorites: favorites, messages: messages)
    }

    // Now do something with the finished user data.
    print("User \(user.username) has \(user.messages.count) messages and \(user.favorites.count) favorites.")
}
```