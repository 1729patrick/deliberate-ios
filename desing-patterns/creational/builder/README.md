# Builder

**Usage examples:** The Builder pattern is a well-known pattern in Swift world. It’s especially useful when you need to create an object with lots of possible configuration options.

**Identification:** The Builder pattern can be recognized in a class, which has a single creation method and several methods to configure the resulting object. Builder methods often support chaining (for example, someBuilder.setValueA(1).setValueB(2).create()).

**Complexity:** 2/3
**Popularity:** 3/3

## Intent

Builder is a creational design pattern that lets you construct complex objects step by step. The pattern allows you to produce different types and representations of an object using the same construction code.

![Builder design pattern](https://refactoring.guru/images/patterns/content/builder/builder-en-2x.png?id%3D8da2aa97abfdabf265e622579fc448a1)

## Problem

Imagine a complex object that requires laborious, step-by-step initialization of many fields and nested objects. Such initialization code is usually buried inside a monstrous constructor with lots of parameters. Or even worse: scattered all over the client code.

![Lots of subclasses create another problem](https://refactoring.guru/images/patterns/diagrams/builder/problem1-2x.png?id%3D02ffbd7ad294600e42aa78989d441b4d)
You might make the program too complex by creating a subclass for every possible configuration of an object.

For example, let’s think about how to create a House object. To build a simple house, you need to construct four walls and a floor, install a door, fit a pair of windows, and build a roof. But what if you want a bigger, brighter house, with a backyard and other goodies (like a heating system, plumbing, and electrical wiring)?

The simplest solution is to extend the base House class and create a set of subclasses to cover all combinations of the parameters. But eventually you’ll end up with a considerable number of subclasses. Any new parameter, such as the porch style, will require growing this hierarchy even more.

There’s another approach that doesn’t involve breeding subclasses. You can create a giant constructor right in the base House class with all possible parameters that control the house object. While this approach indeed eliminates the need for subclasses, it creates another problem.

![The telescoping constructor](https://refactoring.guru/images/patterns/diagrams/builder/problem2-2x.png?id%3D5e7975a91c0e4f4ba960f908cc9c2ea2)
The constructor with lots of parameters has its downside: not all the parameters are needed at all times.
In most cases most of the parameters will be unused, making the constructor calls pretty ugly. For instance, only a fraction of houses have swimming pools, so the parameters related to swimming pools will be useless nine times out of ten.

## Solution

The Builder pattern suggests that you extract the object construction code out of its own class and move it to separate objects called builders.

![Applying the Builder pattern](https://refactoring.guru/images/patterns/diagrams/builder/solution1-2x.png?id%3Da9c2ab02f0b2aca1a7512022194dd113)
The Builder pattern lets you construct complex objects step by step. The Builder doesn’t allow other objects to access the product while it’s being built.

The pattern organizes object construction into a set of steps (buildWalls, buildDoor, etc.). To create an object, you execute a series of these steps on a builder object. The important part is that you don’t need to call all of the steps. You can call only those steps that are necessary for producing a particular configuration of an object.

Some of the construction steps might require different implementation when you need to build various representations of the product. For example, walls of a cabin may be built of wood, but the castle walls must be built with stone.

In this case, you can create several different builder classes that implement the same set of building steps, but in a different manner. Then you can use these builders in the construction process (i.e., an ordered set of calls to the building steps) to produce different kinds of objects.

![Different builders execute the same task in various ways.](https://refactoring.guru/images/patterns/content/builder/builder-comic-1-en-2x.png?id%3D99728c9881fbf45fd3b6e0e3373935f1)

For example, imagine a builder that builds everything from wood and glass, a second one that builds everything with stone and iron and a third one that uses gold and diamonds. By calling the same set of steps, you get a regular house from the first builder, a small castle from the second and a palace from the third. However, this would only work if the client code that calls the building steps is able to interact with builders using a common interface.

### Director

You can go further and extract a series of calls to the builder steps you use to construct a product into a separate class called director. The director class defines the order in which to execute the building steps, while the builder provides the implementation for those steps.

![Director](https://refactoring.guru/images/patterns/content/builder/builder-comic-2-en-2x.png?id%3D15035f2ea0317a93eca0177fc7ce2f22)
The director knows which building steps to execute to get a working product.
Having a director class in your program isn’t strictly necessary. You can always call the building steps in a specific order directly from the client code. However, the director class might be a good place to put various construction routines so you can reuse them across your program.

In addition, the director class completely hides the details of product construction from the client code. The client only needs to associate a builder with a director, launch the construction with the director, and get the result from the builder.

## Structure

![Structure](https://refactoring.guru/images/patterns/diagrams/builder/structure-2x.png?id%3Ddca1b1508e23c266cbedc80ffb84311a)

1. The **Builder** interface declares product construction steps that are common to all types of builders.

2. **Concrete Builders** provide different implementations of the construction steps. Concrete builders may produce products that don’t follow the common interface.

3. **Products** are resulting objects. Products constructed by different builders don’t have to belong to the same class hierarchy or interface.

4. The **Director** class defines the order in which to call construction steps, so you can create and reuse specific configurations of products.

5. The **Client** must associate one of the builder objects with the director. Usually, it’s done just once, via parameters of the director’s constructor. Then the director uses that builder object for all further construction. However, there’s an alternative approach for when the client passes the builder object to the production method of the director. In this case, you can use a different builder each time you produce something with the director.

## Applicability

Use the Builder pattern to get rid of a “telescoping constructor”.

Say you have a constructor with ten optional parameters. Calling such a beast is very inconvenient; therefore, you overload the constructor and create several shorter versions with fewer parameters. These constructors still refer to the main one, passing some default values into any omitted parameters.

```
class Pizza {
    Pizza(int size) { ... }
    Pizza(int size, boolean cheese) { ... }
    Pizza(int size, boolean cheese, boolean pepperoni) { ... }
    // ...
```

Creating such a monster is only possible in languages that support method overloading, such as C# or Java.
The Builder pattern lets you build objects step by step, using only those steps that you really need. After implementing the pattern, you don’t have to cram dozens of parameters into your constructors anymore.

Use the Builder pattern when you want your code to be able to create different representations of some product (for example, stone and wooden houses).

The Builder pattern can be applied when construction of various representations of the product involves similar steps that differ only in the details.

The base builder interface defines all possible construction steps, and concrete builders implement these steps to construct particular representations of the product. Meanwhile, the director class guides the order of construction.

Use the Builder to construct Composite trees or other complex objects.

The Builder pattern lets you construct products step-by-step. You could defer execution of some steps without breaking the final product. You can even call steps recursively, which comes in handy when you need to build an object tree.

A builder doesn’t expose the unfinished product while running construction steps. This prevents the client code from fetching an incomplete result.

## How to Implement

1. Make sure that you can clearly define the common construction steps for building all available product representations. Otherwise, you won’t be able to proceed with implementing the pattern.
2. Declare these steps in the base builder interface.
3. Create a concrete builder class for each of the product representations and implement their construction steps.
4. on’t forget about implementing a method for fetching the result of the construction. The reason why this method can’t be declared inside the builder interface is that various builders may construct products that don’t have a common interface. Therefore, you don’t know what would be the return type for such a method. However, if you’re dealing with products from a single hierarchy, the fetching method can be safely added to the base interface.
5. Think about creating a director class. It may encapsulate various ways to construct a product using the same builder object.
6. The client code creates both the builder and the director objects. Before construction starts, the client must pass a builder object to the director. Usually, the client does this only once, via parameters of the director’s class constructor. The director uses the builder object in all further construction. There’s an alternative approach, where the builder is passed to a specific product construction method of the director.
7. The construction result can be obtained directly from the director only if all products follow the same interface. Otherwise, the client should fetch the result from the builder.

## Pros

1. You can construct objects step-by-step, defer construction steps or run steps recursively.
2. You can reuse the same construction code when building various representations of products.
3. Single Responsibility Principle. You can isolate complex construction code from the business logic of the product.
## Cons
1. The overall complexity of the code increases since the pattern requires creating multiple new classes.
# Builder in Swift
Builder is a creational design pattern, which allows constructing complex objects step by step.

Unlike other creational patterns, Builder doesn’t require products to have a common interface. That makes it possible to produce different products using the same construction process.

````
import Foundation
import XCTest


class BaseQueryBuilder<Model: DomainModel> {

    typealias Predicate = (Model) -> (Bool)

    func limit(_ limit: Int) -> BaseQueryBuilder<Model> {
        return self
    }

    func filter(_ predicate: @escaping Predicate) -> BaseQueryBuilder<Model> {
        return self
    }

    func fetch() -> [Model] {
        preconditionFailure("Should be overridden in subclasses.")
    }
}

class RealmQueryBuilder<Model: DomainModel>: BaseQueryBuilder<Model> {

    enum Query {
        case filter(Predicate)
        case limit(Int)
        /// ...
    }

    fileprivate var operations = [Query]()

    @discardableResult
    override func limit(_ limit: Int) -> RealmQueryBuilder<Model> {
        operations.append(Query.limit(limit))
        return self
    }

    @discardableResult
    override func filter(_ predicate: @escaping Predicate) -> RealmQueryBuilder<Model> {
        operations.append(Query.filter(predicate))
        return self
    }

    override func fetch() -> [Model] {
        print("RealmQueryBuilder: Initializing CoreDataProvider with \(operations.count) operations:")
        return RealmProvider().fetch(operations)
    }
}

class CoreDataQueryBuilder<Model: DomainModel>: BaseQueryBuilder<Model> {

    enum Query {
        case filter(Predicate)
        case limit(Int)
        case includesPropertyValues(Bool)
        /// ...
    }

    fileprivate var operations = [Query]()

    override func limit(_ limit: Int) -> CoreDataQueryBuilder<Model> {
        operations.append(Query.limit(limit))
        return self
    }

    override func filter(_ predicate: @escaping Predicate) -> CoreDataQueryBuilder<Model> {
        operations.append(Query.filter(predicate))
        return self
    }

    func includesPropertyValues(_ toggle: Bool) -> CoreDataQueryBuilder<Model> {
        operations.append(Query.includesPropertyValues(toggle))
        return self
    }

    override func fetch() -> [Model] {
        print("CoreDataQueryBuilder: Initializing CoreDataProvider with \(operations.count) operations.")
        return CoreDataProvider().fetch(operations)
    }
}


/// Data Providers contain a logic how to fetch models. Builders accumulate
/// operations and then update providers to fetch the data.

class RealmProvider {

    func fetch<Model: DomainModel>(_ operations: [RealmQueryBuilder<Model>.Query]) -> [Model] {

        print("RealmProvider: Retrieving data from Realm...")

        for item in operations {
            switch item {
            case .filter(_):
                print("RealmProvider: executing the 'filter' operation.")
                /// Use Realm instance to filter results.
                break
            case .limit(_):
                print("RealmProvider: executing the 'limit' operation.")
                /// Use Realm instance to limit results.
                break
            }
        }

        /// Return results from Realm
        return []
    }
}

class CoreDataProvider {

    func fetch<Model: DomainModel>(_ operations: [CoreDataQueryBuilder<Model>.Query]) -> [Model] {

        /// Create a NSFetchRequest

        print("CoreDataProvider: Retrieving data from CoreData...")

        for item in operations {
            switch item {
            case .filter(_):
                print("CoreDataProvider: executing the 'filter' operation.")
                /// Set a 'predicate' for a NSFetchRequest.
                break
            case .limit(_):
                print("CoreDataProvider: executing the 'limit' operation.")
                /// Set a 'fetchLimit' for a NSFetchRequest.
                break
            case .includesPropertyValues(_):
                print("CoreDataProvider: executing the 'includesPropertyValues' operation.")
                /// Set an 'includesPropertyValues' for a NSFetchRequest.
                break
            }
        }

        /// Execute a NSFetchRequest and return results.
        return []
    }
}


protocol DomainModel {
    /// The protocol groups domain models to the common interface
}

private struct User: DomainModel {
    let id: Int
    let age: Int
    let email: String
}


class BuilderRealWorld: XCTestCase {

    func testBuilderRealWorld() {
        print("Client: Start fetching data from Realm")
        clientCode(builder: RealmQueryBuilder<User>())

        print()

        print("Client: Start fetching data from CoreData")
        clientCode(builder: CoreDataQueryBuilder<User>())
    }

    fileprivate func clientCode(builder: BaseQueryBuilder<User>) {

        let results = builder.filter({ $0.age < 20 })
            .limit(1)
            .fetch()

        print("Client: I have fetched: " + String(results.count) + " records.")
    }
}
````