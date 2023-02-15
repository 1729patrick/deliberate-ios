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

  How is a dictionary different from an array?
  What are the main differences between classes and structs in Swift?
  What are tuples and why are they useful?
  What does the Codable protocol do?
  What is the difference between an array and a set?
  What is the difference between the Float, Double, and CGFloat data types?
  What’s the importance of key decoding strategies when using Codable?
  When using arrays, what’s the difference between map() and compactMap()?
  Why is immutability important?
  What are one-sided ranges and when would you use them?
  What does it mean when we say “strings are collections in Swift”?
  What is a UUID, and when might you use it?
  What's the difference between a value type and a reference type?
  When would you use Swift’s Result type?
  What is type erasure and when would you use it?


## Design patterns
Questions about design patterns, code architectures, and other programming approaches.

  How would you explain delegates to a new Swift developer?
  Can you explain MVC, and how it's used on Apple's platforms?
  Can you explain MVVM, and how it might be used on Apple's platforms?
  How would you explain dependency injection to a junior developer?
  How would you explain protocol-oriented programming to a new Swift developer?
  What experience do you have of functional programming?
  Can you explain KVO, and how it's used on Apple's platforms?
  Can you give some examples of where singletons might be a good idea?
  What are phantom types and when would you use them?
  

## Frameworks
Questions about Apple frameworks and APIs beyond UIKit and SwiftUI.
  How does CloudKit differ from Core Data?
  How does SpriteKit differ from SceneKit?
  How much experience do you have using Core Data? Can you give examples?
  How much experience do you have using Core Graphics? Can you give examples?
  What are the different ways of showing web content to users?
  What class would you use to list files in a directory?
  What is UserDefaults good for? What is UserDefaults not good for?
  What is the purpose of NotificationCenter?
  What steps would you follow to make a network request?
  When would you use CGAffineTransform?
  How much experience do you have using Core Image? Can you give examples?
  How much experience do you have using iBeacons? Can you give examples?
  How much experience do you have using StoreKit? Can you give examples?
  How much experience do you have with GCD?
  What class would you use to play a custom sound in your app?
  What experience do you have of NSAttributedString?
  What is the purpose of GameplayKit?
  What is the purpose of ReplayKit?
  When might you use NSSortDescriptor?
  Can you name at least three different CALayer subclasses?
  What is the purpose of CADisplayLink?


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