# iOS Interview Questions 
## Accessibility
###### Questions that cover making apps easier to use for everyone.

<details>
  <summary> 🤔 How much experience do you have testing with VoiceOver?</summary>
  <p>

 ✅ VoiceOver is a central part of Apple's accessibility system, to the point where if your app isn't accessible to VoiceOver it's probably not accessible to other accessibility systems in iOS. So, talk about your experience trying it out, how you make sure you've tested a UI thoroughly, any problems you've hit, and for bonus points mention the screen curtain!
  </p>
</details>
<details>
  <summary> 🤔 How would you explain Dynamic Type to a new iOS developer?</summary>
  <p>

  ✅ This is a sneaky question, because if you say “I don’t use it” or (worse) “I don’t know what it is”, it sort of means you don’t pay attention to accessibility or user preferences. Dynamic Type is a way of allowing the user to adjust their preferred size for all fonts in all apps, and it's surprisingly easy to use from both a developer and user perspective. SwiftUI even defaults to using it across the board!
  </p>
</details>
<details>
  <summary> 🤔 What are the main problems we need to solve when making accessible apps?</summary>
  <p>

  ✅ Try to give a range of answers: visual impairment, color blindness, touch problems, and audio problems are all good places to start, so give some specific examples of issues folks hit and how you solve them with Apple's accessibility tools.

  You should at the very least be able to talk about Dynamic Type confidently – why is it important, how does it adapt to user needs, and how do you use it in your apps?
  </p>
</details>
<details>
  <summary> 🤔 What accommodations have you added to apps to make them more accessible?</summary>
  <p>

  ✅ Hopefully you can think of a few examples where you've added icons alongside colors to accommodate folks with color blindness, or where you've added support for the Reduce Motion option, and so on.

  This really is about being specific: which changes were easier or harder to make and why?
  </p>
</details>

## Data
###### Questions dealing with data and data structures.

<details>
  <summary> 🤔 How is a dictionary different from an array?</summary>
  <p>

  ✅ It’s all down to how you access data: arrays must be accessed using the index of each element, whereas dictionaries can be accessed using something you define – strings are very common. Make sure and give practical examples of where each would be used.
  </p>
</details>
<details>
  <summary> 🤔 What are the main differences between classes and structs in Swift?
</summary>
  <p>

  ✅ Your answer ought to include a discussion of value types (like structs) and reference types (like classes), but also the fact that classes allow inheritance.

  For bonus points you could mention that classes have `deinit()` methods and structs do not.
  </p>
</details>
<details>
  <summary> 🤔 What are tuples and why are they useful?</summary>
  <p>

  ✅ Tuples are a bit like anonymous structs, and are helpful for returning multiple values from a method in a type-safe way, among other things. Make sure you go on to provide some explanation of where they might be useful, such as returning two values from an array.
  </p>
</details>
<details>
  <summary> 🤔 What does the Codable protocol do?</summary>
  <p>

  ✅ This protocol was introduced in Swift 4 to let us quickly and safely convert custom Swift types to and from JSON, XML, and similar.

  For bonus points talk about customization points such as key and date decoding strategies, the `CodingKey` protocol, and more, so that you're able to show you can handle a range of input and output styles.
  </p>
</details>
<details>
  <summary> 🤔 What is the difference between an array and a set?</summary>
  <p>

  ✅ This is a bit like computer science 101, so start by answering with the facts: sets can’t contain duplicates and are unordered, so lookup is significantly faster. Note: this might sound like a trivial question, but the "significantly faster" part is critical – sets can be thousands of times faster than arrays depending on how many elements they contain. If you can, go on to give specific examples of where a set would be a better idea than an array.
  </p>
</details>
<details>
  <summary> 🤔 What is the difference between the Float, Double, and CGFloat data types?</summary>
  <p>

  ✅ It’s a question of how many bits are used to store data: `Float` is always 32-bit, `Double` is always 64-bit, and `CGFloat` is either 32-bit or 64-bit depending on the device it runs on, but realistically it’s just 64-bit all the time.

  For bonus points, talk about how Swift 5.5 and onwards allows us to use `CGFloat` and `Double` interchangeably.
  </p>
</details>
<details>
  <summary> 🤔 What’s the importance of key decoding strategies when using Codable?</summary>
  <p>
  
  Give a specific answer first – “key decoding strategies let us handle difference between JSON keys and property names in our `Decodable` struct” – then provide some kind of practical sample. For example, you might say that it’s common for JSON keys to use `snake_case` for key names, whereas in Swift we prefer `camelCase`, so we need to use a key decoding strategy to convert between the two.
  </p>
</details>
<details>
  <summary> 🤔 When using arrays, what’s the difference between map() and compactMap()?</summary>
  <p>

  ✅ Remember to give practical examples as well as outlining the core differences. So, you might start by saying the `map()` transforms a sequence using a function we specify, whereas `compactMap()` does that same step but then unwraps its optionals and discards any nil values. For example, converting an array of strings into integers works better with `compactMap()`, because creating an `Int` from a `String` is failable.
  </p>
</details>
<details>
  <summary> 🤔 Why is immutability important?</summary>
  <p>

  ✅ Immutability is baked deep into Swift, and Xcode even warns if `var` was used when `let` was possible. It’s important because it’s like a programming contract: we’re saying This Thing Should Not Change, so if we try to change it the compiler will refuse.
  </p>
</details>
<details>
  <summary> 🤔 What are one-sided ranges and when would you use them?</summary>
  <p>

  ✅ As always, start with a simple definition that clarifies the difference between regular ranges, then provide a practical example.

  So, you might say that one-sided ranges are ranges where you don’t specify the start or end of the range, meaning that Swift will automatically make the range start from the start of the collection or the end of the collection. They are useful when you want to read from a certain position to the end of a collection, such as if you want to skip the first 10 users in an array.
  </p>
</details>
<details>
  <summary> 🤔 What does it mean when we say “strings are collections in Swift”?</summary>
  <p>

  ✅ This statement means that Swift’s `String` type conform to the `Collection` protocol, which allows us to loop over characters, count how long the string is, map the characters, select random characters, and more.

  For bonus points, move on to talk about the `Collection` protocol itself – how it means we have a consistent way to work with strings, arrays, sets, and more.
  </p>
</details>
<details>
  <summary> 🤔 What is a UUID, and when might you use it?</summary>
  <p>

  ✅ UUID stands for "universally unique identifier", which is a long string of hexadecimal numbers stored in a single type.

  UUIDs are helpful for ensuring some value is guaranteed to be unique, for example you might need a unique filename when saving something.

  For bonus points, perhaps explain why we call them universally unique – if you created 100 trillion UUIDs there's a one in a billion chance of generating a duplicate.
  </p>
</details>
<details>
  <summary> 🤔 What's the difference between a value type and a reference type?</summary>
  <p>

  ✅ The best way to frame this discussion is likely to be classes vs structs: an instance of a class can have multiple owners, but an instance of a struct cannot.

For bonus points mention that closures are also reference types, and the implications of that.
  </p>
