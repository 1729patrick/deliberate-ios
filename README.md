# iOS Interview Questions 
## Accessibility
Questions that cover making apps easier to use for everyone.

<details>
  <summary>How much experience do you have testing with VoiceOver?</summary>
  <p>

  VoiceOver is a central part of Apple's accessibility system, to the point where if your app isn't accessible to VoiceOver it's probably not accessible to other accessibility systems in iOS. So, talk about your experience trying it out, how you make sure you've tested a UI thoroughly, any problems you've hit, and for bonus points mention the screen curtain!
  </p>
</details>

<details>
  <summary>How would you explain Dynamic Type to a new iOS developer?</summary>
  <p>

  This is a sneaky question, because if you say “I don’t use it” or (worse) “I don’t know what it is”, it sort of means you don’t pay attention to accessibility or user preferences. Dynamic Type is a way of allowing the user to adjust their preferred size for all fonts in all apps, and it's surprisingly easy to use from both a developer and user perspective. SwiftUI even defaults to using it across the board!
  </p>
</details>

<details>
  <summary>What are the main problems we need to solve when making accessible apps?</summary>
  <p>

  Try to give a range of answers: visual impairment, color blindness, touch problems, and audio problems are all good places to start, so give some specific examples of issues folks hit and how you solve them with Apple's accessibility tools.

  You should at the very least be able to talk about Dynamic Type confidently – why is it important, how does it adapt to user needs, and how do you use it in your apps?
  </p>
</details>

<details>
  <summary>What accommodations have you added to apps to make them more accessible?</summary>
  <p>

  Hopefully you can think of a few examples where you've added icons alongside colors to accommodate folks with color blindness, or where you've added support for the Reduce Motion option, and so on.

  This really is about being specific: which changes were easier or harder to make and why?
  </p>
</details>

## Data
Questions dealing with data and data structures.

<details>
  <summary>How is a dictionary different from an array?</summary>
  <p>

  It’s all down to how you access data: arrays must be accessed using the index of each element, whereas dictionaries can be accessed using something you define – strings are very common. Make sure and give practical examples of where each would be used.
  </p>
</details>

<details>
  <summary>What are the main differences between classes and structs in Swift?
</summary>
  <p>

  Your answer ought to include a discussion of value types (like structs) and reference types (like classes), but also the fact that classes allow inheritance.

  For bonus points you could mention that classes have `deinit()` methods and structs do not.
  </p>
</details>

<details>
  <summary>What are tuples and why are they useful?</summary>
  <p>

  Tuples are a bit like anonymous structs, and are helpful for returning multiple values from a method in a type-safe way, among other things. Make sure you go on to provide some explanation of where they might be useful, such as returning two values from an array.
  </p>
</details>

<details>
  <summary>What does the Codable protocol do?</summary>
  <p>

  This protocol was introduced in Swift 4 to let us quickly and safely convert custom Swift types to and from JSON, XML, and similar.

  For bonus points talk about customization points such as key and date decoding strategies, the `CodingKey` protocol, and more, so that you're able to show you can handle a range of input and output styles.
  </p>
</details>

<details>
  <summary>What is the difference between an array and a set?</summary>
  <p>

  This is a bit like computer science 101, so start by answering with the facts: sets can’t contain duplicates and are unordered, so lookup is significantly faster. Note: this might sound like a trivial question, but the "significantly faster" part is critical – sets can be thousands of times faster than arrays depending on how many elements they contain. If you can, go on to give specific examples of where a set would be a better idea than an array.
  </p>
</details>

<details>
  <summary>What is the difference between the Float, Double, and CGFloat data types?</summary>
  <p>

  It’s a question of how many bits are used to store data: `Float` is always 32-bit, `Double` is always 64-bit, and `CGFloat` is either 32-bit or 64-bit depending on the device it runs on, but realistically it’s just 64-bit all the time.

  For bonus points, talk about how Swift 5.5 and onwards allows us to use `CGFloat` and `Double` interchangeably.
  </p>
</details>

