# Identifying performance hot spots with Time Profiler
Instruments gives us a range of tools for finding performance problems, and in this article we’ll be looking at how the Time Profiler instrument can point out problems in seconds.

# Looking for heavy stack traces
I’ve tried to build the smallest possible project that can demonstrate meaningful problems for Instruments to solve. The zip file you downloaded contains a macOS Command Line Tool project that loads some JSON with friend data, and goes every person to see how many total friends are online – that’s it.

To try it out, copy input.json to your desktop, then build and run the project. macOS should ask you if it’s okay to grant our program access to your desktop – please allow it otherwise the rest of this tutorial won’t be much use!

While that’s running, and before we get into Instruments, I want to point out a few small things just in case you were wondering:

1. The sleep(1) call is in there so we distinguish time spent loading our data from time spent analyzing our data.
2. The calls to CFAbsoluteTimeGetCurrent() let us track execution time – how long it took for the program to run.
3. The program is set to run in release mode even when running through Xcode, otherwise it’s just too slow – don’t try to use debugging!
Hopefully by now the program should have finished running. Mine took 8.861 seconds to run. Given there are only 3000 people in the data, that’s pretty slow – imagine 30,000 or 30 million!

That’s our baseline: about 9 seconds. Now let’s see where Instruments thinks the time is going: press Cmd+I to build and run the code for Instruments, then select Time Profiler when it asks you what template to use.

When it’s ready, press the record button in the top-left corner. This will start our app, and watch its execution to see what’s going on. Remember, we added a sleep(1) call so we could clearly distinguish between time spent loading our data and time spent analyzing it.

Time Profiler will stop recording automatically when our program stops, so after about 9 seconds – or however long yours took – it will finish, and you should see a chart of the results: how active your CPU was.

You can dive straight into the numbers if you want, but very often the most interesting thing in Time Profiler is called the heaviest stack trace. If it isn’t visible already, you can show it by going to the View menu and choosing View > Utilities > Show Extended Detail.

The heaviest stack trace is the single slowest part of your code. By default this will be across the entire run of your app, but you can also click and drag over the line chart at the top to limit that.

When looking at the heaviest stack trace, code in white is ours, code in gray is Apple’s, and those numbers to the left of the code show how many milliseconds were spent in there.

All being well, you should see “outlined destroy of Friend” taking up a lot of time – probably about half. Why is our program spending almost half its time destroying objects?

Well, the crux of our program is here:

```
for user in users {
    for friend in user.friends {
        if users.contains(where: {
            $0.name == friend.name && user.isActive
        }) {
            total += 1
        }
    }
}
```

That loops over all users, loops over all the friends of their users, then attempts to find the first user that matches the friend’s name.

Breaking that down a little more, each Friend instance has a LinkedFriends array inside it, which contains just the ID and name of the friend – enough data so we can show a preview then find their actual data in the main array.

If we have 3000 users, then a single loop over that would need to be run 3000 times. If each user had an average of 5 friends, then nesting that inside would mean 3000 x 5 loop iterations, giving 15,000 in total. But on the very inside we have a call to users.contains(where:), which will loop over all the items in users and return as soon as any one item matches the test – or false if none of them match the test.

So, in a worst-case scenario we now have 3000 x 5 x 3000 loop iterations – that 45,000,000 iterations!

That in itself isn’t terrible, but it does cause an interesting problem here: we’re copying a lot of data. You see, each time our loop goes around Swift will take copies of the data we’re working with – that’s what for user in users and for friend in user.friends is doing, copying one item out of those arrays into a temporary constant.

Mostly that’s fine, but here each one of our Friend instances has lots of properties – 10 to be precise. And lots of those are strings or arrays of strings, which in Swift are particularly problematic for performance.

How problematic? Well, take a look at the numbers area in the center: open the disclosure indicators TimeProfilerTest > Main Thread > swift_bridgeObjectRetain, and you’ll see it contains [__NSCFString retain] – mine was using up 1.58 seconds just doing that. We didn’t create any instances of NSCFString, but Swift is now doing vast amount of memory work to keep them around!

There are two underlying problems here. First, that structs have only one unique owner, so when we start a for loop Swift needs to copy each item into the loop variable. Second, that behind the scenes Swift’s strings are reference types with value semantics, which means we can use them as if they were value types but they are implemented as reference types in Swift’s internals.

This is how Swift implements copy on write: if you copy a string they both point to the same internal string reference, but if you then change one of those strings a copy is taken at that point.

So, putting that all together: when we loop over things 45 million times Swift is having to copy lots of structs, but inside those structs are lots of strings so it speeds things up by sharing the strings in both places using retain counts.

I’d like you to change the definition of Friend from a class to a struct, then press Cmd+R to run the code again. How does it affect your run speed? More importantly, why does it do that?

I’m going to answer in just a moment, but first I’d like you to consider it yourself.

Still here? Okay, think about this: our struct contains six String properties, plus an array of LinkedFriend that internally also uses has a String. Every time Swift copies that struct, it needs to tell each string that it’s being shared in two places. When we switch to a class, Swift is able to make an important performance optimization: it can retain the whole class rather than its individual contents. This means now rather than telling many strings they are being retained, it can tell just one class instance.

Don’t get me wrong, structs are much better than classes in so many places, but here they are causing a real performance headache – my code went from taking 8.75 seconds down to just 2.27 seconds, just by changing one word. Nice!

