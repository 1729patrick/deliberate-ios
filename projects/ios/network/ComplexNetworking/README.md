# Modern, safe networking
Some apps – banking apps, password managers, social media and so on – have complex networking requirements because of requirements like OAuth 2, certificate pinning, and more. But the vast majority of apps are much simpler: we want to read and write data, so with such simple requirements how can we make networking? Let’s find out…

# Starting from scratch
We’re going to start from a place you’re familiar with: a trivial SwiftUI app that fetches some data, and decodes it for display. We’ll use two different data types, so let’s start by creating these two structs:

```
struct News: Decodable, Identifiable {
    var id: Int
    var title: String
    var strap: String
    var url: URL
}

struct Message: Decodable, Identifiable {
    var id: Int
    var from: String
    var text: String
}
```

Now we can store arrays of those as properties in ContentView:

```
@State private var headlines = [News]()
@State private var messages = [Message]()
```

Place a List into the body property to show both pieces of data in different sections:

```
List {
    Section("Headlines") {
        ForEach(headlines) { headline in
            VStack(alignment: .leading) {
                Text(headline.title)
                    .font(.headline)

                Text(headline.strap)
            }
        }
    }

    Section("Messages") {
        ForEach(messages) { message in
            VStack(alignment: .leading) {
                Text(message.from)
                    .font(.headline)

                Text(message.text)
            }
        }
    }
}
```

And finally attach a task() modifier to the List, to fetch both pieces of data and decode them into the properties:

```
.task {
    do {
        let headlinesURL = URL(string: "https://hws.dev/headlines.json")!
        let messagesURL = URL(string: "https://hws.dev/messages.json")!

        let (headlineData, _) = try await URLSession.shared.data(from: headlinesURL)
        let (messageData, _) = try await URLSession.shared.data(from: messagesURL)

        headlines = try JSONDecoder().decode([News].self, from: headlineData)
        messages = try JSONDecoder().decode([Message].self, from: messageData)
    } catch {
        print("Error handling is a smart move!")
    }
}
```

That’s our basic app done, so go ahead and run it now – you should see all the headlines and messages appearing. Yes, the two pieces of information aren’t related, but having two very different things to load is important as you’ll see!

# Step 1: Eliminating strings
We’re going to make a whole bunch of changes to our code over time, building up to something great by the end. However, I’ve structure these changes incrementally, so you’re welcome to jump off the bus at any point – take what you like, and leave what you don’t.

The first change we’re going to make is to remove strings from the main body of our code. Our URLs are both fixed on a server, so typing them out as string each time we need them is long-winded and also likely to break.

So, we’re going to create a new Endpoint struct that holds a URL, and create two static instances of that for the two URLs we want to fetch:

```
struct Endpoint {
    var url: URL

    static let headlines = Endpoint(url: URL(string: "https://hws.dev/headlines.json")!)
    static let messages = Endpoint(url: URL(string: "https://hws.dev/messages.json")!)
}
```

That defines fixed constants referring to resources on my server. We can now create a simple NetworkManager struct that has the job of fetching and returning some data for an endpoint, like this:

```
struct NetworkManager {
    func fetch(_ resource: Endpoint) async throws -> Data {
        var request = URLRequest(url: resource.url)
        var (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
```

Tip: Swift will flag up warning that request and data could be made constants. This is intentional, so please leave them as variables.

Having those two new structs in place makes our ContentView code simpler. We need to add a property to store a network manager instance:

```
let networkManager = NetworkManager()
And then adjust the task() code to this:

do {
    let headlineData = try await networkManager.fetch(.headlines)
    let messageData = try await networkManager.fetch(.messages)

    headlines = try JSONDecoder().decode([News].self, from: headlineData)
    messages = try JSONDecoder().decode([Message].self, from: messageData)
} catch {
    print("Error handling is a smart move!")
}
```

This means we define our URLs in one centralized place, and there’s no risk of mistyping them elsewhere.