</details>
<details>
  <summary> 🤔 When would you use Swift’s Result type?</summary>
  <p>

  ✅ Start with a brief introduction to what `Result` does, saying that it’s an enum encapsulating success and failure, both with associated values so you can attach extra information. I would then dive into the “when would you use it” part of the question – talking about asynchronous code is your best bet, particularly in comparison to how things like `URLSession` would often pass both a value and an error even when only one should exist at a time.

  If you’d like to go into more detail, more benefits of `Result` include being able to send the result of a function around as value to be handled at a later date, and also the ability to handle typed errors.
  </p>
</details>
<details>
  <summary> 🤔 What is type erasure and when would you use it?</summary>
  <p>

  ✅ Type erasure allows us to throw away some type information, for example to say that an array of strings is actually just `AnySequence` – it’s a sequence containing strings, but we don’t know exactly what kind of sequence.

  This is particularly useful when types are long and complex, which is often the case with Combine. So, rather than having a return type that is 500 characters long, we can just say `AnyPublisher<SomeType, Never>` – it’s a publisher that will provide `SomeType` and never throw an error, but we don’t care exactly what publisher it is.
  </p>
</details>

## Design patterns
###### Questions about design patterns, code architectures, and other programming approaches.

<details>
  <summary> 🤔 How would you explain delegates to a new Swift developer?</summary>
  <p>

  ✅ Delegation allows you to have one object act in place of another, for example your view controller might act as the data source for a table. The delegate pattern is huge in iOS, so try to pick a small, specific example such as `UITableViewDelegate` from UIKit – something you can dissect from memory. 
  </p>
</details>
<details>
  <summary> 🤔 Can you explain MVC, and how it's used on Apple's platforms?</summary>
  <p>

  ✅ MVC is an approach that advocates separating data (model) from presentation (view), with the two parts being managed by separate logic (a controller). In theory this separation should be as clear as possible, but for bonus points you should talk about how view controllers sometimes get bloated as code gets merged together into one big blob. 
  </p>
</details>
<details>
  <summary> 🤔 Can you explain MVVM, and how it might be used on Apple's platforms?</summary>
  <p>

  ✅ Start with the simple definition of Model (your data), View (your layout), and View Model (a way to store the state of your application independently from your UI), but make sure you give some time over to the slightly more nebulous parts – where does networking code go, for example? This is also a good place to bring up the importance of bindings to avoid lots of boilerplate, and that probably leads to SwiftUI. 
  </p>
</details>
<details>
  <summary> 🤔 How would you explain dependency injection to a junior developer?</summary>
  <p>

  ✅ Dependency injection is the practice of creating an object and tell it what data it should work with, rather than letting that object query its environment to find that data for itself. Although this goes against the OOP principle of encapsulation, it’s worth talking about the advantages – it allows for mocking data when testing, for example. 
  </p>
</details>
<details>
  <summary> 🤔 How would you explain protocol-oriented programming to a new Swift developer?</summary>
  <p>

  ✅ POP is a Swift buzzword, but don’t get carried away with the hype here: focus on why it’s different from OOP, and what benefits you think it has. You might want talk about horizontal vs vertical architectures here – larger codebases are likely to have sizable class hierarchies – but you could also talk about how POP is able to work with structs and enums as well as classes.
  </p>
</details>
<details>
  <summary> 🤔 What experience do you have of functional programming?</summary>
  <p>

  ✅ The best answer of course is to provide detailed explanations of what you've used and where, but as you go make sure and talk about what functional programming means – functions must be first-class types, you place an emphasis on pure functions, and so on.

  If you’re not sure where to start, the easiest answer is to list some small specifics: if you’ve used `map()`, `compactMap()`, `flatMap()`, `reduce()`, `filter()` and so on, that’s a good place to begin.
  </p>
</details>
<details>
  <summary> 🤔 Can you explain KVO, and how it's used on Apple's platforms?</summary>
  <p>

  ✅ KVO used to be helpful in UIKit to watch for changes on values that don’t have useful delegates – you can literally say "tell me when this value changes." Try to give at least one specific example, such as watching the page load progress on a `WKWebView`. If you’re exclusively using SwiftUI chances are you’ll struggle here. 
  </p>
</details>
<details>
  <summary> 🤔 Can you give some examples of where singletons might be a good idea?</summary>
  <p>

  ✅ It’s very unlikely you’ll join a company where singletons are used extensively, so feel free to say that broadly speaking singletons aren’t great. Once you’ve given up that proviso, perhaps mention that Apple uses them extensively – thinks like `UIApplication`, for example, are designed to exist only once. Finally, try to give a fresh example of your own, such as creating an app-wide logger.

  For bonus points, perhaps compare and contrast SwiftUI’s environment. 
  </p>
</details>
<details>
  <summary> 🤔 What are phantom types and when would you use them?</summary>
  <p>

  ✅ Phantom types are a type that doesn’t use at least one its generic parameters – they are declared with a generic parameter that isn’t used in their properties or methods.

  Even though we don’t use the generic type parameter, Swift does, which means it will treat two instances of our type as being incompatible if their generic type parameters are different. They aren’t used often, but when they are used they help the compiler enforce extra rules on our behalf – they make bad states impossible because the compiler will refuse to build our code.
  </p>
</details>

## Frameworks
###### Questions about Apple frameworks and APIs beyond UIKit and SwiftUI.
<details>
  <summary> 🤔 How does CloudKit differ from Core Data?</summary>
  <p>

 Although the two have many conceptual similarities, CloudKit is specifically designed to work remotely. Another key difference is that CloudKit lets you store data without worrying about your structure ahead of time, whereas Core Data requires that you define your structure up front.
  </p>
</details>
 <details>
  <summary> 🤔 How does SpriteKit differ from SceneKit?</summary>
  <p>

  ✅ Obviously one is for 2D drawing and the other is 3D, but you might use this chance to talk about how they both sit on top of Metal, and how you can mix the two if you want.

  For additional material, consider talking about commonanlities – they can both be used with ARKit, UIKit, and SwiftUI, for example.
  </p>
</details>
<details>
  <summary> 🤔 How much experience do you have using Core Data? Can you give examples?</summary>
  <p>

  ✅ Core Data is a huge and complex topic, but you should at least have tried it once. You might find it useful to talk about how `NSPersistentContainer` made Core Data easier to use from iOS 10 onwards, or compare and contrast Core Data and CloudKit.

  For a really great answer, talk about things that Core Data does well such as searching, sorting, and relationships, but also talk about places where Core Data struggles such as optionality and extensive stringly typed APIs.
  </p>
</details>
<details>
  <summary> 🤔 How much experience do you have using Core Graphics? Can you give examples?</summary>
  <p>

  ✅ Most developers have at least used Core Graphics for drawing basic shapes, but you might also have used it for text and resizing images. You should aim for at least a little experience, because this is one of the most important Apple frameworks.

  If you only have experience with drawing inside SwiftUI, at least talk about that rather than just saying "I don't know" – it all counts.
  </p>
</details>
<details>
  <summary> 🤔 What are the different ways of showing web content to users?</summary>
  <p>

  ✅ You don’t need to have named them all, but it certainly helps: `UIWebView`, `WKWebView`, `SFSafariViewController`, and calling `openURL()` on `UIApplication`. Don’t just list them off, though: at least mention that UIWebView is deprecated, but if you can you should also compare and contrast `WKWebView` and `SFSafariViewController`.
  </p>