# Time for a second pass
Now that we’ve made an important change to our program, let’s try running Instruments again. It’s very easy to accidentally re-run Instruments without giving it your newly compiled code, so to be sure I often close the Instruments window then press Cmd+I in Xcode.

Anyway, re-run the Time Profiler and see what the heaviest stack trace is now. All being well you should see our friend “outlined destroy of Friend” has now been vanquished, and is replaced with a new stack trace that starts with “specialized Sequence.contains(where:)` – that’s taking 2350 milliseconds for me!

The “specialized” here means this is a generic function that has been optimized by the Swift compiler to work on the specific data we have in our program. But it doesn’t seem very optimized, because it’s chewing up a lot of time.

However, that function itself isn’t slow. If you look below you’ll see more white code: “thunk for @callee_guaranteed”. This is actually start of the closure we passed into contains(where:), and if you continue further down you’ll see static String.==.

For me, that == function was taking 2157 milliseconds, which is nearly all the 2350 milliseconds that its parent was taking. So, Instruments is telling us that contains(where:) isn’t slow – it’s the code we run inside it.

Remember when I said that strings are particularly problematic in Swift? Well, here’s another example: we’re comparing two strings right here. How long that operation takes depends on the strings in question: if they are 2000 characters long and the first 1900 are identical then this will be extraordinarily slow. Here our strings are names, so it’s fairly unlikely we’ll get collision past the first two or three letters. But even then, this code is slow and we can do better.

In this case, there’s something else we can use to detect whether two users are the same: we can compare their id properties. This is a UUID, which is a long sequence of letters and numbers like this one: 926AA7BB-D33B-4CE5-BAA2-B1D1B64F23D4.

That’s longer than most of if not all of our names, but it doesn’t matter: UUID is stored internally as 16 8-bit integers, so it’s extremely fast to compare them.

So, let’s try changing the contains(where:) closure to this:

```
$0.id == friend.id && user.isActive
```

Press Cmd+R to run the app again to get a feel for the speed difference – mine went from 2.27 seconds down to 1.55 seconds, which is a huge improvement.

You can also try running it through Instruments again, and now you’ll see all the string comparisons are gone.

# Short circuiting the smart way
What if I said there was a way to make our code run twice as fast without making any changes? Well, that’s not strictly true – we’ll be using all the same characters, just in a slightly different order.

I want you to look at this line of code:

```
$0.id == friend.id && user.isActive
```

What does that do? Hopefully you can read it more or less aloud: “if the user’s ID is equal to the friend’s ID and the user is active.”

That && isn’t magic in Swift; it’s an operator just like any other. In fact, it’s one of my favorite operators in Swift because the underlying code for it is quite beautiful:

```
public static func && (lhs: Bool, rhs: @autoclosure () throws -> Bool) rethrows -> Bool {
    return lhs ? try rhs() : false
}
```
There’s a heck of a lot packed into there, but what it does is produce short-circuit evaluation – the right-hand side of && will only be checked if the left-hand side is true.

What this means is that the order of our checks matters: if we put slow work on the left and fast work on the right, we’re guaranteed always to run the slow work and only sometimes run the fast work. But if we flip it around – get the fastest check done straight away – then we the slower check never has to happen.

In practice, this means we can change our code from this:

```
$0.id == friend.id && user.isActive
```

To this:

```
user.isActive && $0.id == friend.id
```

That’s the same code, just with a different order. And now my program runs in just 0.81 seconds – it takes half as long as it did before.

# Challenges
At this point we have made three small changes: using a class rather than a struct (one word difference), comparing id rather than name (two words difference), and rearranging our && check to prioritize a simple Boolean over two UUIDs (no words difference). And yet our program now runs in 0.81 seconds rather than 8.861 seconds – it’s more than 10 times faster.

Along the way we’ve looked at how copy on write can cause problems even with structs, why UUIDs are so much faster than strings, and how Swift’s beautiful && operator can be made to do less work with a little thinking.

But now I want to leave you with a challenge: we’ve solved this problem using Swift language features, but if you take a step back and think about this from a pure computer science perspective there’s an even bigger optimization waiting for us.

Think about it: we have to go over all 3000 users, and then each of their (approximately) 5 friends, so we’re stuck with at leas 15,000 loop iterations. But introducing the inner loop is what causes our main performance problem – it’s how we end up with 45 million iterations.

Your job is to think of a way to avoid that inner loop: how can you find a user in the array more quickly?

If you need a hint, there’s one below. If you’d like to see an example solution, that’s also below, but I’m going to write a few more words here so that you can’t accidentally see either of them.

Because that wouldn’t be nice.

And it wouldn’t be a challenge.

Still here?

Okay: try filling a [UUID: Friend] dictionary before the users loop begins – that would allow us to look up our users significantly faster.

I’m going to give you an example solution to, but obviously I don’t want you to read it. Seriously, taking the time to try things yourself is important and you’ll learn much more!

Still here?

Okay, try something like this:

```
var flattened = [UUID: Friend]()
flattened.reserveCapacity(users.count)

for user in users {
    flattened[user.id] = user
}

for user in users {
    for friend in user.friends {
        if let user = flattened[friend.id], user.isActive {
            total += 1
        }
    }
}
```

If you try that then you’ll see some epic performance gains, and now you can start to see why processing 30 million users wouldn’t be so hard after all!