<details>
  <summary>What’s the importance of key decoding strategies when using Codable?</summary>
  <p>
  
  Give a specific answer first – “key decoding strategies let us handle difference between JSON keys and property names in our `Decodable` struct” – then provide some kind of practical sample. For example, you might say that it’s common for JSON keys to use `snake_case` for key names, whereas in Swift we prefer `camelCase`, so we need to use a key decoding strategy to convert between the two.
  </p>
</details>

<details>
  <summary>When using arrays, what’s the difference between map() and compactMap()?</summary>
  <p>

  Remember to give practical examples as well as outlining the core differences. So, you might start by saying the `map()` transforms a sequence using a function we specify, whereas `compactMap()` does that same step but then unwraps its optionals and discards any nil values. For example, converting an array of strings into integers works better with `compactMap()`, because creating an `Int` from a `String` is failable.
  </p>
</details>

<details>
  <summary>Why is immutability important?</summary>
  <p>

  Immutability is baked deep into Swift, and Xcode even warns if `var` was used when `let` was possible. It’s important because it’s like a programming contract: we’re saying This Thing Should Not Change, so if we try to change it the compiler will refuse.
  </p>
</details>

<details>
  <summary>What are one-sided ranges and when would you use them?</summary>
  <p>

  As always, start with a simple definition that clarifies the difference between regular ranges, then provide a practical example.

  So, you might say that one-sided ranges are ranges where you don’t specify the start or end of the range, meaning that Swift will automatically make the range start from the start of the collection or the end of the collection. They are useful when you want to read from a certain position to the end of a collection, such as if you want to skip the first 10 users in an array.
  </p>
</details>

<details>
  <summary>What does it mean when we say “strings are collections in Swift”?</summary>
  <p>

  This statement means that Swift’s `String` type conform to the `Collection` protocol, which allows us to loop over characters, count how long the string is, map the characters, select random characters, and more.

  For bonus points, move on to talk about the `Collection` protocol itself – how it means we have a consistent way to work with strings, arrays, sets, and more.
  </p>
</details>

<details>
  <summary>What is a UUID, and when might you use it?</summary>
  <p>

  UUID stands for "universally unique identifier", which is a long string of hexadecimal numbers stored in a single type.

  UUIDs are helpful for ensuring some value is guaranteed to be unique, for example you might need a unique filename when saving something.

  For bonus points, perhaps explain why we call them universally unique – if you created 100 trillion UUIDs there's a one in a billion chance of generating a duplicate.
  </p>
</details>

<details>
  <summary>What's the difference between a value type and a reference type?</summary>
  <p>

  The best way to frame this discussion is likely to be classes vs structs: an instance of a class can have multiple owners, but an instance of a struct cannot.

For bonus points mention that closures are also reference types, and the implications of that.
  </p>
</details>

<details>
  <summary>When would you use Swift’s Result type?</summary>
  <p>

  Start with a brief introduction to what `Result` does, saying that it’s an enum encapsulating success and failure, both with associated values so you can attach extra information. I would then dive into the “when would you use it” part of the question – talking about asynchronous code is your best bet, particularly in comparison to how things like `URLSession` would often pass both a value and an error even when only one should exist at a time.

  If you’d like to go into more detail, more benefits of `Result` include being able to send the result of a function around as value to be handled at a later date, and also the ability to handle typed errors.
  </p>
</details>

<details>
  <summary>What is type erasure and when would you use it?</summary>
  <p>

  Type erasure allows us to throw away some type information, for example to say that an array of strings is actually just `AnySequence` – it’s a sequence containing strings, but we don’t know exactly what kind of sequence.

  This is particularly useful when types are long and complex, which is often the case with Combine. So, rather than having a return type that is 500 characters long, we can just say `AnyPublisher<SomeType, Never>` – it’s a publisher that will provide `SomeType` and never throw an error, but we don’t care exactly what publisher it is.
  </p>
</details>


## Design patterns
Questions about design patterns, code architectures, and other programming approaches.

<details>
  <summary>How would you explain delegates to a new Swift developer?</summary>
  <p>

  Delegation allows you to have one object act in place of another, for example your view controller might act as the data source for a table. The delegate pattern is huge in iOS, so try to pick a small, specific example such as `UITableViewDelegate` from UIKit – something you can dissect from memory. 
  </p>