</details>
<details>
  <summary> 🤔 What class would you use to list files in a directory?</summary>
  <p>

  ✅ Hopefully your answer was `FileManager`. If your interviewer looked like they wanted more, you might want to talk about sandboxing: important directories such as documents and caches, using App Groups to share data between targets in your app, and more.
  </p>
</details>
<details>
  <summary> 🤔 What is UserDefaults good for? What is UserDefaults not good for?</summary>
  <p>

  ✅ This should immediately have you thinking about speed, size, and security: `UserDefaults` is bad at large amounts of data because it slows your app load, it’s annoying for complex data types because of `NSCoding`, and a bad choice for information such as credit cards and passwords – recommend the keychain instead. If you’re using SwiftUI extensively you could mention `@AppStorage` here.
  </p>
</details>
<details>
  <summary> 🤔 What is the purpose of NotificationCenter?</summary>
  <p>

  ✅ Most people use this for receiving system messages, for example to be notified when they keyboard appears or disappears, but you can also use it to send your own messages inside your app. Once you’ve outlined the basics, try comparing it against delegates.
  </p>
</details>
<details>
  <summary> 🤔 What steps would you follow to make a network request?</summary>
  <p>

  ✅ There are so many ways of answering this (not least “use Alamofire”), but the main thing is to demonstrate that you know it needs to be asynchronous to avoid blocking the main thread. Don't forget to mention the need to push work back to the main thread when it's time to update the user interface.

  For bonus points, mention that this is the kind of work Combine just eats up.
  </p>
</details>
<details>
  <summary> 🤔 When would you use CGAffineTransform?</summary>
  <p>

  ✅ There are lots of ways of using these to manipulate the frame of a view, but an easy one is animation – you might make a view scale upwards, rotate, or grow larger over time for example.

  For bonus points, you might want to move on to discuss that affine scale transforms don't cause views to redraw at their larger size, which means that text is likely to appear fuzzy.
  </p>
</details>
<details>
  <summary> 🤔 How much experience do you have using Core Image? Can you give examples?</summary>
  <p>

  ✅ Some developers confuse Core Graphics and Core Image, which is a mistake – they are quite different. Core Image is used less often than Core Graphics, but is helpful for filtering images: blurring or sharpening, adjusting colors, and so on.

  For bonus points, talk about Core Image being able to apply multiple effects efficiently, and how it can also generate some kinds of images too.
  </p>
</details>
<details>
  <summary> 🤔 How much experience do you have using iBeacons? Can you give examples?</summary>
  <p>

  ✅ iBeacons were introduced way back in iOS 7, and have found mixed use – unless you’re applying for an iBeacon development job this is one you can probably skip with “I haven’t used them much, but I’m keen to learn!”

  Of course, if you do have experience then this is your time to shine: talk about major and minor identifiers, talk about positioning beacons overhead to avoid interference from people and devices, talk about ranging, and more.
  </p>
</details>
<details>
  <summary> 🤔 How much experience do you have using StoreKit? Can you give examples?
</summary>
  <p>

  ✅ Most apps use only a small slice of StoreKit, whether it's unlocking in-app purchases, displaying other apps to purchase, or asking users to review the app. Either way, have something to talk about – it's better to say you've at least tried one of its features than have nothing at all to show.
  </p>
</details>
<details>
  <summary> 🤔 How much experience do you have with GCD?</summary>
  <p>

  ✅ Most developers have used Grand Central Dispatch at some point, either explicitly or implicitly – here the interviewer is probably trying to figure out which it is. You can approach this directly using `DispatchQueue` if you want, but you might also want to consider `OperationQueue`.
  </p>
</details>
<details>
  <summary> 🤔 What class would you use to play a custom sound in your app?</summary>
  <p>

  ✅ An easy answer is `AVAudioPlayer`, as long as you're clear about keeping the object alive while its sound plays. If you were feeling more confident you could discuss the pros and cons of using `AudioServicesCreateSystemSoundID()` instead – it's a slightly odd API, but it definitely works.
  </p>
</details>
<details>
  <summary> 🤔 What experience do you have of NSAttributedString?</summary>
  <p>

  ✅ This is an incredibly useful class, so hopefully your answer isn’t “none”! Perhaps start by talking about how they are useful to add formatting like bold, italics, and color. You might also want to mention that they are great for hyperlinks, but for real bonus points mention that you can embed images inside them as well. 
  </p>
</details>
<details>
  <summary> 🤔 What is the purpose of GameplayKit?</summary>
  <p>

  ✅ The clue is in the name: GameplayKit contains lots of helpful classes for games, such as AI strategists, state machines, and pathfinding. However, there’s no reason its components must be limited just to games, because you can use them just as well in apps. 
  </p>
</details>
<details>
  <summary> 🤔 What is the purpose of ReplayKit?</summary>
  <p>

  ✅ ReplayKit is one of Apple’s more obscure frameworks, but if lets you record, save, and broadcast the user’s activity in your app. It's most commonly used in games, but you could easily frame this in terms of submitting error report videos from users. 
  </p>
</details>
<details>
  <summary> 🤔 When might you use NSSortDescriptor?</summary>
  <p>

  ✅ Start out with a simple definition of what `NSSortDescriptor` actually does: it lets us provide sorting instructions to a data store, e.g. "sort by name alphabetically".

  Once you've done that you should go on to mention that it's most commonly when used in Core Data to sort the data that got fetched, but it's also available in CloudKit.

  For bonus points, talk about how it can be a stringly typed API, or you can use key paths instead. 
  </p>
</details>
<details>
  <summary> 🤔 Can you name at least three different CALayer subclasses?</summary>
  <p>

  ✅ This is an intermediate to advanced question aimed at folks with UIKit experience. You could choose from `CAGradientLayer`, `CATiledLayer`, `CAEmitterLayer`, `CAShapeLayer`, and more – they are all quite popular on Apple's platforms.

  If I were you, I'd list off a few different subclasses, but then pick one and try to provide more detail on how it works and why it exists.
  </p>
</details>
<details>
  <summary> 🤔 What is the purpose of CADisplayLink?</summary>
  <p>

  ✅ This lets you attach code to the user interface drawing loop so that your code always gets called immediately after a frame has been drawn and you have maximum time available to you.

  For bonus points, try to compare it to a more naive solution such as `Timer`.
  </p>
</details>

## iOS
###### General questions about building for iOS itself, or UI questions that apply to both UIKit and SwiftUI.

<details>
  <summary> 🤔 How do you create your UI layouts – storyboards or in code?</summary>
  <p>

  ✅ Everyone is different, so be prepared to explain how you settled on your approach. You might want to talk about Auto Layout and stack views here, or perhaps some Auto Layout alternatives you've tried. Of course, if you exclusively use SwiftUI this ought to be an easy one to answer!
  </p>
</details>
<details>
  <summary> 🤔 How would you add a shadow to one of your views?
</summary>
  <p>

  ✅ In UIKit, all view layers have options for shadow opacity, radius, offset, color, and path. In SwiftUI, you can use the `shadow()` modifier. This would be a good time to mention to relative cost of dynamic shadows and how rasterizing layers in UIKit helps.
  </p>
