# Storing preferences efficiently
Apple’s UserDefaults system lets us store small amounts of user data for our app, which might sound simple but it’s deceptively powerful. In this article I’ll show you the correct way to create initial preferences, how to share preferences across applications, how to synchronize data with iCloud, and why this is a case where property wrappers probably aren’t a good solution.

# Setting initial preferences
Any app that stores preferences will need default values for those preferences, and although UserDefaults does provide default values they are unlikely to be helpful. For example, bool(forKey:) returns true if the saved value was true, false if the saved value was false, but also false if there was no saved value at all – you can’t distinguish between there being a saved value set to false and there not being a saved value at all.

When I first learned to build iOS apps, I would write code like this:

```
func loadSettings() {
    let defaults = UserDefaults.standard

    if defaults.bool(forKey: "SettingsSaved") == false {
        defaults.set(true, forKey: "SettingsSaved")
        defaults.set("standard", forKey: "ReadingMode")
        defaults.set(0, forKey: "HighScore")
    }
}
```

That would check whether a known key is false, and if so set it to be true, then set our other default values as the same time. That worked well enough, but it has the potential to cause problems – not least if another thread tried to read settings first.

There’s a better way, and it’s baked right into the system. It’s called register(defaults:) and takes a [String: Any] dictionary of all the default values you want to have, like this:

```
UserDefaults.standard.register(defaults: [
    "ReadingMode": "standard",
    "HighScore": 0
])
```

Apart from just being less code, this approach has two other advantages: it won’t ever overwrite any actual values you have saved using those keys, and it never gets written to disk, so you can call it as often as you need and even change your mind over time without it becoming permanent.

Of course, the fact that these defaults are written to disk does mean you need to call register(defaults:) on every app launch, so make sure and put this somewhere obvious that gets run on every app launch.

# Sharing across apps and extensions
Apple lets us share defaults data between apps by using an app group, but in practice this wasn’t used so often. However, app groups are now becoming increasingly important as a way to share app data between different parts of your app – the main app, the Siri integration, the home screen action, and more.

From the perspective of iOS, each of these different parts are miniature binaries in their own right, which means different defaults settings. Of course, from our perspective that’s usually not something we want, because it means our app can end up with weird inconsistencies – some data available from the home screen, other data available through Siri, and so on.

So, Apple gives us a technology called App Groups. To get started with this, go to your target settings and choose Signing & Capabilities. Now press the “+ Capability” button and select App Groups, then press the + button underneath the list of your existing groups.

All App Group names should start with “group.”, so you should see that part pre-filled for you. After that, a bundle-style reverse domain name format should be used, so I might use “group.com.hackingwithswift.importantproject” for example. Once that’s done, make sure the box next to your new group is checked, and you’re all set.

When it comes to actually sharing data, the key difference is that you should not rely on UserDefaults.standard to read or write values – that will always write to the private data area assigned to the current extension, rather than your shared app group that all components can write to.

Instead, you want to use the UserDefaults(suiteName:) initializer to get access to your shared data area, like this:

```
guard let defaults = UserDefaults(suiteName: "group.com.hackingwithswift.userdefaults") else { return }
```

Once you have that, all the reading and writing code is the same.

That’s all there is to this API, but personally I find it a bit problematic – any stringly typed APIs are unwelcome in my code, and the thought of having to scatter a shared identifier around in several places doesn’t sit well for me.

So, if you intend to use app groups I recommend you create one Swift file that is shared across your targets, then give it code like this:

```
extension UserDefaults {
    static var shared: UserDefaults {
        guard let defaults = UserDefaults(suiteName: "group.YOUR_GROUP_IDENTIFIER_HERE") else {
            return UserDefaults.standard
        }

        return defaults
    }
}
```

This way you never need to deal with optionality, and you don’t run the risk of accidentally mistyping your suite name. If you’re feeling particularly brave, you could even replace the else block with a call to fatal error.

Tip: If you want to work with more than one UserDefaults instance at a time, create your standard one first then call addSuite(named:) on it to add your group.

# Synchronizing with iCloud
UserDefaults is great for storing data, but if you want that same data to work across several devices you need to turn to NSUbiquitousKeyValueStore. This gives us key-value data store for up to 1024 keys or 1MB, whichever is reached first, and it works more or less like UserDefaults.

If you want to try it out, first go to Signing & Capabilities for your app target, then add iCloud. When Xcode has resolved any signing issues, check the box “Key-value Storage” underneath iCloud, and you’re good to go.

Saving values to the iCloud key-value store is almost identical to UserDefaults:

```
NSUbiquitousKeyValueStore.default.set("Paul", forKey: "username")
```

Similarly, reading values back out is the same:

```
let username = NSUbiquitousKeyValueStore.default.string(forKey: "username") ?? "Anonymous"
```

So, it isn’t hard. However, I do think it’s a bit annoying: we already have to read and write values with UserDefaults, why do we also need to write them separately to iCloud?

The answer is that we don’t – we can absolutely write some code to make the two synchronize automatically.

Start by making a new class called CloudDefaults, giving it two properties: a shared static instance so it acts as a singleton, and an ignoreLocalChanges Boolean, so we don’t try to synchronize changes that have already been synchronized:

```
final class CloudDefaults {
    static let shared = CloudDefaults()
    private var ignoreLocalChanges = false
}
```