</details>
<details>
  <summary>Can you explain MVC, and how it's used on Apple's platforms?</summary>
  <p>

  MVC is an approach that advocates separating data (model) from presentation (view), with the two parts being managed by separate logic (a controller). In theory this separation should be as clear as possible, but for bonus points you should talk about how view controllers sometimes get bloated as code gets merged together into one big blob. 
  </p>
</details>
<details>
  <summary>Can you explain MVVM, and how it might be used on Apple's platforms?</summary>
  <p>

  Start with the simple definition of Model (your data), View (your layout), and View Model (a way to store the state of your application independently from your UI), but make sure you give some time over to the slightly more nebulous parts – where does networking code go, for example? This is also a good place to bring up the importance of bindings to avoid lots of boilerplate, and that probably leads to SwiftUI. 
  </p>
</details>
<details>
  <summary>How would you explain dependency injection to a junior developer?</summary>
  <p>

  Dependency injection is the practice of creating an object and tell it what data it should work with, rather than letting that object query its environment to find that data for itself. Although this goes against the OOP principle of encapsulation, it’s worth talking about the advantages – it allows for mocking data when testing, for example. 
  </p>
</details>
<details>
  <summary>How would you explain protocol-oriented programming to a new Swift developer?</summary>
  <p>

  POP is a Swift buzzword, but don’t get carried away with the hype here: focus on why it’s different from OOP, and what benefits you think it has. You might want talk about horizontal vs vertical architectures here – larger codebases are likely to have sizable class hierarchies – but you could also talk about how POP is able to work with structs and enums as well as classes.
  </p>
</details>
<details>
  <summary>What experience do you have of functional programming?</summary>
  <p>

  The best answer of course is to provide detailed explanations of what you've used and where, but as you go make sure and talk about what functional programming means – functions must be first-class types, you place an emphasis on pure functions, and so on.

  If you’re not sure where to start, the easiest answer is to list some small specifics: if you’ve used `map()`, `compactMap()`, `flatMap()`, `reduce()`, `filter()` and so on, that’s a good place to begin.
  </p>
</details>
<details>
  <summary>Can you explain KVO, and how it's used on Apple's platforms?</summary>
  <p>

  KVO used to be helpful in UIKit to watch for changes on values that don’t have useful delegates – you can literally say "tell me when this value changes." Try to give at least one specific example, such as watching the page load progress on a `WKWebView`. If you’re exclusively using SwiftUI chances are you’ll struggle here. 
  </p>
</details>
<details>
  <summary>Can you give some examples of where singletons might be a good idea?</summary>
  <p>

  It’s very unlikely you’ll join a company where singletons are used extensively, so feel free to say that broadly speaking singletons aren’t great. Once you’ve given up that proviso, perhaps mention that Apple uses them extensively – thinks like `UIApplication`, for example, are designed to exist only once. Finally, try to give a fresh example of your own, such as creating an app-wide logger.

  For bonus points, perhaps compare and contrast SwiftUI’s environment. 
  </p>
</details>
<details>
  <summary>What are phantom types and when would you use them?</summary>
  <p>

  Phantom types are a type that doesn’t use at least one its generic parameters – they are declared with a generic parameter that isn’t used in their properties or methods.

  Even though we don’t use the generic type parameter, Swift does, which means it will treat two instances of our type as being incompatible if their generic type parameters are different. They aren’t used often, but when they are used they help the compiler enforce extra rules on our behalf – they make bad states impossible because the compiler will refuse to build our code.
  </p>
</details>
  

## Frameworks
Questions about Apple frameworks and APIs beyond UIKit and SwiftUI.
<details>
  <summary>How does CloudKit differ from Core Data?</summary>
  <p>

 Although the two have many conceptual similarities, CloudKit is specifically designed to work remotely. Another key difference is that CloudKit lets you store data without worrying about your structure ahead of time, whereas Core Data requires that you define your structure up front.
  </p>
</details>
 <details>
  <summary>How does SpriteKit differ from SceneKit?</summary>
  <p>

  Obviously one is for 2D drawing and the other is 3D, but you might use this chance to talk about how they both sit on top of Metal, and how you can mix the two if you want.

  For additional material, consider talking about commonanlities – they can both be used with ARKit, UIKit, and SwiftUI, for example.
  </p>