</details>
<details>
  <summary> 🤔 How would you round the corners of one of your views?</summary>
  <p>

  ✅ If you’re using UIKit then you’d use the `cornerRadius` property of your view’s `layer` – something like myView.`layer.cornerRadius = 10` ought to be enough to start. If you’re using SwiftUI, then the `cornerRadius()` modifier is your friend.
  </p>
</details>
<details>
  <summary> 🤔 What are the advantages and disadvantages of SwiftUI compared to UIKit?</summary>
  <p>

  ✅ Try to be thoughtful here – coming down hard on one side rather than the other isn’t a good look, so instead try to think about what each framework does well and less well.

  For example, UIKit gives us endless customizability, for example, as well as access to almost the full range of iOS UI tools, but takes a lot more code to use and you need to handle all the state changes properly. On the other hand, SwiftUI gives us access to fewer iOS components, but takes less than a fifth of the amount of code to write and does a huge amount of extra work for us.
  </p>
</details>
<details>
  <summary> 🤔 What do you think is a sensible minimum iOS deployment target?</summary>
  <p>

  ✅ Unless you have specific needs, a safe answer is Apple’s: “the current version minus 1.” Note that e-commerce companies – i.e., companies that rely on users buying things through their app – are more likely to support a wider range of deployment targets, because even if only 5% of their users are on iOS n-2 that's enough to cause a significant revenue hit if they were lost.
  </p>
</details>
<details>
  <summary> 🤔 What features of recent iOS versions were you most excited to try?</summary>
  <p>

  ✅ This question is less about feature knowledge and more about your general excitement for iOS releases – if none of SwiftUI, widgets, SF Symbols, or App Clips interest you, you might be in the wrong career.

  I'd suggest a good approach here is to list a few broad things, but then pick one you really like and drill right into it.
  </p>
</details>
<details>
  <summary> 🤔 What kind of settings would you store in your Info.plist file?</summary>
  <p>

  ✅ The Info.plist file stores settings that must be available even when the app isn't running. You could talk about custom URLs, privacy permission messages, custom fonts, whether the app disables background running, and so on.

  For bonus points, consider this question: would you use Info.plist to store custom settings for your app, such as API end points?
  </p>
</details>
<details>
  <summary> 🤔 What is the purpose of size classes?</summary>
  <p>

  ✅ Size classes let you add extra layout configuration to your app so that your UI works well across different devices. For example, you might say that a stack view aligns its views horizontally in normal conditions, but vertically when constrained.

  For bonus points mention how important this is when working with split view and slide over!
  </p>
</details>
<details>
  <summary> 🤔 What happens when Color or UIColor has values outside 0 to 1?</summary>
  <p>

  ✅ In the old days values outside of 0 and 1 would be clamped (i.e., forced to 0 or 1) because they didn't mean anything, but wide color support means that is no longer the case – a red value beyond 1.0 is especially red, going into the Display P3 gamut.
  </p>
</details>

## Miscellaneous
###### Questions that cover how you interact with Apple, other developers, designers, and more.

<details>
  <summary> 🤔 Can you talk me through some interesting code you wrote recently?</summary>
  <p>

  ✅ Hopefully you can go straight to GitHub and pick an interesting project. If not, why not? Your projects don't need to be amazing, clever, or even popular, but if you literally have nothing to show you’re going to have a much harder job convincing companies to hire you.
  </p>
</details>
<details>
  <summary> 🤔 Do you have any favorite Swift newsletters or websites you read often?</summary>
  <p>

  ✅ Most employers will say it's important to be able to demonstrate that you’re committed to learning more about your craft. I subscribe to iOS Dev Weekly, Swift Weekly Brief, and This Week in Swift – all are interesting. Obviously I would hope you mention Hacking with Swift too, but I'm biased!
  </p>
</details>
<details>
  <summary> 🤔 How do you stay up to date with changes in Swift?</summary>
  <p>

  ✅ We develop in a fast-changing world, not least because Apple bump all their major versions every year. Be prepared to talk about books you read, sites you visit, newsletters you subscribe to, conferences you attend, and more – the more specific the better, because it shows you’re working hard to stay updated.
  </p>
</details>
<details>
  <summary> 🤔 How familiar are you with XCTest? Have you ever created UI tests?</summary>
  <p>

  ✅ Be prepared to talk about the challenges you’ve faced when designing tests, particularly when it comes to user interface tests. It’s a good idea to make sure you’re crystal clear on the differences between unit tests and integration tests. Tip: I’ve never a development team that was 100% happy with their iOS UI tests.
  </p>
</details>
<details>
  <summary> 🤔 How has Swift changed since it was first released in 2014?</summary>
  <p>

  ✅ This can either show how long you’ve been writing Swift, or it can show you have an interest in the language’s evolution. You might talk about the addition of `try`/`catch`, `guard`, and defer in Swift 2, the massive Cocoa renaming from Swift 3, the introduction of `Codable` in Swift 4, the changes for SwiftUI in Swift 5.1, or really whatever takes your interest.
  </p>
</details>
<details>
  <summary> 🤔 If you could have Apple add or improve one API, what would it be?</summary>
  <p>

  ✅ This is a personal choice, and is asked to see how creative or interesting your answer is. If it were me, I’d love to see either a handwriting detection API so that we could add handwriting support everywhere, or a weather API so that apps could integrate weather information in all sorts of places – imagine having a calendar app with weather forecasts built right in!
  </p>
</details>
<details>
  <summary> 🤔 What books would you recommend to someone who wants to learn Swift?</summary>
  <p>

  ✅ Obviously I’d recommend the complete Hacking with Swift series, but the point is that it gives you a chance to talk about how you learned Swift. You can always list Apple’s official Swift guide if you’re desperate. Note: Saying "I didn't use any books, I just worked hard" is a valid answer, but you should at least be aware that such an approach doesn't work for many people.
  </p>
</details>
<details>
  <summary> 🤔 What non-Apple apps do you think have particular good design?</summary>
  <p>

  ✅ This is a personal choice. I would probably talk about Airbnb and Duolingo, for example, because they have some really smooth transitions and a very harmonious layout. Don’t be afraid to throw a curveball and include a game – Monument Valley, for example, is visually pleasing.
  </p>
</details>
<details>
  <summary> 🤔 What open source projects have you contributed to?</summary>
  <p>

  ✅ This isn’t a requirement – far from it! – but again shows an eagerness to learn and an ability to participate. Don’t be afraid to list your own projects if they are public on GitHub.

  For bonus points, being able to say you've contributed to Swift itself is always likely to make the interviewer impressed, at least a little!
  </p>
</details>
<details>
  <summary> 🤔 What process do you take to perform code review?</summary>
  <p>

  ✅ This isn’t a coding question but that doesn’t mean it’s not important: are you able to take part in (and perhaps lead) meaningful code review sessions that are encouraging and useful? Code review is a skill that needs to be honed just like any other – what do you think is required for a good code review session? How important is it to have discussion on pull requests? Are there particular things you look for?
  </p>
