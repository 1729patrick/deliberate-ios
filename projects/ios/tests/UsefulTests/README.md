# Testing in an async world
How we write tests continues to evolve just as quickly as how we write production code, and that’s important – you should, after all, treat your tests with the same level as care as code you ship. In this article we’ll look at a handful of useful techniques to help write better tests with modern Swift.

# Asserting against async
Let’s start with the basics and work our way up. Create a new Unit Testing Bundle target in your project; naming it TestingSandboxTests is fine. Inside TestSandboxTests.swift, add this import:

```
@testable import TestSandbox
```

That gives us access to all the data types inside our main target, so we can write tests against it.

We don’t have anything to test just yet, so we’ll start by writing a simple class with some failing methods:

```
class DataModel: ObservableObject {
    func goingToFail() throws {
        throw CocoaError(.fileNoSuchFile)
    }

    func goingToFail() async throws {
        try await Task.sleep(for: .milliseconds(500))
        throw CocoaError(.fileNoSuchFile)
    }
}
```

They both have the same signature except for async; Swift knows which one to call based on whether we are calling it from an async context or not.

Now we can write our first two tests in the TestSandboxTests class:

```
func test_failingThrows() throws {
    let sut = DataModel()
    try sut.goingToFail()
}

func test_failingAsyncThrows() async throws {
    let sut = DataModel()
    try await sut.goingToFail()
}
```

Tip: To avoid extra clutter, I suggest you delete any of the template code that was provided by Xcode.

When you run your tests, you’ll see both fail as expected. We haven’t needed to actually provide any assertions to make them fail, because both tests were marked as throws they will automatically be considered failures if the code they run throws – but only if we mark the tests as throwing too. The same is true with async: just marking the tests as async is enough for them to be run in an async context.

Now, although our code works it’s not great because we’re missing all the information we’d expect from a test failure such as what we expected to happen when something went wrong. This is why it’s always preferable to write your own assertions making clear what should happen.

In our case, that means adjusting our tests to these:

```
func test_failingThrows() throws {
    let sut = DataModel()

    do {
        try sut.goingToFail()
    } catch {
        XCTFail("The goingToFail() method should not throw an error.")
    }
}

func test_failingAsyncThrows() async throws {
    let sut = DataModel()

    do {
        try await sut.goingToFail()
    } catch {
        XCTFail("The goingToFail() method should not throw an error.")
    }
}
```

So you can see that the difference between synchronous and asynchronous tests can be trivial: just adding async gets us a long way forward.

# Asserting that code should fail
Our existing tests are trivial, which is why they are easy to write. Things fall down a little when we expect tests to fail, which is really common – yes, you should write tests to prove that some valid input generates a valid response, but you should also write tests to provide that invalid input does not succeed.

We have two methods in our observable object that will always fail, so what if we wanted them to fail – what if we wanted to write tests proving that they fail?

Xcode’s unit testing framework has a built-in XCTAssertThrowsError() function that does exactly what we want: it will run some code, and consider the test to have failed if the code did not throw an error.

So, we can make our synchronous test use that:

```
func test_failingThrows() throws {
    let sut = DataModel()

    try XCTAssertThrowsError(sut.goingToFail(), "The goingToFail() method should have thrown an error.")
}
```

We can also move our async function over to it:

```
func test_failingAsyncThrows() async throws {
    let sut = DataModel()

    try XCTAssertThrowsError(sut.goingToFail(), "The goingToFail() method should have thrown an error.")
}
```

However, that won’t actually work: XCTAssertThrowsError() exists only in a synchronous form, meaning that we can’t use it with async functions.

To fix this we need to add our own version of XCTAssertThrowsError() that does support async functions. The code for this function is trivial, but the function signature needs to be really precise!

Add this now:

```
func XCTAssertThrowsError<T>(_ expression: @autoclosure () async throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) async {
    if let _ = try? await expression() {
        XCTFail(message(), file: file, line: line)
    }
}
```

Let’s break that down:

- The function is generic over some kind of T, which is whatever our test code will return. We don’t actually care what this is.
- The expression we want to evaluate – the code we want test will be async and throwing, and return some kind of T.
- We’ve marked the expression using @autoclosure meaning that it won’t run at the call site and have its value passed in. Instead, the code we want to run is passed in for our test to run when it’s ready.
- The message string is there to show information on what was expected by the test. It’s also an autoclosure so that we don’t generate the message unless the test fails.
- We accept parameters for both file and line to store which file and line number contained the code we were testing. Both of those use built-in compiler values that represent the filename and line number of our Swift code.
- The file parameter has the type StaticString, which is Swift’s type for hard-coded strings – i.e., strings that aren’t variables.
- Inside the function we run our throwing function, then call XCTFail() immediately if the call succeeds. This takes values for file and line, so we just pass them along.
- With that function added, our test_failingAsyncThrows() code works – nice!