</details>
<details>
  <summary>How much experience do you have using Core Data? Can you give examples?</summary>
  <p>

  Core Data is a huge and complex topic, but you should at least have tried it once. You might find it useful to talk about how `NSPersistentContainer` made Core Data easier to use from iOS 10 onwards, or compare and contrast Core Data and CloudKit.

  For a really great answer, talk about things that Core Data does well such as searching, sorting, and relationships, but also talk about places where Core Data struggles such as optionality and extensive stringly typed APIs.
  </p>
</details>
<details>
  <summary>How much experience do you have using Core Graphics? Can you give examples?</summary>
  <p>

  Most developers have at least used Core Graphics for drawing basic shapes, but you might also have used it for text and resizing images. You should aim for at least a little experience, because this is one of the most important Apple frameworks.

  If you only have experience with drawing inside SwiftUI, at least talk about that rather than just saying "I don't know" – it all counts.
  </p>
</details>
<details>
  <summary>What are the different ways of showing web content to users?</summary>
  <p>

  You don’t need to have named them all, but it certainly helps: `UIWebView`, `WKWebView`, `SFSafariViewController`, and calling `openURL()` on `UIApplication`. Don’t just list them off, though: at least mention that UIWebView is deprecated, but if you can you should also compare and contrast `WKWebView` and `SFSafariViewController`.
  </p>
</details>
<details>
  <summary>What class would you use to list files in a directory?</summary>
  <p>

  Hopefully your answer was `FileManager`. If your interviewer looked like they wanted more, you might want to talk about sandboxing: important directories such as documents and caches, using App Groups to share data between targets in your app, and more.
  </p>
</details>
<details>
  <summary>What is UserDefaults good for? What is UserDefaults not good for?</summary>
  <p>

  This should immediately have you thinking about speed, size, and security: `UserDefaults` is bad at large amounts of data because it slows your app load, it’s annoying for complex data types because of `NSCoding`, and a bad choice for information such as credit cards and passwords – recommend the keychain instead. If you’re using SwiftUI extensively you could mention `@AppStorage` here.
  </p>
</details>
<details>
  <summary>What is the purpose of NotificationCenter?</summary>
  <p>

  Most people use this for receiving system messages, for example to be notified when they keyboard appears or disappears, but you can also use it to send your own messages inside your app. Once you’ve outlined the basics, try comparing it against delegates.
  </p>
</details>
<details>
  <summary>What steps would you follow to make a network request?</summary>
  <p>

  There are so many ways of answering this (not least “use Alamofire”), but the main thing is to demonstrate that you know it needs to be asynchronous to avoid blocking the main thread. Don't forget to mention the need to push work back to the main thread when it's time to update the user interface.

  For bonus points, mention that this is the kind of work Combine just eats up.
  </p>
</details>
<details>
  <summary>When would you use CGAffineTransform?</summary>
  <p>

  There are lots of ways of using these to manipulate the frame of a view, but an easy one is animation – you might make a view scale upwards, rotate, or grow larger over time for example.

  For bonus points, you might want to move on to discuss that affine scale transforms don't cause views to redraw at their larger size, which means that text is likely to appear fuzzy.
  </p>
</details>
<details>
  <summary>How much experience do you have using Core Image? Can you give examples?</summary>
  <p>

  Some developers confuse Core Graphics and Core Image, which is a mistake – they are quite different. Core Image is used less often than Core Graphics, but is helpful for filtering images: blurring or sharpening, adjusting colors, and so on.

  For bonus points, talk about Core Image being able to apply multiple effects efficiently, and how it can also generate some kinds of images too.
  </p>
</details>
<details>
  <summary>How much experience do you have using iBeacons? Can you give examples?</summary>
  <p>

  iBeacons were introduced way back in iOS 7, and have found mixed use – unless you’re applying for an iBeacon development job this is one you can probably skip with “I haven’t used them much, but I’m keen to learn!”

  Of course, if you do have experience then this is your time to shine: talk about major and minor identifiers, talk about positioning beacons overhead to avoid interference from people and devices, talk about ranging, and more.
  </p>
</details>
<details>
  <summary>How much experience do you have using StoreKit? Can you give examples?
