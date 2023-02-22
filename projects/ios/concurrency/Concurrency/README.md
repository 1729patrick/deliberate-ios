# What does `concurrency` even mean?
Swift 5.5 introduces a massive collection of changes focused around a single topic: `concurrency`. These changes were so big they ended up having to be split into smaller proposals, but that had the side effect of making them inter-linked – you now had to read many proposals to get the same information, and many proposals built upon one or more other proposals.

Back when I started reading through all the proposals in detail back in late January, I figured out an order that I think is the most logical for learners. That’s the order I’ve used since then, and that’s the order we’ll be using here – it tries to introduce individual topics one at a time, building on what you know rather than surprising you with concepts.

We’re going to spend a whole day exploring `concurrency` in Swift, but first I need to make something really clear: this is easily the most complex set of changes introduced in Swift since it launched. This means a few things:

There’s a good chance you’re not going to understand at least one concept presented here, at least not at first.
Sometimes you might need to understand a later concept before an earlier concept makes sense.
Some of these Swift changes are still in review. Yes, almost two months after WWDC they are still making changes.
I’m going to deliberately avoid some specific topics early on, because I don’t want to jump around too much. Don’t worry, it will all get covered eventually!
I said it earlier, but it’s worth reminding you of the importance of asking questions here – if you don’t understand something, please ask and I’ll do my best to clarify!

Before we get into the actual Swift changes, there are two topics you need to understand at a very high level. The first is this: what’s the difference between `concurrency` and parallelism? They don’t quite match how we use them in English, so it’s important we get a clear definition up front.

A core computer science topic is that of multitasking – the ability for a computer to do many things at the same time. We take it for granted these days that an average iPhone has multiple CPU cores inside, and some Mac Pro computers have 28 of them available.

These are independent CPU cores, and so they can literally be running lots of pieces of code at the same time. Perhaps one core is handling Apple Music, another is unzipping a file, a third is letting you navigate around a Finder window, and the remaining 25 are all trying to build a massive Xcode project. It doesn’t matter what they are doing – the point is that all those things are happening at the same instant, or in parallel.

But what would happen if you had only one CPU core? I know it sounds hard to believe these days, but even 15 years ago almost all desktop computers had just a single CPU core inside them. Obviously those computers seem terrifically primitive these days, but they still supported multi-tasking – if you were using Mac OS X 10.4 on a single CPU, you could still listen to music, use Safari, and, yes, even build Xcode projects.

But were you doing those things at the same time?

Yes.

And no.

From the user’s perspective all those things were happening at the same time, however we know that isn’t possible: a single-core CPU can only do one thing at a time.

This feat was made possible thanks to time slicing: the CPU split up all its scheduled work into tiny chunks called time slices, usually about 10 milliseconds each, and by jumping between all available tasks at that speed it looked like they were all running in parallel – that’s 100 different tasks being run every single second.

This is `concurrency`: the operating system was written in such a way that one CPU core can juggle all its tasks so from the user’s perspective they are all running at the same time. One starts, makes a tiny bit of progress on its work, then pauses so that another one can start, make a bit of progress on its work, then pause, and so on.

So, `concurrency` is how we build system so they can be juggled in this way – we’re writing code that knows how to do a little bit of work then stop, then do a little bit more work and stop, and so on. It’s baked right into operating systems through all the many API calls our apps make, but in Swift 5.5 `concurrency` gets surfaced at the app level too.

To be clear, `concurrency` is not the practice of running multiple pieces of code at the same time. Instead, that’s what we call parallelism: when two or more programs run at the same instant. This is not possible in a single-core CPU for the reasons I already said, but as soon as you add a second CPU core to a computer then it becomes possible.

With two cores in place, our computer can do its work up to twice as fast because two programs are literally able to run at the same time. Yes, time slicing still happens because every computer needs to run more than just two programs, but at least now two pieces of work can make progress at the same time.

Note that I said the computer is up to twice as fast, because having two cores leads to a whole new problem around resource locks and similar, but in theory the performance is there.

Now that we have actual parallelism happening, something else becomes more useful: the ability to split up work in a single program – to be able to have two parts of one program running at the same time across two CPU cores.