# Dealing with actors
At this point I need to give you an important warning: when you mark any test with async, Swift is free to execute that test on whatever actor it wants. This is contrast to regular, synchronous tests that always execute on the main actor.

This means you need to be really careful when testing any UI code. That means any code that directly reads or writes UI data, or does so indirectly using @Published or similar.

If you need to write async tests that will work with any part of your user interface, I suggest you mark the test with @MainActor like this:

```
@MainActor
func test_failingAsyncThrows() async throws {
  ```

You can also just @MainActor for your whole test class to make all its test cases run there.

# Checking for changes
Tests verifying our code works the way we expect, and in SwiftUI code that often means verifying our property wrappers work the way we expect.

As an example, we could a simple flag Boolean to our data model class, either like this:

```
@Published var flag = false
Or like this if you prefer:

var flag = false {
    willSet {
        objectWillChange.send()
    }
}
 ```

Either way, the point is that we’ve added some significant logic to our code: whenever that Boolean is changed, our class should publish a change notification to any other types that are watching.

To test that the notification is actually sent out – to ensure that we don’t accidentally remove @Published or similar in the future – we need to make our test watch for the change notification and flip its own Boolean if the notification is triggered.

For example, we might start with this:

```
func test_flagChangesArePublished() {
    let sut = DataModel()
    var flagChangePublished = false

    let checker = sut.objectWillChange.sink {
        flagChangePublished = true
    }

    sut.flag.toggle()

    XCTAssertTrue(flagChangePublished, "Flipping DataModel.flag should trigger a change notification.")
}
```

As you can see, that assumes no change was published, then attaches a closure to flip that when objectWillChange.send() is triggered. We can then go ahead and toggle the Boolean on our observable object, and check that our local Boolean changed.

Tip: Swift will issue a warning that checker isn’t used. You can silence that by adding _ = checker before the call to toggle().

Obviously that’s quite a lot of work to do for all your published properties, so again we should add a new function to centralize all the work. This is similar to the XCTAssertThrowsError() function we already wrote, except now we need an extra parameter to know which object we should be watching for changes.

Here’s the code:

```
func XCTAssertSendsChangeNotification<T, U: ObservableObject>(_ expression: @autoclosure () -> T, from object: U, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    var changePublished = false

    let checker = object.objectWillChange.sink { _ in
        changePublished = true
    }

    _ = checker
    _ = expression()

    XCTAssertTrue(changePublished, message(), file: file, line: line)
}
```

So, again that assumes no change was published, flips that value if any objectWillChange.send() calls are triggered, then runs the expression.

With that in place we can test our own observable object much more easily:

```
func test_flagChangesArePublished() {
    let sut = DataModel()

    XCTAssertSendsChangeNotification(sut.flag.toggle(), from: sut, "Flipping DataModel.flag should trigger a change notification.")
}
```

These kinds of assertions are so simple to write, but do a lot to make sure your code doesn’t accidentally change in the future.

# Testing tasks
The trickiest kind of code to test is code that starts its own tasks, because these become hidden dependencies – things that are hidden from our tests, but affect the outcome.

As an example, let’s say we had a @Published array of strings on our data model:

```
@Published var names = ["Empty"]
```

We might load that using a background task such as the following:

```
func loadData() {
    Task { @MainActor in
        try? await Task.sleep(for: .seconds(1))
        names = ["John", "Paul", "George", "Ringo"]
    }
}
```

The problem is that the task being created is hidden inside loadData(), which means we have no idea work is taking place in the background. So, if we write a test to check that loading happens, this kind of test isn’t going to work:

```
func test_namesAreLoaded() async {
    let sut = DataModel()

    sut.loadData()

    XCTAssertEqual(sut.names.count, 4, "Calling loadData() should load four names.")
}
```

To fix this we need to make the Task explicit, so our test knows it exists. That means returning it from loadData(), like so:

```
func loadData() -> Task<Void, Never> {
  ```

That means “the task returns nothing, and won’t throw any errors.”

Now, most other parts of our code are unlikely to care that there’s a task being sent back, because the task does its own work of updating the data. This can be annoying, because Xcode will throw up “Result of call to 'loadData()' is unused” warnings.

To fix this, add the @discardableResult attribute to the method, like this:

```
@discardableResult
func loadData() -> Task<Void, Never> {
  ```

That will silence the warning, because we don’t care if non-test parts of our code ignore the returned task.

However, in our tests we do care that the task exists, so we can read the returned task and make our test wait for the task to complete. Here’s how that looks:

```
func test_namesAreLoaded() async {
    let sut = DataModel()

    let task = sut.loadData()
    await task.value

    XCTAssertEqual(sut.names.count, 4, "Calling loadData() should load four names.")
}
```

As you can see, just adding await task.value is enough for the task to complete fully before we make our assertion, and thanks to the @discardableResult attribute it has no other effect on our code – nice!