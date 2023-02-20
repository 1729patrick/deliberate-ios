# First steps
The first part of any modern macOS command-line app is to get Swift Argument Parser installed, which is Apple’s open source package for giving command-line apps the ability to read options from the user. To add this, go to the File menu and choose Add Packages, then from the list of packages that is shown choose Apple Swift Packages then swift-argument-parser. Finally, click Add Package to download it from GitHub, then click Add Package again to install it into your Xcode project.

Xcode’s default Command Line Tool template is a bit old-school in that it expects us to write loose code directly into main.swift, known as “top-level code”. That used to be pretty common in early Swift, but these days it’s better to use the `@main` attribute instead so that we control our program’s entry point.

In order to switch over to a modern project, I’d like you to rename main.swift to App.swift, which disables the top-level code magic. You should then also add the following import to the top of the file, so we can start building our app:

```
import ArgumentParser
```

And now for the important part: Swift Argument Parser expects an `@main` type that conforms to the `ParsableCommand` protocol. That protocol gives Argument Parser the ability to “bootstrap” our program – the ability for it to scan for input from the user, and print help information as needed. It defines a default `run()` method that handles launching our app, but in practice that’s something you want to replace to do your actual work.

Replace your existing code in App.swift with this:

```
@main
struct App: ParsableCommand {
    func run() {
        print("Hello from Swift Argument Parser!")
    }
}
```

Tip: The `@main` attribute tells Swift this is the type that should be used when our program is run from the command line.

You can run the app from Xcode if you want, but a better idea is to go to the Product menu and choose Show Build Folder in Finder so you can see where your finished application is. If you select that, then browse into the Products > Debug directory, you should see “JSONTidy” file with the type “Unix Executable File”. That’s our program!

The best way to run that program is to open the macOS Terminal app, then drag the binary from Finder into your Terminal window to enter the full path to it. If you do that then press return the program will run just like it did in Xcode, except now you can also pass options to it – try running it with `--help`, for example, and you’ll see that Swift Argument Parser takes care of printing help information for us.

# Prettifying the JSON
We’re going to add a handful of options to our app so that it can process JSON in a variety of ways. To start with, we’re going to add two flags and an argument – a flag is a simple true or false value, which is perfect for setting the configuration options for our app, whereas an argument is an unnamed option that the user puts on the end of the command, which is the simplest way of specifying the filename to process.

We specify these options using Argument Parser’s property wrappers, so add these three properties to the `App` struct now:

```
@Flag(name: .shortAndLong, help: "Neatly formats the output.")
var prettify = false

@Flag(name: .shortAndLong, help: "Sort keys alphabetically.")
var sort = false

@Argument(help: "The filename you want to process.")
var file: String
```

Notice how each of those three have help text attached, and the first two also have a `name` value – that extra option is important for flags so that users have a way of enabling or disabling them, whereas the argument doesn’t have a name.

You can see what .shortAndLong does by building the project again, then running it with `--help` from the command line – you should see that Swift Argument Parser allows us to use `-p` or `--prettify` for the prettifying flag, and `-s` or `--sort` for the sorting flag. In those instances, `-p` and `-s` are the short names, and `--prettify` and `--sort` are the long names.

With those options in place, we can fill in the `run()` method with some actual code. This will:

Load the file into a `Data` instance.
Convert that `Data` instance into a JSON object.
Convert the JSON object into a fresh `Data` object.
Convert the `Data` object into a string.
Print the string.

Two things might strike you as odd in that list. First, why bother converted from Data to JSON, then back from JSON to data? Well, because that’s where our clean up work will happen – when we write the data back out we get to customize how it’s written, including prettifying and sorting the keys.

The second thing is how we can convert `Data` into a JSON object: how can we use `Codable` if we don’t have any idea what we’re decoding? The answer is that we don’t need to use `Codable` at all, because we can use Foundation’s existing `JSONSerialization` class to all the work for us. We don’t need `Codable` here because we don’t care what kind of data is actually inside the file – as long as `JSONSerialization` can read it, we’re happy.

So, go ahead and add this `run()` method to your `App` struct now:

```
func run() {
    let url = URL(fileURLWithPath: file)

    guard let contents = try? Data(contentsOf: url) else {
        print("Failed to read input file \(file)")
        return
    }

    guard let json = try? JSONSerialization.jsonObject(with: contents, options: .fragmentsAllowed) else {
        print("Failed to parse JSON in input file \(file)")
        return
    }

    do {
        let newData = try JSONSerialization.data(withJSONObject: json)
        let outputString = String(decoding: newData, as: UTF8.self)
        print(outputString)
    } catch {
        print("Failed to create JSON output.")
    }
}
```