</details>
<details>
  <summary> 🤔 Have you ever filed bugs with Apple? Can you walk me through some?</summary>
  <p>

  ✅ This is about demonstrating you’re a good citizen of the iOS community: you file bugs with Apple when you find them, and (just as important!) they are useful bugs with details and ideally a test case. If you file these properly, walking through shouldn’t be hard. Keep in mind that if you file bad bugs with Apple it suggests you'd be pretty bad at filing internal bugs for your own company too.
  </p>
</details>
<details>
  <summary> 🤔 Have you ever used test- or business-driven development?</summary>
  <p>

  ✅ Hopefully the answer is yes, even if only a little, but remember to give examples. Did you use TDD/BDD fully, or did you occasionally write tests later on? Did you use it as part of a larger team? Did you find that it helped or hindered you from building a great product?

  You might find it useful to talk about your approach specifically, because everyone is different.
  </p>
</details>
<details>
  <summary> 🤔 How do you think Swift compares to Objective-C?
</summary>
  <p>

  ✅ Swift is a much more modern programming language, so it has a lot going for it. You might want to mention optionality, tuples, value types, `Codable`, generics, among other things. However, don't get sucked into the trap of assuming the traffic is all one way: Objective-C has C and C++ compatibility, and compiles significantly faster.
  </p>
</details>
<details>
  <summary> 🤔 How familiar are you with Objective-C? Have you shipped any apps using it?</summary>
  <p>

  ✅ Although Objective-C is has largely lost its grip on the enterprise it’s still going to be a useful skill for some years yet, and if the company you're interviewing with has extensive Objective-C code then hopefully you can produce a strong answer here.

  Make sure and talk about how Swift and Objective-C interact using bridging headers – it's unlikely you'll join a job where you write new Objective-C, but you do at least need to know how to make Objective-C and Swift play well together.
  </p>
</details>
<details>
  <summary> 🤔 What experience do you have with the Swift Package Manager?</summary>
  <p>

  ✅ If you've used CocoaPods or Carthage instead of SPM, that's okay – it doesn’t really matter which one you personally use, as long as you’re able to discuss the importance of dependency management. If you have the knowledge, being able to compare and contrast the three options would likely go down well.
  </p>
</details>
<details>
  <summary> 🤔 What experience do you have working on macOS, tvOS, and watchOS?</summary>
  <p>

  ✅ Keep in mind that many company have significant investments in Apple computers – being able to make macOS apps for internal use can be a real boost. I would also suggest that saying you've dabbled in something like watchOS demonstrates curiosity and an ability innovate. If you’ve moved apps to the Mac using something like Catalyst that’s also worth discussing here, particularly if you’re able to compare it to SwiftUI.
  </p>
</details>
<details>
  <summary> 🤔 What is the purpose of code signing in Xcode?</summary>
  <p>

  ✅ I know code signing gets a lot of flak from developers because it can be quite annoying, but try to think about this from Apple’s perspective, in terms of verifying a developer is who they say they are, and also how provisioning profiles enable functionality.

  Once you're there, I would connect it to the importance of tight security on the App Store, because verifying developer identities is one of several steps towards shipping safe apps.
  </p>
</details>

## Performance
###### Questions about improving your apps to be faster, more efficient, less crashy, and similar.

<details>
  <summary> 🤔 What experience do you have working on macOS, tvOS, and watchOS?</summary>
  <p>

  ✅ Keep in mind that many company have significant investments in Apple computers – being able to make macOS apps for internal use can be a real boost. I would also suggest that saying you've dabbled in something like watchOS demonstrates curiosity and an ability innovate. If you’ve moved apps to the Mac using something like Catalyst that’s also worth discussing here, particularly if you’re able to compare it to SwiftUI.
  </p>
</details>
<details>
  <summary> 🤔 How would you identify and resolve a retain cycle?</summary>
  <p>

  ✅ The first step is identification – looking for a place where leaks happen, and it’s important to mention either Instruments or the Memory Graph Debugger here. Leaks don’t always means retain cycles (for example, unused caches are effectively leaks), but they are a good starting point. Once you’ve found a possible retain cycle, you need to decide which side of the cycle should be made weak rather than strong in order to resolve it.
  </p>
</details>
<details>
  <summary> 🤔 What is an efficient way to cache data in memory?</summary>
  <p>

  ✅ There are lots of ways of making caches, with the most humble being a simple dictionary, but whatever you choose you should be prepared to explain your choice and why you like it. Make sure and take into account how you remove data from the cache, either explicitly or to hit a memory quota.

  If you're comfortable talking about it, `NSCache` is definitely preferable over a simple dictionary because it automatically gets cleared by the system when memory is low.
  </p>
</details>
<details>
  <summary> 🤔 What steps do you take to identify and resolve battery life issues?</summary>
  <p>

  ✅ This is something so many developers don’t ever think about, so use this as your chance to shine: talk about optimizing drawing, batching network requests, and minimizing work when the user isn’t interacting with the app.

  Keep in mind that the battery settings app on iOS automatically shows which apps use the most battery life for a user, so having poor battery performance is very visible.
  </p>
</details>
<details>
  <summary> 🤔 What steps do you take to identify and resolve crashes?</summary>
  <p>

  ✅ Walk through your knowledge of debugging from the basics upwards. Do you use breakpoints? Do you use `assert()` or `precondition()`? Do you write to a log? Do you download crash logs from iTunes Connect?

  All these things help provide data points we can use to find and fix problems in our code, because once you know where the problem is it's usually(!) fairly straightforward to fix.
  </p>
</details>
<details>
  <summary> 🤔 How does Swift handle memory management?</summary>
  <p>

  ✅ Jump straight in with ARC – get to the point and focus on it, explaining about retain, release, and retain counts. If you want to also talk about `unowned` and `weak`, or perhaps reference counting for classes, this is also the place.

  For bonus points, talk about places that aren't automatic, such as using an autorelease pool inside tight loops.
  </p>
</details>
<details>
  <summary> 🤔 How would you explain ARC to a new iOS developer?</summary>
  <p>

  ✅ Automatic reference counting is a feature that Objective-C developers had to think about every day, but Swift developers mostly forget it's even there. Focus on why it saves developer time (less work) and what performance problems it might have (extra CPU time).
  </p>
</details>
<details>
  <summary> 🤔 What steps do you take to identify and resolve a memory leak?</summary>
  <p>

  ✅ Hopefully you have at least some experience with Instruments, so talk about persistent vs transient objects, talk about filtering for your custom data types, and so on. You should also discuss how you can be sure the leak is gone, for example if you push and pop the same view controller 10 times does the memory level remain constant?
  </p>
</details>
<details>
  <summary> 🤔 What steps do you take to identify and resolve performance issues?</summary>
  <p>

  ✅ This is a tricky question to answer because “performance” has many forms, so be prepared to adjust your answer as you talk based on interviewer feedback.

  If they mean graphical performance then you should probably talk about using the Core Animation instrument to identify slow drawing, but you should also consider venturing into the cost of Auto Layout in things like table view cells where lots of work happens quickly.

  If they mean code performance then perhaps talk about stack traces, retain cycles, unnecessary caches, and similar – again make sure and bring Instruments in.

  And then there's network performance, where you might talk about things such as batching requests to reduce battery wastage or using compression to save bandwidth.
  </p>