</summary>
  <p>

  Most apps use only a small slice of StoreKit, whether it's unlocking in-app purchases, displaying other apps to purchase, or asking users to review the app. Either way, have something to talk about – it's better to say you've at least tried one of its features than have nothing at all to show.
  </p>
</details>
<details>
  <summary>How much experience do you have with GCD?</summary>
  <p>

  Most developers have used Grand Central Dispatch at some point, either explicitly or implicitly – here the interviewer is probably trying to figure out which it is. You can approach this directly using `DispatchQueue` if you want, but you might also want to consider `OperationQueue`.
  </p>
</details>
<details>
  <summary>What class would you use to play a custom sound in your app?</summary>
  <p>

  An easy answer is `AVAudioPlayer`, as long as you're clear about keeping the object alive while its sound plays. If you were feeling more confident you could discuss the pros and cons of using `AudioServicesCreateSystemSoundID()` instead – it's a slightly odd API, but it definitely works.
  </p>
</details>
<details>
  <summary>What experience do you have of NSAttributedString?</summary>
  <p>

  This is an incredibly useful class, so hopefully your answer isn’t “none”! Perhaps start by talking about how they are useful to add formatting like bold, italics, and color. You might also want to mention that they are great for hyperlinks, but for real bonus points mention that you can embed images inside them as well. 
  </p>
</details>
<details>
  <summary>What is the purpose of GameplayKit?</summary>
  <p>

  The clue is in the name: GameplayKit contains lots of helpful classes for games, such as AI strategists, state machines, and pathfinding. However, there’s no reason its components must be limited just to games, because you can use them just as well in apps. 
  </p>
</details>
<details>
  <summary>What is the purpose of ReplayKit?</summary>
  <p>

  ReplayKit is one of Apple’s more obscure frameworks, but if lets you record, save, and broadcast the user’s activity in your app. It's most commonly used in games, but you could easily frame this in terms of submitting error report videos from users. 
  </p>
</details>
<details>
  <summary>When might you use NSSortDescriptor?</summary>
  <p>

  Start out with a simple definition of what `NSSortDescriptor` actually does: it lets us provide sorting instructions to a data store, e.g. "sort by name alphabetically".

  Once you've done that you should go on to mention that it's most commonly when used in Core Data to sort the data that got fetched, but it's also available in CloudKit.

  For bonus points, talk about how it can be a stringly typed API, or you can use key paths instead. 
  </p>
</details>
<details>
  <summary>Can you name at least three different CALayer subclasses?</summary>
  <p>

  This is an intermediate to advanced question aimed at folks with UIKit experience. You could choose from `CAGradientLayer`, `CATiledLayer`, `CAEmitterLayer`, `CAShapeLayer`, and more – they are all quite popular on Apple's platforms.

  If I were you, I'd list off a few different subclasses, but then pick one and try to provide more detail on how it works and why it exists.
  </p>
</details>
<details>
  <summary>What is the purpose of CADisplayLink?</summary>
  <p>

  This lets you attach code to the user interface drawing loop so that your code always gets called immediately after a frame has been drawn and you have maximum time available to you.

  For bonus points, try to compare it to a more naive solution such as `Timer`.
  </p>
</details>


## iOS
General questions about building for iOS itself, or UI questions that apply to both UIKit and SwiftUI.

  How do you create your UI layouts – storyboards or in code?
  How would you add a shadow to one of your views?
  How would you round the corners of one of your views?
  What are the advantages and disadvantages of SwiftUI compared to UIKit?
  What do you think is a sensible minimum iOS deployment target?
  What features of recent iOS versions were you most excited to try?
  What kind of settings would you store in your Info.plist file?
  What is the purpose of size classes?
  What happens when Color or UIColor has values outside 0 to 1?