Note: The `.fragmentsAllowed` option I passed in when creating the JSON object, which makes the parser a little more relaxed.

At this point our program is actually useful already, because by default `JSONSerialization` removes all whitespace from JSON it writes – try running the program on an actual JSON file by using your-json-file.json in place of `--help`, and you should see it working!

Of course, our app would be much more useful if the `--prettify` and `--sort` options actually worked, but that’s only a few more lines of code. You see, when we call `JSONSerialization.data(withJSONObject:)` we get to pass in any writing options we want to customize how the output should look. This is our chance to inject the options for sorting and prettifying based on the values of our flags.

Start by adding this directly before the `do` block:

```
var writingOptions: JSONSerialization.WritingOptions = []

if prettify {
    writingOptions.insert(.prettyPrinted)
}

if sort {
    writingOptions.insert(.sortedKeys)
}
```

As you can see, that starts out with no special writing options, then inserts one or both of `.prettyPrinted` or `.sortedKeys` depending on the user’s flags. Now we just need to modify the call to `JSONSerialization.data(withJSONObject:)` to pass in those writing options, like this:

```
let newData = try JSONSerialization.data(withJSONObject: json, options: writingOptions)
```

Writing and overwriting
Beyond just exposing the underlying options provided by `JSONSerialization`, we can also write our own custom logic to add extra functionality to the app. In the case of cleaning files, it’s common to want to write the output to a different file rather than just printing it to the terminal, and we can code that ourselves.

Doing this takes a new flag and also another Argument Parser property wrapper called `@Option`. You’ve seen how `@Argument` lets us ask for an unnamed value from the user, and how `@Flag` lets us request a simple true or false. Well, `@Option` lets us request a named value that isn’t a simple Boolean, such as an integer or a string. In this project we’re going to look for an optional string, meaning that users don’t have to provide one if they want to.

The reason we have need both a new flag and an option is because one will be used to let the user specify a file to write to. We don’t want them to accidentally overwrite an existing file by accident, so the other new property will let them force a file overwrite if their output file exists already – if there is a filename clash and that value isn’t set, we’ll skip writing the new output.

So, add add these two new properties to the `App` struct now:

```
@Option(name: .shortAndLong, help: "Writes the output to a file rather than to standard output.")
var output: String?

@Flag(name: .shortAndLong, help: "Force overwrite files if they exist already.")
var forceOverwrite = false
```

The `output` property is optional, so it’s nil by default and not required from the user. But if it is set it means the user wants us to write their JSON to a file, which means we wrap the whole `let outputString` and `print()` call with new logic:

If output has a value, then make a file URL out of it.
If a file exists at that path already and the user hasn’t requested a force overwrite, issue an error and take no further action.
Otherwise, try writing the data to the file URL.
Adjust your code to this:

```
if let output = output {
    let outputURL = URL(fileURLWithPath: output)

    if FileManager.default.fileExists(atPath: outputURL.path) && forceOverwrite == false {
        print("Aborting: \(output) exists already.")
    } else {
        try newData.write(to: outputURL)
    }
} else {
    let outputString = String(decoding: newData, as: UTF8.self)
    print(outputString)
}
```

Now our app is able to print to the command line or write to a file, which makes it a much more natural command-line citizen.

# Cleaning up
The last thing we’re going to add is a custom command configuration, which lets us provide a range of customization options include the app’s name and description, version number, and, if you’re making a particularly big program, any subcommands that need to be connected.

Here we’re going to create a simple command configuration that specifies a better name and description than Swift Argument Parser has by default. I’m not sure you noticed when you were using `--help`, but Argument Parser thinks our app’s executable name is just “app”, because it uses the name of our `@main` struct. With a custom command configuration we can override this to be any name we want, all by adding this extra property to the `App` struct:

```
static var configuration: CommandConfiguration {
    CommandConfiguration(commandName: "jsontidy", abstract: "Adjusts JSON files to compress or expand data, and also provide key sorting.")
}
```

Now go ahead and build the app one last time, because it’s done!

If you wanted this app to live on your system for the long term, I recommend two things:

1. Make a release build of your app, rather than always using the debug version.
2. Copy the final release binary into /user/local/bin/jsontidy, so that it’s accessible from anywhere on your system.

# Challenges
1. Add an option to allow JSON5, which is another format supported by `JSONSerialization`.
2. Add a `--validate` flag that simply prints “OK” or “Syntax error” depending on whether the JSON is valid or not. Make sure you don’t allow `--output`, or `--prettify` to be set when validation is activated.
3. Find a way to adjust the pretty printing so that users can customize the number of spaces used for indenting. (Tip: This means operating on the output as a string!)