</details>

## Security
###### Questions about how you store and send data.

<details>
  <summary> 🤔 How much experience do you have using Face ID or Touch ID? Can you give examples?</summary>
  <p>

  ✅ If you’re applying for a job at any company that has secure user data, biometric authentication is almost certainly involved somewhere. Fortunately, it’s not hard to learn!

  For bonus points mention the need for a password backup in case Face ID/Touch ID fails, but if you're generally stuck here a good approach might be just to say "I haven't used it before, but I have used the keychain for secure storage."
  </p>
</details>
<details>
  <summary> 🤔 How would you explain App Transport Security to a new iOS developer?</summary>
  <p>

  ✅ This is your chance to demonstrate your security knowledge: why is HTTPS so important, and in what specific cases might you need to opt out? It also an opportunity to demonstrate your awareness of Apple's app review guidelines, which require secure transmission of user data.
  </p>
</details>
<details>
  <summary> 🤔 What experience do you have of using the keychain?</summary>
  <p>

  ✅ The keychain is the smartest way to store secure data on Apple's platforms. If you don’t have any experience of using it at least be prepared to discuss why it’s important for storing sensitive information – `UserDefaults` is the wrong choice!
  </p>
</details>
<details>
  <summary> 🤔 How would you calculate the secure hash value for some data?</summary>
  <p>

  ✅ Secure hash values use something like SHA-3, which is not the kind of code you'd want to write yourself. Instead, the best approach here is to mention something like Apple's CryptoKit framework, which can do hashing and encryption quickly, efficiently, and correctly.
  </p>
</details>

## Swift
###### Questions about the Swift language itself.

<details>
  <summary> 🤔 How would you compare two tuples to ensure their values are identical?</summary>
  <p>

  ✅ Swift provides automatic tuple comparison ever since Swift 2.2 – you can just use `==` to compare tuples item by item.

  For bonus points you could mention that tuple comparison does not guarantee that both tuples use the same element names.
  </p>
</details>
<details>
  <summary> 🤔 How would you explain operator overloading to a junior developer?</summary>
  <p>

  ✅ Operator overloading sounds like a complex topic, but really you can and should boil this answer down as small as you can: it allows us to use the same `+` operator with multiple types, such as integers, strings, doubles, and more. If you want to talk about examples of custom operator overloading, perhaps think about multiplying a `CGPoint` or something else that’s easy to use in practice.
  </p>
</details>
<details>
  <summary> 🤔 How would you explain protocols to a new Swift developer?</summary>
  <p>

  ✅ Protocols are used extensively in Apple development, so try to pick a small, specific example such as `UITableViewDataSource` – something you can dissect from memory. If you’re coming from SwiftUI, perhaps talk about `View` or `ObservableObject`.
  </p>
</details>
<details>
  <summary> 🤔 In which situations do Swift functions not need a return keyword?</summary>
  <p>

  ✅ There are three: when the function isn’t supposed to return a value, when it is supposed to return a value but you’ve used something like `fatalError()` to skip that requirement, and when it returns a value using a single expression. That second case is useful when you have placeholder functions you haven’t implemented yet, or have created an abstract class where child classes will override your erroring implementations.
  </p>
</details>
<details>
  <summary> 🤔 What are property observers?</summary>
  <p>

  ✅ Property observers let you run code before or after a property is modified. Try to give a practical example here: “if you have a score property that holds an integer, you might attach a `didSet` observer so that it updates a label whenever the score changes.”

  For bonus points mention the major problem they have: you might think that adding 1 to an integer is a nice and quick operation, but if you accidentally attach a complex property observer then it could cause havoc.
  </p>
</details>
<details>
  <summary> 🤔 What are raw strings?</summary>
  <p>

  ✅ There’s a simple formula here, taking you from broad to specific: explain how you make raw strings, explain how you’d use them, then provide any extra information such as how they handle string interpolation.

  So, you might start by saying that you make them by placing a hash before and after your string quotes, they are used for strings where lots of instances of quote marks or backslashes appear in order to make the string easier to read (bonus points for mentioning regular expressions!), and then finish up by saying that string interpolation must also use a hash in order to become active.

If you want to really show off your knowledge, perhaps mention that you can use more than one hash if you need to.
  </p>
</details>
<details>
  <summary> 🤔 What does the #error compiler directive do?</summary>
  <p>

  ✅ Answering this isn’t hard (“it forces the compiler to emit an error using a message we specify”), but please make sure you follow up with at least one example. So, maybe you’re shipping some sample code where users need to enter an API key otherwise it won’t work, so you use `#error` next to the API key line saying “fill in your API key before continuing.” Similarly, you might use `#error` alongside an OS check to say that your code isn’t compatible with tvOS, for example.
  </p>
</details>
<details>
  <summary> 🤔 What does the #if swift syntax do?</summary>
  <p>

  ✅ The syntax was added in Swift 2.2 to support compile-time version checking, meaning that you can mix two different Swift versions in one file without errors because only one will be used at a time.

  Make sure and give an example, such as Swift 5.4 supporting colors such as `.red.opacity(0.5)` whereas older versions need to use `Color.red.opacity(0.5)`.
  </p>
</details>
<details>
  <summary> 🤔 What does the assert() function do?</summary>
  <p>

  ✅ This evaluates some code and causes your app to crash if the result is false. This is actually helpful because the check only happens in debug mode – it lets you make sure your code does what you think it does.

  For bonus points, give practical examples of where you’re using it in your current code.
  </p>
</details>
<details>
  <summary> 🤔 What does the canImport() compiler condition do?</summary>
  <p>

  ✅ You should get straight to the point and say that `canImport()` returns true if a module such as UIKit can be imported, then provide a practical example such as it allowing us to write code that does one thing using UIKit on iOS, and another thing using AppKit on macOS.
  </p>
</details>
<details>
  <summary> 🤔 What does the CaseIterable protocol do?</summary>
  <p>

  ✅ Go straight in and answer that this protocol allows us to loop over all cases in an enum, but then follow up with a practical example – you might have a word search generation algorithm that has enum cases for all possible directions you can place a word, so you loop over them all to try and find a valid spot for each word.
  </p>
</details>
<details>
  <summary> 🤔 What does the final keyword do, and why would you want to use it?</summary>
  <p>

  ✅ Think about the underlying goal here: why would you want to say “you cannot inherit from this class”? Is that a good idea? There are good reasons for using it – sometimes a class does something very precise, and you really don’t want users to override important parts of your code.
  </p>
</details>
<details>
  <summary> 🤔 What does the nil coalescing operator do?</summary>
  <p>

 The nil coalescing operator (`??`) lets you provide a default value to use if an optional value is empty. I would probably add that optionals are a really useful language feature in Swift, but if I can ditch them – if I can get a `String` rather than a `String?` – then I do, and that's where nil coalescing is really useful.
  </p>
</details>
<details>
  <summary> 🤔 What is the difference between if let and guard let?</summary>
  <p>

  ✅ Both check and unwrap optionals, but `guard` forces an early return if its check fails – your code will literally not compile unless you exit the scope. Furthermore, any variables that `guard` unwraps stay in scope after the `guard` block, whereas with `if let` the variables are available only inside the scope.
  </p>