# Step 2: Automatic decoding
A lot of the time, we expect to receive exactly the same response from a URL, such as some JSON in a fixed format, for example. That’s not always the case – some URLs return nothing, some might return varying data, and other times we might want to read only part of the JSON that gets sent back – but it is certainly extremely common.

In fact, it’s so common that we can upgrade our networking stack to bake decoding right in. This takes a little thinking as you’ll see.

First, we need to upgrade the Endpoint struct so that it’s generic over some kind of data that conforms to the Decodable protocol:

```
struct Endpoint<T: Decodable> {
  ```

We also want to store the type that was provided as a property on that struct, so we can decode to it later on:

```
var type: T.Type
 ```

And now Swift will hit us with errors: those two static properties in Endpoint are now no longer valid.

The reason for this is clear if you think about what’s happening with the generic type parameter. When we made Endpoint generic, we said it might exist as Endpoint<[News]>, Endpoint<Int>, Endpoint<String>, and any other type that conforms to Decodable. Which one of those should store the two static properties – all of them? Just one?

It’s confusing, and so Swift makes us clear up the confusion by adding the properties in an extension to one specific variant of Endpoint. In our code, that means moving the news property to an Endpoint extension where T is an array of news, like this:

```
extension Endpoint where T == [News] {
    static let headlines = Endpoint(url: URL(string: "https://hws.dev/headlines.json")!, type: [News].self)
}
 ```

And moving messages to an extension where T is an array of messages:

```
extension Endpoint where T == [Message] {
    static let messages = Endpoint(url: URL(string: "https://hws.dev/messages.json")!, type: [Message].self)
}
 ```

That fixes some of the errors, but there’s still another in our fetch() method: we’re using Endpoint without a generic type parameter, so Swift doesn’t know what we mean.

Now that our endpoints have their type baked right in, we can add that to our fetch method signature like this:

```
func fetch<T>(_ resource: Endpoint<T>) async throws -> T {
  ```

That means we expect to be given an Endpoint<T>, and will return a T from the method. So, if our endpoint is an Endpoint<String>, we’ll return a string. Notice how we haven’t had to say that T conforms to Decodable – we already made that a requirement in the Endpoint struct, so Swift knows it must be true here.

Now that we’re promising to return whatever type is inside our endpoint, we need to move our decoding into fetch(). That means replacing the simple return data code with this:

```
let decoder = JSONDecoder()
return try decoder.decode(T.self, from: data)
 ```

And now our task() code in ContentView becomes even simpler:

```
do {
    headlines = try await networkManager.fetch(.headlines)
    messages = try await networkManager.fetch(.messages)
} catch {
    print("Error handling is a smart move!")
}
 ```

Nice!

# Sending and receiving
Our current code does a good job at simply fetching data from a server, but very often we want to write data too. Although there are quite a few different HTTP methods available for us to use, by far the most common are:

- GET, for reading data.
- POST, for writing data.
- PUT, for overwriting an object with a new value.
- PATCH, for modifying part of an object with a new value.
- DELETE, for removing an object entirely.

According to the HTTP standard, each of those need to be written in uppercase, so to avoid making our Swift code ugly we’ll keep Swift-style lowercase enum cases, and uppercase using a computed raw value.

Add this enum now:

```
enum HTTPMethod: String {
    case delete, get, patch, post, put

    var rawValue: String {
        String(describing: self).uppercased()
    }
}
 ```

A simple GET request just reads values from the server, but something like a POST request can have data attached containing some encoded data for the server to process. While it’s possible that you’ll always want to attach the same data for a given endpoint, in practice that’s very unlikely – it will always be a POST request, but what you send will change depending on what the user does.

So, we’re going to store the HTTP method in our endpoint, but won’t attach any data there; that will come later.

Add this property to the struct:

```
var method = HTTPMethod.get
 ```

Now we can upgrade our fetch() method to attach that method to our URLRequest, and also accept any data that needs to be sent as part of the request:

```
func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil) async throws -> T {
    var request = URLRequest(url: resource.url)
    request.httpMethod = resource.method.rawValue
    request.httpBody = data
 ```