Having the operating system run different programs on different cores is automatic as far as we’re concerned – we don’t need to do extra work. However, when it comes to making different parts of our program run in parallel then we do need to do some work because Swift can’t just try to pull bits out and hope for the best. Instead, we have to tell Swift ahead of time which parts of our code can be split up if needed, and also tell it what we should do when those tasks complete.

This is where Swift 5.5’s `concurrency` features come in: they give us the tools to teach Swift how it can split up the work in our programs so it can be run concurrently.

Chances are you’re already familiar with more naive forms of `concurrency`, such as Grand Central Dispatch. This solves a similar problem as the new Swift `concurrency` features, albeit by putting almost all the work on us to make sure we don’t screw it up.

However, the benefit is much the same: we can push slow work onto a background thread, so that our user interface didn’t stall all the time.

The second core concept you need to understand is about threads and queues. Threads are small slices of your program that run independently of each other, and they are how CPUs are able to run different parts of a program in parallel – one CPU core can run one thread from the app, while another CPU core runs another thread from the app.

You might already be familiar with the concept of the main thread which is the one your application is launched with. This thread exists for the life of the app, and for all of Apple’s platforms this is the only thread that is able to update the user interface.

Although Swift lets us make as many threads as we want, usually we prefer to think about queues: a simple data structure where we can add work to be executed, and the system will figure out the best place to make that work happen. Queues work much like their real-life counterpart in that they are first-in, first-out (FIFO) by default, although if someone says they have a plane to catch you’re probably going to let them jump ahead of you.

So, before we get into some code, let’s wrap up so far:

`concurrency` is the way we structure our code so that the system is able to deal with many parts of it at the same time.
`Parallelism` is the actual work of running many pieces of code at the same time.
`Threads` let us divide our programs up into small parts that can be run concurrently.
`Queues` let us schedule work in an orderly manner, but we don’t actually care which underlying threads are being used.

# A taste of async/await
Swift 5.5’s `concurrency` features are massive – so many changes across so many parts of the language, backed up by large-scale changes to Apple’s APIs.

And yet two particular keywords have gotten almost all the attention: async and await. Yes, they matter, yes I think you’ll use them more than any other part of the `concurrency` changes – at least directly – but most importantly I think they are worth starting with because so many other features build on top of them.

I want to start by throwing you in at the deep end, using a handy extension I started using a couple of months ago and am really appreciating: a way to download some JSON data from a server, and decode it into a Swift type of our choosing.

If you want to follow along, create a new iOS project using the App template. Make sure you set the iOS deployment target to iOS 15, so all the new APIs are available.

You probably know that downloading data in Swift means using URLSession, and providing it with a data task. This then needs a closure to handle success, response, and error, and you then resume that task. Yes, it works, but it’s a bit messy – surely both the success and error shouldn’t exist at the same time? And if you show me someone who says they’ve never forgotten to call resume() on a data task, I’ll show you a liar.

Apple took the opportunity of async/await being introduced to rethink the URLSession APIs, and there’s a new data(from:) method that sends back the data and response values. Rather than having an error parameter in a closure, it just throws errors like a regular function.

Here’s the extension:

```
extension URLSession {
    func decode<T: Decodable>(
        _ type: T.Type = T.self,
        from url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) throws -> T {
        let (data, _) = try data(from: url)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        let decoded = try decoder.decode(T.self, from: data)
        return decoded
    }
}
```
That code won’t compile just yet because I missed out two important keywords – that’s intentional, just bear with me!

First I want you to focus on the structure of this code. There is no more completion closure for our result, and no more weird situation involving both success and error values. Instead, what we have here is called straight-line code, so-named because the body of the method is all lined up in one vertical column.

In order to make this code compile, we need to do two things. First, we need to tell Swift that calling data(from:) might take some time, and we need to wait for the response to come back. This is done by adding the await keyword to it, like this:

let (data, _) = try await data(from: url)
Now, Swift knows the await keyword is required there, which is why our code didn’t compile in the first place – we’re adding that await keyword there to make the code clearer to humans, not to Swift itself, similar to how we need to use try before calling throwing functions.