</details>
<details>
  <summary> 🤔 What is the difference between try, try?, and try! in Swift?</summary>
  <p>

  ✅ A regular `try` requires you to catch errors, `try?` converts the throwing call into an optional where you’ll get back `nil` on failure, and `try!` will cause your app to crash if the throwing call fails. All three have their uses, so don’t dismiss one out of hand.
  </p>
</details>
<details>
  <summary> 🤔 What problem does optional chaining solve?</summary>
  <p>

  ✅ Optional chaining makes our code concise because we can write multiple optional calls on one line but have execution skip over the line if any of the optionals are missing.

  For bonus points, talk about this also works with things like `try?` and `as?`.
  </p>
</details>
<details>
  <summary> 🤔 What's the difference between String? and String! in Swift?</summary>
  <p>

  ✅ All Swift developers should be able to nail this one: `String?` marks an optional string and `String!` marks an implicitly unwrapped string.

  For bonus points, go further: when would you use one rather than the other? If you're stuck, consider talking about how Interface Builder creates its outlets, and why it does it that way.
  </p>
</details>
<details>
  <summary> 🤔 When would you use the guard keyword in Swift?</summary>
  <p>

  ✅ It’s most commonly used to check preconditions are satisfied, but you should also discuss how variables it creates remain in scope after the `guard` block, and also how it enforces you exit the scope if the precondition fails.

  For bonus points, mention that you can use `guard` inside any kind of block as long as you escape afterwards – you can use it inside a loop for example.
  </p>
</details>
<details>
  <summary> 🤔 Apart from the built-in ones, can you give an example of property wrappers?</summary>
  <p>

  ✅ If it weren’t for the built-in restriction, this would be easy to answer with `@State`, `@EnvironmentObject`, and more, but with that restriction in place you need to be more creative – what real example can you think of? For example, a wrapper to make sure numbers are never negative, or strings are never empty, or perhaps arrays that silently stay sorted.
  </p>
</details>
<details>
  <summary> 🤔 Can you give useful examples of enum associated values?</summary>
  <p>

  ✅ Enum associated values let us attach one or more extra pieces of data to enum cases – that much is easy enough. However, the key word here is “useful”, which means you need to provide an example that is even vaguely real world.

  For instance, you might describe a weather enum that lists sunny, windy, and rainy as cases, but has an associated value for cloudy so that you can store the cloud coverage. Or you might describe types of houses, with the number of bedrooms being an associated integer.

  It doesn't really matter what example you choose, because the point is to show you understand why they are useful outside of a textbook!
  </p>
</details>
<details>
  <summary> 🤔 How would you explain closures to a new Swift developer?</summary>
  <p>

  ✅ Closures are easy to begin with, but make sure you talk about capturing of values, capture lists (`unowned` vs `weak`), and why they are actually useful compared to other approaches. It’s possible your interviewer is looking for a broader discussion of functions as first-class types in Swift, so if they seem to be waiting for you to continue that might be a good angle to go down.
  </p>
</details>
<details>
  <summary> 🤔 What are generics and why are they useful?</summary>
  <p>

  ✅ Generics allow us to create types and functions that can be adapted to use different kinds of data for extra flexibility and safety.

  Generics are most commonly used to add type safety to collections – even if you don't create them yourself much, you certainly use them because `[String]` is really `Array<String>` under the hood.

  For bonus points, talk about how protocols use associated types rather than generics to achieve a similar result.
  </p>
</details>
<details>
  <summary> 🤔 What are multi-pattern catch clauses?</summary>
  <p>

  ✅ Swift’s `catch` blocks let us catch several types of errors, specified using comma separation – hence the “multi-pattern” clauses. They are useful as a way of grouping error handling code together: if the error thrown was A or B then take the same action, but if it was C or D take some other action.
  </p>
</details>
<details>
  <summary> 🤔 What does the @main attribute do?</summary>
  <p>

  ✅ This attribute marks the point where your program starts to run. When using this attribute with one of your types need to implement a `main()` method to handle setting up your program, but if you’re using SwiftUI the `App` protocol provides that for you.
  </p>
</details>
<details>
  <summary> 🤔 What does the #available syntax do?</summary>
  <p>

  ✅ This syntax was introduced in Swift 2.0 to allow run-time version checking of features by OS version number. It allows you to target an older version of iOS while selectively limiting features available only in newer iOS versions, all carefully checked by the compiler to avoid human error.
  </p>
</details>
<details>
  <summary> 🤔 What is a variadic function?</summary>
  <p>

  ✅ Variadic functions accept any number of parameters. Swift writes them using `...`, and we’re handed the parameters as an array. Again, try to give an example – something like `print()` is a good place to start.

  For bonus points, you could add that Swift 5.4 and later allow multiple variadic parameters.
  </p>
</details>
<details>
  <summary> 🤔 What is the difference between weak and unowned?</summary>
  <p>

  ✅ As well as explaining that `weak` becomes a regular optional whereas `unowned` is an implicitly unwrapped optional, be prepared to discuss the safety differences. Do you have a preference? If so, why? Can you think of places where `unowned` must be used?
  </p>
</details>
<details>
  <summary> 🤔 What is the difference between an escaping closure and a non-escaping closure?</summary>
  <p>

  ✅ This is an advanced language question and comes down to one thing: if you pass a closure as a function parameter and that closure might be called after the function has returned (e.g. after a delay), it must be marked as escaping.

  For bonus points, talk about why Swift uses non-escaping closures by default – they remove a small performance hit caused by Swift needing to keep escaping closures alive in memory after the function finishes.
  </p>
</details>
<details>
  <summary> 🤔 What is the difference between an extension and a protocol extension?</summary>
  <p>

  ✅ Extensions add functionality to specific data types, e.g. `Int`. Protocol extensions add functionality to protocols, for example all kinds of integers at the same time – `Int`, `Int8`, `UInt64`, and so on.

  For bonus points you could go on to talk about how protocol extensions enable protocol-oriented programming.
  </p>
</details>
<details>
  <summary> 🤔 When would you use the defer keyword in Swift?</summary>
  <p>

  ✅ Go straight in with a clear explanation before adding more detail: this is used to delay a piece of work until a function ends, similar to how `try`/`finally` works in some other languages.

  Once you've done that, be sure to give a specific example such as saving a file once everything has been written – any kind of work that absolutely must take place.

  For bonus points, mention how you can defer multiple pieces of work, and they get executed in reverse as Swift unwinds the `defer` stack.
  </p>
</details>
<details>
  <summary> 🤔 How would you explain key paths to a new Swift developer?</summary>
  <p>

  ✅ Start with the simplest explanation then you can, then try to follow up with practical examples.

  For example, you might start by saying that key paths let us refer to a property in a type rather than the exact value of that property in one particular instance. You could then follow up with examples such as using the `map()` method with a key path, to convert an array of users into an array of strings containing just their names, or perhaps using `filter()` to filter an array based on which items have a Boolean property set to true.
  </p>