For some servers that will be enough, but really when writing data using JSON you should tell the server that’s what you’re sending, otherwise technically it should treat the input as plain text.

So, we’re going to add another field to Endpoint to track any custom header data, which will be useful for specifying what we’re sending. Add this property now:

```
var headers = [String: String]()
```

Inside the fetch() method we need to all those custom headers to the request we’re sending, which means adding another line of code below the httpMethod and httpBody:

```
request.allHTTPHeaderFields = resource.headers
```

If you want to verify that sending data works, I recommend you use a site such as https://reqres.in where you can post any data you like and get a reasonable response.

For example, we could add an endpoint just to test out that posting a new user in JSON responds correctly:

```
extension Endpoint where T == [String: String] {
    static let userTest = Endpoint(url: URL(string: "https://reqres.in/api/users")!, type: [String: String].self, method: .post, headers: ["Content-Type": "application/json"])
}
```

Then we could try that out inside our task() code:

```
let user = ["name": "Bilbo Baggins", "job": "Ring Courier"]

let response = try await networkManager.fetch(.userTest, with: JSONEncoder().encode(user))
print(response)
```

You should see the same data we sent – name and job – but now with the addition of an ID number and a “createdAt” value, mimicking a real server reply.

Tip: You can delete the test code now you know posting data works.

# Adding in an environment
Any app that takes networking seriously will usually have more than one environment, which means different URLs for testing and production, different configuration, and likely different API keys too.

These environments matter a lot, and you certainly don’t want to mix them up. So, we’re going to extend our networking API to support them, and in doing so make sure that the various environments can’t clash.

Start by making a new Swift struct to store data about an environment: its user-facing name (that’s for us), the base URL it’s pointing to (our server, plus whatever base path we need), plus a URLSession instance that’s configured with whatever settings we want.

Here’s that in code:

```
struct AppEnvironment {
    var name: String
    var baseURL: URL
    var session: URLSession
}
```
We can now go ahead and add all the environments we want. Usually you’ll want at least two: production with live user data for your shipping app, and a testing/sandbox environment that’s identical to the production environment but is only for development use. Sometimes you’ll see companies separate testing/sandbox into two environments: one that is more or less the same as production, and one where the environment might be different to production because new features are being tested or experimented with.

Anyway, I suggest you add your environments as static properties inside the AppEnvironment struct. For example, you might add a production environment like this:

```
static let production = AppEnvironment(
    name: "Production",
    baseURL: URL(string: "https://hws.dev")!,
    session: {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "APIKey": "production-key-from-keychain"
        ]
        return URLSession(configuration: configuration)
    }()
)
```

That has a placeholder for an API key – please don’t hard-code it in there, but instead fetch it from your server and store it securely.

You could also add a testing environment like this one:

```
#if DEBUG
static let testing = AppEnvironment(
    name: "Testing",
    baseURL: URL(string: "https://hws.dev")!,
    session: {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.httpAdditionalHeaders = [
            "APIKey": "test-key"
        ]
        return URLSession(configuration: configuration)
    }()
)
#endif
```

As you can see I’ve made that use a different session configuration that ignores all caches, and I’ve also wrapped it in a #if DEBUG so it never goes to the App Store. Yes, I’ve used the same base URL for both production and testing environments – those environments and their configurations are just to give you some ideas – you’ll need to adapt them to your own needs.

Now that we have app environments in play, we need to adjust the rest of our code to use them. More specifically, our endpoints should now no longer contain full URLs, but instead should just have paths – the last part of the URL. For example, rather than using https://hws.dev/headlines.json, we would instead have https://hws.dev as the base URL for our app environment, there have headlines.json as the path for our endpoint.

Using this approach means the path stays the same regardless of what environment we’re using, while the base URL can change. This is how we can ensure we don’t accidentally touch the production environment from testing code: once configured for the test environment, all requests route through to the test base URL.

To make this happen, start by replacing the url property of Endpoint with this:

```
var path: String
```

You’ll need to adjust the two endpoints for headlines.json and messages.json so they send in simple paths rather than full URLs:

```
extension Endpoint where T == [News] {
    static let headlines = Endpoint(path: "headlines.json", type: [News].self)
}

extension Endpoint where T == [Message] {
    static let messages = Endpoint(path: "messages.json", type: [Message].self)
}
```

When it comes to our NetworkManager struct, we need to make sure this is aware of the current app environment so it can use the correct configuration.

That means adding a new property to NetworkManager to track which environment is being used:

```
var environment: AppEnvironment
```

It also means our fetch() method needs to construct its URL by combining the base URL of the environment with the path for the specific endpoint that is being requested. This should Just Work™, but there’s no harm being safe so we’ll throw an .unsupportedURL if somehow we can’t construct a full URL for the endpoint.

Replace the start of the method with this:

```
guard let url = URL(string: resource.path, relativeTo: environment.baseURL) else {
    throw URLError(.unsupportedURL)
}

var request = URLRequest(url: url)
Then replace the call to URLSession.shared.data(for: request) with this:

var (data, _) = try await environment.session.data(for: request)
```

Finally, we’ll need to change the way we create the networkManager property in ContentView, so it selects an app environment. You could make this dynamic using some kind of debugging screen, but we’ll just specify one explicitly here:

```
let networkManager = NetworkManager(environment: .production)
```

That should now work, and it’s taken us to the next level of functionality: the ability to flip between two or more different environment configurations, while also protecting us from accidentally using the wrong URL.

# Sharing the environment
Having each network-enabled view create its own NetworkManager instance with its own app environment is clearly not ideal, so the next step up for us is to have our app decide its configuration at launch, then share that configuration everywhere that wants it.

This is best done using a custom environment key to store a fully configured network manager.

This takes four steps, starting with a struct that conforms to the EnvironmentKey protocol so that we have a default value in place in case we forgot to inject something. It’s best to play it safe here, so we’ll default to the testing environment if nothing else was specified - add this now:

```
struct NetworkManagerKey: EnvironmentKey {
    static var defaultValue = NetworkManager(environment: .testing)
}
```

The second step is to add a custom EnvironmentValue property that knows how to read and write the NetworkManagerKey we just created:

```
extension EnvironmentValues {
    var networkManager: NetworkManager {
        get { self[NetworkManagerKey.self] }
        set { self[NetworkManagerKey.self] = newValue }
    }
}
```

The third step is to adjust our app struct so that it creates a local network manager instance:

```
@State private var networkManager = NetworkManager(environment: .testing)
```

And also injects that instance into the environment:

```
WindowGroup {
    ContentView()
        .environment(\.networkManager, networkManager)
}
```

The final step is to modify the networkManager property in ContentView so that it comes from the environment rather than being made locally:

```
@Environment(\.networkManager) var networkManager
```

That’s it – we now have a single, app-wide environment in place, which any view can read and use.

# Adding retry support
Most of the time we’re dealing with a pretty flaky connection: a user on their iPhone, perhaps walking around or even on something like a train. As a result, having support for retrying fetches is a really good idea to maximize our chances of getting data back – we want to make a request, but if it fails pause for a short amount of time before trying again.

This is extremely easy to implement in our networking stack: we can add a fetch() overload that accepts an integer storing how many attempts to make, along with an optional number of seconds to wait between retries. This can then call itself repeatedly until either we run out of retries or we get a successful response.

Here’s how that looks:

```
func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, attempts: Int, retryDelay: Double = 1) async throws -> T {
    do {
        print("Attempting to fetch (Attempts remaining: \(attempts)")
        return try await fetch(resource, with: data)
    } catch {
        if attempts > 1 {
            try await Task.sleep(for: .milliseconds(Int(retryDelay * 1000)))
            return try await fetch(resource, with: data, attempts: attempts - 1, retryDelay: retryDelay)
        } else {
            throw error
        }
    }
}
```

That’s really all it takes – we can now attempt to read some API three or four times before finally giving up!

# Choosing a sensible default
Sometimes handling errors with a catch block is exactly what you want, but other times you’ll find you can provide a sensible default for times when a request fails.