## Miscellaneous
Questions that cover how you interact with Apple, other developers, designers, and more.

  Can you talk me through some interesting code you wrote recently?
  Do you have any favorite Swift newsletters or websites you read often?
  How do you stay up to date with changes in Swift?
  How familiar are you with XCTest? Have you ever created UI tests?
  How has Swift changed since it was first released in 2014?
  If you could have Apple add or improve one API, what would it be?
  What books would you recommend to someone who wants to learn Swift?
  What non-Apple apps do you think have particular good design?
  What open source projects have you contributed to?
  What process do you take to perform code review?
  Have you ever filed bugs with Apple? Can you walk me through some?
  Have you ever used test- or business-driven development?
  How do you think Swift compares to Objective-C?
  How familiar are you with Objective-C? Have you shipped any apps using it?
  What experience do you have with the Swift Package Manager?
  What experience do you have working on macOS, tvOS, and watchOS?
  What is the purpose of code signing in Xcode?


## Performance
Questions about improving your apps to be faster, more efficient, less crashy, and similar.

  How would you identify and resolve a retain cycle?
  What is an efficient way to cache data in memory?
  What steps do you take to identify and resolve battery life issues?
  What steps do you take to identify and resolve crashes?
  How does Swift handle memory management?
  How would you explain ARC to a new iOS developer?
  What steps do you take to identify and resolve a memory leak?
  What steps do you take to identify and resolve performance issues?


## Security
Questions about how you store and send data.

  How much experience do you have using Face ID or Touch ID? Can you give examples?
  How would you explain App Transport Security to a new iOS developer?
  What experience do you have of using the keychain?
  How would you calculate the secure hash value for some data?


## Swift
Questions about the Swift language itself.

  How would you compare two tuples to ensure their values are identical?
  How would you explain operator overloading to a junior developer?
  How would you explain protocols to a new Swift developer?
  In which situations do Swift functions not need a return keyword?
  What are property observers?
  What are raw strings?
  What does the #error compiler directive do?
  What does the #if swift syntax do?
  What does the assert() function do?
  What does the canImport() compiler condition do?
  What does the CaseIterable protocol do?
  What does the final keyword do, and why would you want to use it?
  What does the nil coalescing operator do?
  What is the difference between if let and guard let?
  What is the difference between try, try?, and try! in Swift?
  What problem does optional chaining solve?
  What's the difference between String? and String! in Swift?
  When would you use the guard keyword in Swift?
  Apart from the built-in ones, can you give an example of property wrappers?
  Can you give useful examples of enum associated values?
  How would you explain closures to a new Swift developer?
  What are generics and why are they useful?
  What are multi-pattern catch clauses?
  What does the @main attribute do?
  What does the #available syntax do?
  What is a variadic function?
  What is the difference between weak and unowned?
  What is the difference between an escaping closure and a non-escaping closure?
  What is the difference between an extension and a protocol extension?
  When would you use the defer keyword in Swift?
  How would you explain key paths to a new Swift developer?
  What are conditional conformances?
  What are opaque return types?
  What are result builders and when are they used in Swift?
  What does the targetEnvironment() compiler condition do?
  What is the difference between self and Self?
  When would you use @autoclosure?


## SwiftUI
Questions about building apps with SwiftUI.

  How would you explain SwiftUI’s environment to a new developer?
  What does the @Published property wrapper do?
  What does the @State property wrapper do?
  What's the difference between a view's initializer and onAppear()?
  When would you use @StateObject versus @ObservedObject?
  How can an observable object announce changes to SwiftUI?
  How would you create programmatic navigation in SwiftUI?
  What is the purpose of the ButtonStyle protocol?
  When would you use GeometryReader?
  Why does SwiftUI use structs for views?


## UIKit
Questions about building apps with UIKit.

  How are XIBs different from storyboards?
  How would you explain UIKit segues to a new iOS developer?
  What are storyboard identifiers for?
  What are the benefits of using child view controllers?
  What are the pros and cons of using viewWithTag()?
  What is the difference between @IBOutlet and @IBAction?
  What is the difference between a UIImage and a UIImageView?
  What is the difference between aspect fill and aspect fit when displaying an image?
  What is the purpose of UIActivityViewController?
  What is the purpose of UIVisualEffectView?
  What is the purpose of reuse identifiers for table view cells?
  When would you choose to use a collection view rather than a table view?
  Which parts of UIKit are you least familiar with?
  How does a view's intrinsic content size aid in Auto Layout?
  What is the function of anchors in Auto Layout?
  What is the purpose of IBDesignable?
  What is the purpose of UIMenuController?