</details>
<details>
  <summary> 🤔 What are conditional conformances?</summary>
  <p>

  ✅ You should already know that protocol conformances allow us to say that one type conforms to a protocol such as `Hashable` or `Equatable`, but this question is asking about conditional conformances – conforming to a protocol only if a condition is true. Make sure and give a practical example, such as `Array` conforming to a `Purchaseable` protocol only if it contains elements that also conform to `Purchaseable`.
  </p>
</details>
<details>
  <summary> 🤔 What are opaque return types?</summary>
  <p>

  ✅ Whenever you see `some` in a return type, it’s an opaque return type – when you want to specify that some kind of type will be returned, but you don’t want to say what.

  It’s important that you try to explain the difference between an opaque return type and returning a protocol, because in the latter your returned value can be absolutely anything whereas in the former the compiler knows what data was actually returned even if you don’t get access to that.

  For bonus points, talk about how SwiftUI uses `@ViewBuilder` to silently allow us to return different view types from a view body.
  </p>
</details>
<details>
  <summary> 🤔 What are result builders and when are they used in Swift?</summary>
  <p>

  ✅ This is an advanced question, so take your time. Start with a basic definition: result builders allow us to create a new value step by step by passing in a sequence of our choosing.

  Next, follow up with a specific example – I’d suggest that SwiftUI is the easiest one here, because when we have a `VStack` with a variety of views inside Swift silently groups them together into an internal `TupleView` type so that they can be stored as a single child of the `VStack` – it turns a sequence of views into a single view.
  </p>
</details>
<details>
  <summary> 🤔 What does the targetEnvironment() compiler condition do?</summary>
  <p>

  ✅ Get straight to the point and say it allows us to compile one set of code for the simulator, and another set of code for physical devices. Make sure and follow up with a practical example, such as a game that uses Core Motion to handle tilting movement on a real device, whereas on the simulator you need to tap the screen to simulate motion.
  </p>
</details>
<details>
  <summary> 🤔 What is the difference between self and Self?</summary>
  <p>

  ✅ Almost every Swift developer uses `self` regularly, but the question here requires to distinguish between that and the capitalized version. Start with `self`, which refers to the current object your code is running inside, then move on to `Self`, which refers to the current type your code is running inside. You can remember this by looking at the capital letter: we name our types using a capital first letter, so `Self` refers to a type.
  </p>
</details>
<details>
  <summary> 🤔 When would you use @autoclosure?</summary>
  <p>

  ✅ There are a few ways you could tackle this, but I would recommend either talking about the `&&` operator or the `assert() `function – something you use regularly, and so feel comfortable talking about in detail.

  First, start with a simple definition: `@autoclosure` silently turns a function’s parameter into a closure so that it can be executed on demand rather than immediately. Now, pick a specific example such as `assert()` and explain why it’s used – the autoclosure behavior here ensures our assertion doesn’t happen in release mode, so it won’t have a performance impact when we ship apps to the App Store.
  </p>
</details>

## SwiftUI
###### Questions about building apps with SwiftUI.

 <details>
  <summary> 🤔 How would you explain SwiftUI’s environment to a new developer?</summary>
  <p>

  ✅ I would suggest you start off nice and broad, and say that the environment acts a bit like a singleton manager – you place objects in there and share them in many places. But then you want to dive into the details a little more, perhaps saying that actually you can subdivide the environment if you want, allowing some views to have different environment objects.

  I would recommend you try to mention how the environment differs from just injecting an `ObservableObject` instance in an initializer.
  </p>
</details>
<details>
  <summary> 🤔 What does the @Published property wrapper do?</summary>
  <p>

  ✅ As with many questions, the best answer here starts with a simple definition (when used inside an `ObservableObject` an `@Published` property will automatically send out change notifications when its value changes), then diving into a practical example. So, you might say that a class you’re using in SwiftUI has an array of todo list items, and when that array changes the UI should update – a simple, real-world use for `@Published`.
  </p>
</details>
<details>
  <summary> 🤔 What does the @State property wrapper do?</summary>
  <p>

  ✅ Remember to start with a basic definition first, then provide a practical example. Here, that means saying the `@State` allows us to mutate a value that belongs to a struct without using mutating methods. When it comes to a practical example, almost any kind of value-type SwiftUI binding is good, such as storing text in a `TextField`.
  </p>
</details>
<details>
  <summary> 🤔 What's the difference between a view's initializer and onAppear()?</summary>
  <p>

  ✅ Using `init()` and `onAppear()` both let us run some code early in a view's lifecycle, however it's important to understand the difference between them.

  SwiftUI creates all its view structs immediately, even creating destination views for navigation links, which means that initializers are run immediately and that's probably not something you want. In comparison, code placed in an `onAppear()` modifier is called only when the view is shown for the first time, so it's the right place to do complex work.
  </p>
</details>
<details>
  <summary> 🤔 When would you use @StateObject versus @ObservedObject?</summary>
  <p>

  ✅ I would recommend you start by making the similarities and differences clear, then sum up by answering the question directly. So, you would say that both of these property wrappers monitor an observable object for changes, and refresh SwiftUI views when changes happen. However, `@StateObject` is used when you create an object for the first time and want to retain ownership of it, whereas `@ObservableObject` is used in other places where you pass the object and does not retain ownership.
  </p>
</details>
<details>
  <summary> 🤔 How can an observable object announce changes to SwiftUI?</summary>
  <p>

  ✅ There are two primary ways this is done: using the `@Published` property wrapper, or by calling `objectWillChange.send()` directly.

  Try to provide examples of when one is preferable over the other, such as saying that you might use `@Published` by default, switching over to `objectWillChange.send()` for times when you need more fine-grained control.
  </p>
</details>
<details>
  <summary> 🤔 How would you create programmatic navigation in SwiftUI?</summary>
  <p>

  ✅ SwiftUI makes simple navigation as easy as it should be, but programmatic navigation is trickier because you need to declare all your states up front.

  If you want to talk about tags for `NavigationLink` views you can, but I would say the important thing here is to think about why it's important – handling deep links from Spotlight or widgets are both good places where you need to navigate programmatically.
  </p>
</details>
<details>
  <summary> 🤔 What is the purpose of the ButtonStyle protocol?</summary>
  <p>

  ✅ SwiftUI provides several built-in button styles depending on which platform you're targetting, and the `ButtonStyle` protocol allows us to create new button styles that can be reused across our apps to get consistent designs.

  For bonus points, compare and contrast `ButtonStyle` with `PrimitiveButtonStyle`.
  </p>
</details>
<details>
  <summary> 🤔 When would you use GeometryReader?</summary>
  <p>

  ✅ Start with the simplest answer and work your way up: `GeometryReader` allows us to read the size and location of a view, which means we can create proportional layouts or create adaptive modifiers that change their values as a view moves around the screen.

  For bonus points you might want to add that `GeometryReader` is frequently over-used.
  </p>
</details>
<details>
  <summary> 🤔 Why does SwiftUI use structs for views?</summary>
  <p>

  ✅ Start with the easiest answer, then work your way up: structs are used because they are much simpler and much more efficient than classes. Once you've nailed the basics, go on to discuss why this matters – SwiftUI is free to recreate your view structs whenever and as often as it wants, so performance needs to be good.
  </p>
</details>