We can implement this using another small fetch() overload that accepts a default value of our T type, and calls down to the original fetch() method. If that original method throws an error, we return the default value instead, like this:

```
func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, defaultValue: T) async throws -> T {
    do {
        return try await fetch(resource, with: data)
    } catch {
        return defaultValue
    }
}
```

It’s a really small change, but it adds a little extra ease of use to our API – that default value option is there as an alternative any time you need it.

# And finally…
At this point we have something really nice: the ability to request any URL, using any HTTP method, decoding to any compatible type, with lots of safety in place.

The last thing I want to show you is a little trick I use in my own projects while I’m prototyping: how to decode just part of some JSON using a key path. The code for this is probably not something I’d ship unless I really had no choice, but as you’ll see it does make prototyping much easier.

To see why this might be important, take a look at this JSON: https://hws.dev/nested.json. If you only actually cared what city the user lived in, you’d need to read the response, then the user, then the address, then finally the city – you’d need to create Decodable structs for each layer of the chain, then toss most of them away at the end.

We’re going to modify our fetching code so that it’s able to decode just a subset of the response. To be clear, it is a much better idea to ask your server team to vend different JSON for this work. However, I find this really useful for prototyping because it means I can serve up a big pile of JSON, dig through it freely with my networking API, then adjust the JSON only once I know the format is working well.

This requires a couple of small changes, starting with another new property for Endpoint to store the key path we want to read:

```
var keyPath: String?
```

We can add a test endpoint to read nested.json, digging through all the data to look for the user’s city string. Key paths specified as strings should have their various components separated by dots, like this:

```
extension Endpoint where T == String {
    static let city = Endpoint(path: "nested.json", type: String.self, keyPath: "response.user.address.city")
}
```

You can go ahead and add a test call for that to your task() modifier in ContentView – this will just print the value out straight away, for example:

```
let city = try await networkManager.fetch(.city)
print(city)
```

Now for the interesting part: how do we actually tell Codable to decode just part of the data? Keep in mind that it needs to know key names and types for all parts of the tree we’re trying to decode, and we just have "response.user.address.city”.

Well, the trick is this: we don’t use Codable, or at least not at first. Instead, we bounce the data through JSONSerialization, which is how we used to decode JSON before Codable was introduced back in Swift 4.0. This can decode JSON data to arbitrary objects, which is perfect because we can convert the data into an NSDictionary and use its value(forKeyPath:) method to convert "response.user.address.city" into “Cupertino” – it knows exactly how to dig through multiple levels of JSON data using a dot-separated string.

So:

1. If we have a key path set in the endpoint, and
2. If we can convert our data into an NSDictionary, and
3. If we can read the endpoint’s key path from that dictionary, then
4. We’ll convert the resulting data back into JSON and store it in data so our existing JSONDecoder code gets run.

Add this to the fetch() method, just before the let decoder = JSONDecoder() line:

```
if let keyPath = resource.keyPath {
    if let rootObject = try JSONSerialization.jsonObject(with: data) as? NSDictionary {
        if let nestedObject = rootObject.value(forKeyPath: keyPath) {
            data = try JSONSerialization.data(withJSONObject: nestedObject, options: .fragmentsAllowed)
        }
    }
}
```

Like I said, this isn’t exactly code I’d be keen to ship, but it does solve a significant problem in an easy way!

Anyway, hopefully you can see how we can incrementally work towards a smarter networking stack, that has a number of important features:

1. We have a single, fixed base URL for all our requests.
2. We isolate the string parts outside of our views, to avoid repetition and error.
3. We support a range of HTTP methods, including uploading data.
4. We automatically handle decoding of data.
5. We share settings through SwiftUI’s environment.
6. We maximize our chances of getting a good value back by using retries, but we also support default values.
7. We support parsing only part of the returned JSON.

If you wanted to take this further, consider allowing endpoints to customize their JSONDecoder – things like key decoding strategies and date decoding strategies could vary across requests, so making that customizable would be helpful.