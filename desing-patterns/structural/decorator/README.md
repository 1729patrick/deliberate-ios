# Decorator
**Usage examples:** The Decorator is pretty standard in Swift code, especially in code related to streams.

**Identification:** Decorator can be recognized by creation methods or constructors that accept objects of the same class or interface as a current class.

**Complexity:** 2/3
**Popularity:** 2/3

## Intent

Decorator is a structural design pattern that lets you attach new behaviors to objects by placing these objects inside special wrapper objects that contain the behaviors.

![Decorator design pattern](https://refactoring.guru/images/patterns/content/decorator/decorator-2x.png)
## Problem

Imagine that you’re working on a notification library which lets other programs notify their users about important events.

The initial version of the library was based on the Notifier class that had only a few fields, a constructor and a single send method. The method could accept a message argument from a client and send the message to a list of emails that were passed to the notifier via its constructor. A third-party app which acted as a client was supposed to create and configure the notifier object once, and then use it each time something important happened.

![Structure of the library before applying the Decorator pattern](https://refactoring.guru/images/patterns/diagrams/decorator/problem1-en-2x.png)

A program could use the notifier class to send notifications about important events to a predefined set of emails.
At some point, you realize that users of the library expect more than just email notifications. Many of them would like to receive an SMS about critical issues. Others would like to be notified on Facebook and, of course, the corporate users would love to get Slack notifications.

![Structure of the library after implementing other notification types](https://refactoring.guru/images/patterns/diagrams/decorator/problem2-2x.png)
Each notification type is implemented as a notifier’s subclass.

How hard can that be? You extended the Notifier class and put the additional notification methods into new subclasses. Now the client was supposed to instantiate the desired notification class and use it for all further notifications.

But then someone reasonably asked you, “Why can’t you use several notification types at once? If your house is on fire, you’d probably want to be informed through every channel.”

You tried to address that problem by creating special subclasses which combined several notification methods within one class. However, it quickly became apparent that this approach would bloat the code immensely, not only the library code but the client code as well.


![Structure of the library after creating class combinations](https://refactoring.guru/images/patterns/diagrams/decorator/problem3-2x.png)
Combinatorial explosion of subclasses.

You have to find some other way to structure notifications classes so that their number won’t accidentally break some Guinness record.

## Solution

Extending a class is the first thing that comes to mind when you need to alter an object’s behavior. However, inheritance has several serious caveats that you need to be aware of.

Inheritance is static. You can’t alter the behavior of an existing object at runtime. You can only replace the whole object with another one that’s created from a different subclass.
Subclasses can have just one parent class. In most languages, inheritance doesn’t let a class inherit behaviors of multiple classes at the same time.
One of the ways to overcome these caveats is by using Aggregation or Composition  instead of Inheritance. Both of the alternatives work almost the same way: one object has a reference to another and delegates it some work, whereas with inheritance, the object itself is able to do that work, inheriting the behavior from its superclass.

With this new approach you can easily substitute the linked “helper” object with another, changing the behavior of the container at runtime. An object can use the behavior of various classes, having references to multiple objects and delegating them all kinds of work. Aggregation/composition is the key principle behind many design patterns, including Decorator. On that note, let’s return to the pattern discussion.

![Inheritance vs. Aggregation](https://refactoring.guru/images/patterns/diagrams/decorator/solution1-en-2x.png)
Inheritance vs. Aggregation

“Wrapper” is the alternative nickname for the Decorator pattern that clearly expresses the main idea of the pattern. A wrapper is an object that can be linked with some target object. The wrapper contains the same set of methods as the target and delegates to it all requests it receives. However, the wrapper may alter the result by doing something either before or after it passes the request to the target.

When does a simple wrapper become the real decorator? As I mentioned, the wrapper implements the same interface as the wrapped object. That’s why from the client’s perspective these objects are identical. Make the wrapper’s reference field accept any object that follows that interface. This will let you cover an object in multiple wrappers, adding the combined behavior of all the wrappers to it.

In our notifications example, let’s leave the simple email notification behavior inside the base Notifier class, but turn all other notification methods into decorators.

![The solution with the Decorator pattern](https://refactoring.guru/images/patterns/diagrams/decorator/solution2-2x.png)
Various notification methods become decorators.

The client code would need to wrap a basic notifier object into a set of decorators that match the client’s preferences. The resulting objects will be structured as a stack.

![Apps might configure complex stacks of notification decorators](https://refactoring.guru/images/patterns/diagrams/decorator/solution3-en-2x.png)
Apps might configure complex stacks of notification decorators.

The last decorator in the stack would be the object that the client actually works with. Since all decorators implement the same interface as the base notifier, the rest of the client code won’t care whether it works with the “pure” notifier object or the decorated one.

We could apply the same approach to other behaviors such as formatting messages or composing the recipient list. The client can decorate the object with any custom decorators, as long as they follow the same interface as the others.

## Structure!

[Structure of the Decorator design pattern](https://refactoring.guru/images/patterns/diagrams/decorator/structure-2x.png)

The Component declares the common interface for both wrappers and wrapped objects.

Concrete Component is a class of objects being wrapped. It defines the basic behavior, which can be altered by decorators.

The Base Decorator class has a field for referencing a wrapped object. The field’s type should be declared as the component interface so it can contain both concrete components and decorators. The base decorator delegates all operations to the wrapped object.

Concrete Decorators define extra behaviors that can be added to components dynamically. Concrete decorators override methods of the base decorator and execute their behavior either before or after calling the parent method.

The Client can wrap components in multiple layers of decorators, as long as it works with all objects via the component interface.

## Applicability

Use the Decorator pattern when you need to be able to assign extra behaviors to objects at runtime without breaking the code that uses these objects.

The Decorator lets you structure your business logic into layers, create a decorator for each layer and compose objects with various combinations of this logic at runtime. The client code can treat all these objects in the same way, since they all follow a common interface.

Use the pattern when it’s awkward or not possible to extend an object’s behavior using inheritance.

Many programming languages have the final keyword that can be used to prevent further extension of a class. For a final class, the only way to reuse the existing behavior would be to wrap the class with your own wrapper, using the Decorator pattern.

## How to Implement

1. Make sure your business domain can be represented as a primary component with multiple optional layers over it.

2. Figure out what methods are common to both the primary component and the optional layers. Create a component interface and declare those methods there.

3. Create a concrete component class and define the base behavior in it.

4. Create a base decorator class. It should have a field for storing a reference to a wrapped object. The field should be declared with the component interface type to allow linking to concrete components as well as decorators. The base decorator must delegate all work to the wrapped object.

5. Make sure all classes implement the component interface.

6. Create concrete decorators by extending them from the base decorator. A concrete decorator must execute its behavior before or after the call to the parent method (which always delegates to the wrapped object).

7. The client code must be responsible for creating decorators and composing them in the way the client needs.

## Pros

1. You can extend an object’s behavior without making a new subclass.
2. You can add or remove responsibilities from an object at runtime.
3. You can combine several behaviors by wrapping an object into multiple decorators.
4. Single Responsibility Principle. You can divide a monolithic class that implements many possible variants of behavior into several smaller classes.

## Cons

1. It’s hard to remove a specific wrapper from the wrappers stack.
2. It’s hard to implement a decorator in such a way that its behavior doesn’t depend on the order in the decorators stack.
3. The initial configuration code of layers might look pretty ugly.

## Relations with Other Patterns

Adapter changes the interface of an existing object, while Decorator enhances an object without changing its interface. In addition, Decorator supports recursive composition, which isn’t possible when you use Adapter.

Adapter provides a different interface to the wrapped object, Proxy provides it with the same interface, and Decorator provides it with an enhanced interface.

Chain of Responsibility and Decorator have very similar class structures. Both patterns rely on recursive composition to pass the execution through a series of objects. However, there are several crucial differences.

The CoR handlers can execute arbitrary operations independently of each other. They can also stop passing the request further at any point. On the other hand, various Decorators can extend the object’s behavior while keeping it consistent with the base interface. In addition, decorators aren’t allowed to break the flow of the request.

Composite and Decorator have similar structure diagrams since both rely on recursive composition to organize an open-ended number of objects.

A Decorator is like a Composite but only has one child component. There’s another significant difference: Decorator adds additional responsibilities to the wrapped object, while Composite just “sums up” its children’s results.

However, the patterns can also cooperate: you can use Decorator to extend the behavior of a specific object in the Composite tree.

Designs that make heavy use of Composite and Decorator can often benefit from using Prototype. Applying the pattern lets you clone complex structures instead of re-constructing them from scratch.

Decorator lets you change the skin of an object, while Strategy lets you change the guts.

Decorator and Proxy have similar structures, but very different intents. Both patterns are built on the composition principle, where one object is supposed to delegate some of the work to another. The difference is that a Proxy usually manages the life cycle of its service object on its own, whereas the composition of Decorators is always controlled by the client.

## Decorator in Swift

Decorator is a structural pattern that allows adding new behaviors to objects dynamically by placing them inside special wrapper objects, called decorators.

Using decorators you can wrap objects countless number of times since both target objects and decorators follow the same interface. The resulting object will get a stacking behavior of all wrappers.

````
import UIKit
import XCTest


protocol ImageEditor: CustomStringConvertible {

    func apply() -> UIImage
}

class ImageDecorator: ImageEditor {

    private var editor: ImageEditor

    required init(_ editor: ImageEditor) {
        self.editor = editor
    }

    func apply() -> UIImage {
        print(editor.description + " applies changes")
        return editor.apply()
    }

    var description: String {
        return "ImageDecorator"
    }
}

extension UIImage: ImageEditor {

    func apply() -> UIImage {
        return self
    }

    open override var description: String {
        return "Image"
    }
}



class BaseFilter: ImageDecorator {

    fileprivate var filter: CIFilter?

    init(editor: ImageEditor, filterName: String) {
        self.filter = CIFilter(name: filterName)
        super.init(editor)
    }

    required init(_ editor: ImageEditor) {
        super.init(editor)
    }

    override func apply() -> UIImage {

        let image = super.apply()
        let context = CIContext(options: nil)

        filter?.setValue(CIImage(image: image), forKey: kCIInputImageKey)

        guard let output = filter?.outputImage else { return image }
        guard let coreImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        return UIImage(cgImage: coreImage)
    }

    override var description: String {
        return "BaseFilter"
    }
}

class BlurFilter: BaseFilter {

    required init(_ editor: ImageEditor) {
        super.init(editor: editor, filterName: "CIGaussianBlur")
    }

    func update(radius: Double) {
        filter?.setValue(radius, forKey: "inputRadius")
    }

    override var description: String {
        return "BlurFilter"
    }
}

class ColorFilter: BaseFilter {

    required init(_ editor: ImageEditor) {
        super.init(editor: editor, filterName: "CIColorControls")
    }

    func update(saturation: Double) {
        filter?.setValue(saturation, forKey: "inputSaturation")
    }

    func update(brightness: Double) {
        filter?.setValue(brightness, forKey: "inputBrightness")
    }

    func update(contrast: Double) {
        filter?.setValue(contrast, forKey: "inputContrast")
    }

    override var description: String {
        return "ColorFilter"
    }
}

class Resizer: ImageDecorator {

    private var xScale: CGFloat = 0
    private var yScale: CGFloat = 0
    private var hasAlpha = false

    convenience init(_ editor: ImageEditor, xScale: CGFloat = 0, yScale: CGFloat = 0, hasAlpha: Bool = false) {
        self.init(editor)
        self.xScale = xScale
        self.yScale = yScale
        self.hasAlpha = hasAlpha
    }

    required init(_ editor: ImageEditor) {
        super.init(editor)
    }

    override func apply() -> UIImage {

        let image = super.apply()

        let size = image.size.applying(CGAffineTransform(scaleX: xScale, y: yScale))

        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage ?? image
    }

    override var description: String {
        return "Resizer"
    }
}


class DecoratorRealWorld: XCTestCase {

    func testDecoratorRealWorld() {

        let image = loadImage()

        print("Client: set up an editors stack")
        let resizer = Resizer(image, xScale: 0.2, yScale: 0.2)

        let blurFilter = BlurFilter(resizer)
        blurFilter.update(radius: 2)

        let colorFilter = ColorFilter(blurFilter)
        colorFilter.update(contrast: 0.53)
        colorFilter.update(brightness: 0.12)
        colorFilter.update(saturation: 4)

        clientCode(editor: colorFilter)
    }

    func clientCode(editor: ImageEditor) {
        let image = editor.apply()
        /// Note. You can stop an execution in Xcode to see an image preview.
        print("Client: all changes have been applied for \(image)")
    }
}

private extension DecoratorRealWorld {

    func loadImage() -> UIImage {

        let urlString = "https:// refactoring.guru/images/content-public/logos/logo-new-3x.png"

        /// Note:
        /// Do not download images the following way in a production code.

        guard let url = URL(string: urlString) else {
            fatalError("Please enter a valid URL")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Cannot load an image")
        }

        guard let image = UIImage(data: data) else {
            fatalError("Cannot create an image from data")
        }
        return image
    }
}
````