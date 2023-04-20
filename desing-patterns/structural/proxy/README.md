# Proxy

**Usage examples:** While the Proxy pattern isn’t a frequent guest in most Swift applications, it’s still very handy in some special cases. It’s irreplaceable when you want to add some additional behaviors to an object of some existing class without changing the client code.

**Identification:** Proxies delegate all of the real work to some other object. Each proxy method should, in the end, refer to a service object unless the proxy is a subclass of a service.

**Complexity:** 1/3
**Popularity:** 2/3

## Intent

Proxy is a structural design pattern that lets you provide a substitute or placeholder for another object. A proxy controls access to the original object, allowing you to perform something either before or after the request gets through to the original object.

![Proxy design pattern](https://refactoring.guru/images/patterns/content/proxy/proxy-2x.png)

## Problem

Why would you want to control access to an object? Here is an example: you have a massive object that consumes a vast amount of system resources. You need it from time to time, but not always.

![Problem solved by Proxy pattern](https://refactoring.guru/images/patterns/diagrams/proxy/problem-en-2x.png)
Database queries can be really slow.

You could implement lazy initialization: create this object only when it’s actually needed. All of the object’s clients would need to execute some deferred initialization code. Unfortunately, this would probably cause a lot of code duplication.

In an ideal world, we’d want to put this code directly into our object’s class, but that isn’t always possible. For instance, the class may be part of a closed 3rd-party library.

## Solution

The Proxy pattern suggests that you create a new proxy class with the same interface as an original service object. Then you update your app so that it passes the proxy object to all of the original object’s clients. Upon receiving a request from a client, the proxy creates a real service object and delegates all the work to it.

![Solution with the Proxy pattern](https://refactoring.guru/images/patterns/diagrams/proxy/solution-en-2x.png)

The proxy disguises itself as a database object. It can handle lazy initialization and result caching without the client or the real database object even knowing.
But what’s the benefit? If you need to execute something either before or after the primary logic of the class, the proxy lets you do this without changing that class. Since the proxy implements the same interface as the original class, it can be passed to any client that expects a real service object.

## Structure
![Structure of the Proxy design pattern](https://refactoring.guru/images/patterns/diagrams/proxy/structure-2x.png)

1. The **Service Interface** declares the interface of the Service. The proxy must follow this interface to be able to disguise itself as a service object.
2. The **Service** is a class that provides some useful business logic.
3. The Proxy class has a reference field that points to a service object. After the proxy finishes its processing (e.g., lazy initialization, logging, access control, caching, etc.), it passes the request to the service object.
  Usually, proxies manage the full lifecycle of their service objects.
4. The **Client** should work with both services and proxies via the same interface. This way you can pass a proxy into any code that expects a service object.

## Applicability

There are dozens of ways to utilize the Proxy pattern. Let’s go over the most popular uses.

Lazy initialization (virtual proxy). This is when you have a heavyweight service object that wastes system resources by being always up, even though you only need it from time to time.

Instead of creating the object when the app launches, you can delay the object’s initialization to a time when it’s really needed.

Access control (protection proxy). This is when you want only specific clients to be able to use the service object; for instance, when your objects are crucial parts of an operating system and clients are various launched applications (including malicious ones).

The proxy can pass the request to the service object only if the client’s credentials match some criteria.

Local execution of a remote service (remote proxy). This is when the service object is located on a remote server.

In this case, the proxy passes the client request over the network, handling all of the nasty details of working with the network.

Logging requests (logging proxy). This is when you want to keep a history of requests to the service object.

The proxy can log each request before passing it to the service.

Caching request results (caching proxy). This is when you need to cache results of client requests and manage the life cycle of this cache, especially if results are quite large.

The proxy can implement caching for recurring requests that always yield the same results. The proxy may use the parameters of requests as the cache keys.

Smart reference. This is when you need to be able to dismiss a heavyweight object once there are no clients that use it.

The proxy can keep track of clients that obtained a reference to the service object or its results. From time to time, the proxy may go over the clients and check whether they are still active. If the client list gets empty, the proxy might dismiss the service object and free the underlying system resources.

The proxy can also track whether the client had modified the service object. Then the unchanged objects may be reused by other clients.

## How to Implement

1. If there’s no pre-existing service interface, create one to make proxy and service objects interchangeable. Extracting the interface from the service class isn’t always possible, because you’d need to change all of the service’s clients to use that interface. Plan B is to make the proxy a subclass of the service class, and this way it’ll inherit the interface of the service.
2. Create the proxy class. It should have a field for storing a reference to the service. Usually, proxies create and manage the whole life cycle of their services. On rare occasions, a service is passed to the proxy via a constructor by the client.
3. Implement the proxy methods according to their purposes. In most cases, after doing some work, the proxy should delegate the work to the service object.
4. Consider introducing a creation method that decides whether the client gets a proxy or a real service. This can be a simple static method in the proxy class or a full-blown factory method.
5. Consider implementing lazy initialization for the service object.

## Pros

You can control the service object without clients knowing about it.
You can manage the lifecycle of the service object when clients don’t care about it.
The proxy works even if the service object isn’t ready or is not available.
Open/Closed Principle. You can introduce new proxies without changing the service or clients.

## Cons
The code may become more complicated since you need to introduce a lot of new classes.
The response from the service might get delayed.

## Relations with Other Patterns

Adapter provides a different interface to the wrapped object, Proxy provides it with the same interface, and Decorator provides it with an enhanced interface.

Facade is similar to Proxy in that both buffer a complex entity and initialize it on its own. Unlike Facade, Proxy has the same interface as its service object, which makes them interchangeable.

Decorator and Proxy have similar structures, but very different intents. Both patterns are built on the composition principle, where one object is supposed to delegate some of the work to another. The difference is that a Proxy usually manages the life cycle of its service object on its own, whereas the composition of Decorators is always controlled by the client.

## Proxy in Swift
Proxy is a structural design pattern that provides an object that acts as a substitute for a real service object used by a client. A proxy receives client requests, does some work (access control, caching, etc.) and then passes the request to a service object.

The proxy object has the same interface as a service, which makes it interchangeable with a real object when passed to a client.

````
import XCTest

class ProxyRealWorld: XCTestCase {

    /// Proxy Design Pattern
    ///
    /// Intent: Provide a surrogate or placeholder for another object to control
    /// access to the original object or to add other responsibilities.
    ///
    /// Example: There are countless ways proxies can be used: caching, logging,
    /// access control, delayed initialization, etc.

    func testProxyRealWorld() {

        print("Client: Loading a profile WITHOUT proxy")
        loadBasicProfile(with: Keychain())
        loadProfileWithBankAccount(with: Keychain())

        print("\nClient: Let's load a profile WITH proxy")
        loadBasicProfile(with: ProfileProxy())
        loadProfileWithBankAccount(with: ProfileProxy())
    }

    func loadBasicProfile(with service: ProfileService) {

        service.loadProfile(with: [.basic], success: { profile in
            print("Client: Basic profile is loaded")
        }) { error in
            print("Client: Cannot load a basic profile")
            print("Client: Error: " + error.localizedSummary)
        }
    }

    func loadProfileWithBankAccount(with service: ProfileService) {

        service.loadProfile(with: [.basic, .bankAccount], success: { profile in
            print("Client: Basic profile with a bank account is loaded")
        }) { error in
            print("Client: Cannot load a profile with a bank account")
            print("Client: Error: " + error.localizedSummary)
        }
    }
}

enum AccessField {

    case basic
    case bankAccount
}

protocol ProfileService {

    typealias Success = (Profile) -> ()
    typealias Failure = (LocalizedError) -> ()

    func loadProfile(with fields: [AccessField], success: Success, failure: Failure)
}

class ProfileProxy: ProfileService {

    private let keychain = Keychain()

    func loadProfile(with fields: [AccessField], success: Success, failure: Failure) {

        if let error = checkAccess(for: fields) {
            failure(error)
        } else {
            /// Note:
            /// At this point, the `success` and `failure` closures can be
            /// passed directly to the original service (as it is now) or
            /// expanded here to handle a result (for example, to cache).

            keychain.loadProfile(with: fields, success: success, failure: failure)
        }
    }

    private func checkAccess(for fields: [AccessField]) -> LocalizedError? {
        if fields.contains(.bankAccount) {
            switch BiometricsService.checkAccess() {
            case .authorized: return nil
            case .denied: return ProfileError.accessDenied
            }
        }
        return nil
    }
}

class Keychain: ProfileService {

    func loadProfile(with fields: [AccessField], success: Success, failure: Failure) {

        var profile = Profile()

        for item in fields {
            switch item {
            case .basic:
                let info = loadBasicProfile()
                profile.firstName = info[Profile.Keys.firstName.raw]
                profile.lastName = info[Profile.Keys.lastName.raw]
                profile.email = info[Profile.Keys.email.raw]
            case .bankAccount:
                profile.bankAccount = loadBankAccount()
            }
        }

        success(profile)
    }

    private func loadBasicProfile() -> [String : String] {
        /// Gets these fields from a secure storage.
        return [Profile.Keys.firstName.raw : "Vasya",
                Profile.Keys.lastName.raw : "Pupkin",
                Profile.Keys.email.raw : "vasya.pupkin@gmail.com"]
    }

    private func loadBankAccount() -> BankAccount {
        /// Gets these fields from a secure storage.
        return BankAccount(id: 12345, amount: 999)
    }
}

class BiometricsService {

    enum Access {
        case authorized
        case denied
    }

    static func checkAccess() -> Access {
        /// The service uses Face ID, Touch ID or a plain old password to
        /// determine whether the current user is an owner of the device.

        /// Let's assume that in our example a user forgot a password :)
        return .denied
    }
}

struct Profile {

    enum Keys: String {
        case firstName
        case lastName
        case email
    }

    var firstName: String?
    var lastName: String?
    var email: String?

    var bankAccount: BankAccount?
}

struct BankAccount {

    var id: Int
    var amount: Double
}

enum ProfileError: LocalizedError {

    case accessDenied

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access is denied. Please enter a valid password"
        }
    }
}

extension RawRepresentable {

    var raw: Self.RawValue {
        return rawValue
    }
}

extension LocalizedError {

    var localizedSummary: String {
        return errorDescription ?? ""
    }
}
````