As it’s a singleton, we’ll need a private initializer in there so that only our shared instance can be used:

```
private init() { }
```

When an instance of the class starts up we’re going to monitor two notification names from NotificationCenter, and if the singleton ever gets destroyed we’re going to stop watching them. The two notifications we care about are for when the iCloud key-value store received a remote change, and when UserDefaults received a change, but when starting we’re also going to ask iCloud to synchronize our values so any changes that happened while the app wasn’t running get pulled in.

```
deinit {
    NotificationCenter.default.removeObserver(self)
}

func start() {
    NotificationCenter.default.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default, queue: .main, using: updateLocal)

    NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main, using: updateRemote)

    NSUbiquitousKeyValueStore.default.synchronize()
}
```

Tip: The iCloud notification will only fire on remote changes – changes that come from iCloud, not your local device.

We haven’t written the updateLocal and updateRemote methods, but we’re going to do that next. This will read through all the values in the appropriate source dictionary (e.g. UserDefaults if we are syncing to iCloud), and send each value over with the same key.

Although the basic concept is simple, there are two extra complexities.

First, when the iCloud key-value store changes remotely, we’ll be notified and can update UserDefaults. But if we then update UserDefaults then our other change observer – UserDefaults.didChangeNotification – will fire, and send those values back to iCloud for no reason.

This is where the ignoreLocalChanges property comes in: when synchronizing from iCloud, we need to ignore local changes before copying across the data, and then stop ignoring them after. Then inside updateRemote() we can check that Boolean to make sure we aren’t doing any extra work.

Second, Apple hides all sorts of data in both UserDefaults and NSUbiquitousKeyValueStore, and if we don’t specifically filter them then we’ll be uploading and downloading all sorts of junk. If you don’t mind that then it’s not a problem, but a better idea is to give your keys some sort of prefix that allows them to be identified uniquely as something you care about – something you want to be synchronized. So, in my code here we’re going to look specifically for keys that start with “sync-“, and only synchronize those.

Add these two methods now:

```
private func updateRemote(note: Notification) {
    guard ignoreLocalChanges == false else { return }

    for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
        guard key.hasPrefix("sync-") else { continue }
        print("Updating remote value of \(key) to \(value)")
        NSUbiquitousKeyValueStore.default.set(value, forKey: key)
    }
}

private func updateLocal(note: Notification) {
    ignoreLocalChanges = true

    for (key, value) in NSUbiquitousKeyValueStore.default.dictionaryRepresentation {
        guard key.hasPrefix("sync-") else { continue }
        print("Updating local value of \(key) to \(value)")
        UserDefaults.standard.set(value, forKey: key)
    }

    ignoreLocalChanges = false
}
```

And that’s the class done!

To put it into action, add this line somewhere as your app starts, such as in your app delegate’s didFinishLaunchingWithOptions method:

```
CloudDefaults.shared.start()
```

That will register the observers and synchronize initial settings, but after that all changes should synchronize neatly!

# Wrapping default properties
There’s one thing I want to mention briefly, because if I don’t there’s a good chance you’ll think I’ve just forgotten about it.

The Swift Evolution proposal for property wrappers gives an interesting example of using property wrappers with UserDefaults. It looks like this:

```
@propertyWrapper struct UserDefault<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
```

With that in place, you can now use it like this:

```
@UserDefault(key: "username", defaultValue: "Anonymous") var username
```

Since Swift 5.1 shipped, many people have written blog posts about this approach, often without even crediting the Swift Evolution proposal. But while I understand why folks want to pursue this approach, it’s also something I wouldn’t include in my own projects for a handful of reasons:

1. It’s still stringly typed. If you really wanted to proceed down this path you should at the very least create enums cases or similar.
2. There’s no indication of whether that value is shared across many places or not. (Spoiler: it almost certainly is shared, so different parts of your program can fight over the value)
3. It ignores the register(defaults:) system entirely, and now you’re scattering your default values through the system rather than keeping them centralized.

So, I’ve shown you the code, but I’m just doubtful that it’s a good idea as things stand. For things to improve, I’d want to write code like this:

```
@UserDefault var username = "Anonymous"
```

That would (in my fantasyland of things that property wrappers don’t actually support right now!) automatically use the name of the current struct plus the property name as the UserDefault key, e.g. ContentView.username, and use the = Anonymous part as a call to register(defaults:). (Yes, you can call register(defaults:) multiple times and they just combine.

This approach – if it were ever possible – would stop various parts of our app from sharing data by accident, would eliminate strings from keys entirely, and let us take advantage of register(defaults:). It’s still not perfect because I don’t particularly like having default values scattered everywhere, but it’s a moot point because it isn’t supported in Swift right now!

# Challenges
If you’d like to continue applying what you learned in this tutorial, here are some challenges for you to try:

1. Make our CloudDefaults class have a customizable prefix for its properties that defaults to “sync-”, so it’s easier to change it to something that suits your project.
2. Write an extension for UserDefaults that lets us define store values as enum cases rather than strings. If you’re not sure how to start with this, I’ve included a suggestion below.
I don’t want you to read my solution by accident, so I’m just writing this here so you can’t see it by accident.

Because that would be really annoying.

Still here?

Okay, here’s a suggestion to get you started:

```
extension UserDefaults {
    enum AppKeys: String {
        case name, emailAddress
    }

    func setValue(_ value: String, forKey key: AppKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
}
```