I’ll explain more about why that’s needed shortly, but first we need to make a second change to our function to make it compile: we need to add async before the throws keyword, like this:

) async throws -> T {
Notice that the function is marked async throws but the function calls are marked try await – the keyword order gets reversed. So, it’s “asynchronous, throwing” in the function definition, but “throwing, asynchronous” at the call site. Think of it as unwinding a stack. Not only does try await read more easily than await try, but it’s also more reflective of what’s actually happening when our code executes: we’re waiting for some work to complete, and when it does complete we’ll check whether it ended up throwing an error or not.

With those two changes, our URLSession extension is complete – that’s all it takes to download and decode some data from a server.

Of course, that’s only part of the problem: how do we actually use that code to download some data?

Well, in our SwiftUI project we’d start by defining some kind of Decodable struct we wanted to work with, like this:

```
struct Message: Identifiable, Decodable {
    let id: Int
    let user: String
    let text: String
}
And then we’d create a simple ContentView capable of showing messages in a list, like this:

struct ContentView: View {
    @State private var inbox = [Message]()

    var body: some View {
        NavigationView {
            List(inbox) { message in
                Text("\(message.user): ").bold() + Text(message.text)
            }
            .navigationTitle("Inbox")
        }
    }
}
```

But we’re still no closer to actually calling the extension. Your first pass at the solution might be to add a method such as this one to ContentView:

```
func fetchInbox() throws -> [Message] {
    var inboxURL = URL(string: "https://hws.dev/inbox.json")!
    return try URLSession.shared.decode(from: inboxURL)
}
But that doesn’t work: just like with the extension, we need to mark it using async and await like this:

func fetchInbox() async throws -> [Message] {
    var inboxURL = URL(string: "https://hws.dev/inbox.json")!
    return try await URLSession.shared.decode(from: inboxURL)
}
```
In order to call an async function we must mark the call with await, and as soon as we use await our own function must be marked with async.

If this sounds like we’re in a bit of a loop, it’s because we are. In fact, no part of the async/await proposal on Swift Evolution actually covers how to call that initial async function – how to actually get the ball rolling with `concurrency`.

Instead, that’s a whole other topic called tasks. We’ll be covering these in detail later, but for now the least you need to know is that there’s a new SwiftUI modifier that lets us perform async work when a view is first shown.

Add this to the list in ContentView now:

```
.task {
    do {
        inbox = try await fetchInbox()
    } catch {
        print(error.localizedDescription)
    }
}
```
And with that we have our first actual piece of `concurrency` work running: when the app runs it will fetch and decode all the inbox messages, and display them in a scrolling list. Nice!

If you’ve done multithreading work before, that kind of code might cause a momentary blip of panic – are we potentially trying to modify inbox from a background thread?

The answer is that we don’t know – that code could be running on the main thread or could be on a background thread, and both are fine. This is because @State automatically works across any thread; it takes care of synchronization for us.

Over to you
Believe it or not, you already know enough to start building async/await apps, and I want to put that to use straight away. Your job is to create a new Xcode project and build a small SwiftUI app that fetches some JSON from my server and displays it however you want.

Here’s the URL: https://hws.dev/petitions.json – it’s a snapshot of the old Whitehouse “We the People” API from a couple of years ago. This was where US citizens could submit petitions for other folks to vote on, and included some wonderful ideas as “Make NASA build a Death Star.”

Take a look at the JSON, pick out whatever data you want from there, and show it in your SwiftUI app.

Important: Start a new project for this, rather than overwriting what you have so far – we’ll be using the current project some more. Make sure and set the minimum deployment target to iOS 15 for your new project!

Looking for a solution? Try something like this:

```
struct Petition: Decodable, Identifiable {
    let id: String
    let title: String
    let body: String
    let signatureCount: Int
    let signatureThreshold: Int
}

struct PetitionView: View {
    let petition: Petition

    var body: some View {
        ScrollView {
            Text(petition.title)
                .font(.title)
                .padding(.horizontal)

            Text(petition.body)
                .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContentView: View {
    @State private var petitions = [Petition]()

    var body: some View {
        NavigationView {
            List(petitions) { petition in
                NavigationLink(destination: PetitionView(petition: petition)) {
                    VStack(alignment: .leading) {
                        Text(petition.title)

                        HStack {
                            Spacer()
                            Text("\(petition.signatureCount)/\(petition.signatureThreshold)")
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Petitions")
            .task {
                do {
                    let url = URL(string: "https://hws.dev/petitions.json")!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    petitions = try JSONDecoder().decode([Petition].self, from: data)
                } catch {
                    print("Failed to fetch petitions.")
                }
            }
        }
    }
}
```