# High-speed computation using Accelerate

Many coding problems are designed to perform the same operation on lots of data, and in fact they are so common Apple has a whole framework to make it better: Accelerate. In this video I’ll give you an introduction to Accelerate using practical examples so you can see just how easy it is.

# Why we need SIMD
Most developers are used to the idea of computational concurrency, which sees multiple CPU cores running their own code without waiting for each other.

However, long before multi-core CPUs were common, a different kind of parallel programming was already widespread, called Single Instruction, Multiple Data – or SIMD for short. This is designed to apply the same operation to two or more pieces of data at the same time in a highly efficient way.

You might wonder how often this kind of work is needed, and the answer is everywhere. Think about changing the brightness of a photo: if you have a 12 megapixel camera, that’s 12,000,000 pixels you need to adjust, with each one having red, green, and blue components.

I want to start by looking at how we might solve problems the traditional way. I don’t want to get into actual image processing here, so instead we’re going to look at some simpler math that will still benefit.

First, here’s a trivial extension that lets us make an array by executing a function repeatedly:

```
extension Array {
    init(running function: () -> Element, count: Int) {
        self = (0..<count).map { _ in function() }
    }
}
```

Arrays already have a repeating:count initializer, but that repeats the same value again and again to create the array. So, rather than having an array with lots of unique values, we would instead have an array with lots of identical values.

To demonstrate how useful that is, we can now create two large arrays of random doubles:

```
let count = 10_000_000
let first = Array(running: { Double.random(in: 0...10) }, count: count)
let second = Array(running: { Double.random(in: 0...10) }, count: count)
```

Now, if you wanted to reduce one of those arrays into a single value – to add all the doubles together in the first array to get a single combined value? This is the kind of thing you would do if you wanted to get a total of scores in a game, for example.

One solution might be to use a simple for loop over an array and add each value to a running total. With a couple of calls to CFAbsoluteTimeGetCurrent() we can see exactly how long that takes:

```
var start = CFAbsoluteTimeGetCurrent()
var result1 = 0.0

for item in first {
    result1 += item
}

var end = CFAbsoluteTimeGetCurrent()
print("1. Took \(end - start) to get to \(result1)")
```

In my test that took 0.01 seconds. If you find yours taking dramatically longer, remember to switch to release build configuration!

That’s really, fast, right? Sort of. Yes, if you were adding all the scores in a game then it’s fast, but if you were trying to read the average color value from a 12-megapixel image – a picture with 12,000,000 pixels – then it will use almost all your frame redraw time just to get started, so there’s no hope of you keeping your UI interactive if the operation is triggered every time the user moves a slider.

You might feel a bit clever and switch to using reduce(), like this:

```
start = CFAbsoluteTimeGetCurrent()
let result2 = first.reduce(0, +)
end = CFAbsoluteTimeGetCurrent()
print("2. Took \(end - start) to get to \(result2)")
```

Sadly, in my test that took 0.11 seconds – it was slower than just using a simple for loop! Remember, reduce() is actually just a for loop internally, except now we’re adding the extra overhead of making each loop iteration into a function call.

Now let’s try the same operation using Apple’s Accelerate framework. This is a separate framework built into all four of Apple’s platforms, so your first step is to add this to your Swift file:

```
import Accelerate
```

And now we can write a third attempt:

```
start = CFAbsoluteTimeGetCurrent()
let result3 = vDSP.sum(first)
end = CFAbsoluteTimeGetCurrent()
print("3. Took \(end - start) to get to \(result3)")
```

To be clear, all it takes to sum the array is to use vDSP.sum(). And when I ran that code, I was getting the whole array being summed in about 0.004 seconds – four thousandths of a second. That’s twice as fast as the next best option!

# A note on floating point
There are many major milestones in a programmer’s learning journey, but easily one of the biggest, most confusing, and longest-lived is that floating-point mathematics is really hard. Like, way harder than you would possibly imagine, and in fact likely to lead you into at least one major screw up during your career.

At this point I want to pause to show you an example of that: look at the output from your three pieces of code, and in particular notice the totals that are reached. It’s almost guaranteed that on your computer the first two numbers are identical, but the third is subtly different.

We’ve just done the same thing three times, but one of the three results is different. That should not – for a very specific definition of “should” that your computer will not agree with – be possible, because math is fixed, right? Well, no. Again, floating-point math is hard, and one of its many fascinating complexities is that the order in which you add numbers depends on the result you get.

Here’s an example for you to try:

```
let a = 11111111.11111111
let b = 22222222.22222222
let c = 33333333.33333333
print(a + b + c)
print(c + b + a)
```

If you run that you’ll see two different values being printed, even though if you were to do the math on paper there can only ever be one result: 66666666.66666666. And yet our second print statement manages to add a 4 to the end – and it’s not an accident, because that same difference will be there no matter how many times you run the code.

All this matters because when we’re summing values, both our simple for loop and the reduce() call both take the same approach: add one number to the total, then add another number to the total, then a third, a fourth, a fifth, and so on.

But using vDSP.sum() is designed to issue one instruction (“add stuff”) to multiple pieces of data at the same time, so it will add things in batches. This is a huge performance optimization as you can see, but it also means we’ll get slightly different results from a linear add because of the way the numbers get stored when added.

Is this a problem? Like so many things, it depends. When working with Double the precision is so high that a tiny difference is usually irrelevant, because if you cared about that tiny difference then you would be hit by a thousand other similar problems – that’s just how floating-point math works. But if you work with less precise numbers, such as Float or even Float16, then the difference can increase. Be careful!

# Accelerate everything
The amazing thing about Accelerate – apart from its extraordinary, free performance boosts – is that it comes with a huge amount of functionality just there for the taking.

For example, we have two arrays of numbers and we can ask Accelerate to add them together element by element, like this:

```
let added = vDSP.add(first, second)
```

So, that will add the first item to the first item, the second item to the second item, and so forth, then return a new array with the same number of items and the sums.

This is what’s called an embarrassingly parallel problem: a problem that can be broken up into parallel tasks with little to no work. Here, that means we can add first[1] and second[1] without needing to know the result of adding first[0] and second[0] – they can both be done at the same time.

If you want to subtract the two, just use vDSP.subtract(). Or if you want to multiply or divide, you should use vDSP.multiply() and vDSP.divide() – both work exactly as you would expect. Even better, they can be run with different parameters: if you pass a Double as well they you can add that value to each of the numbers in your array, or divide that value by each of the numbers in your array. Or reverse the parameters to divide the numbers by the value, it’s down to you and it works in exactly the same highly optimized way.

If you just write vDSP. and look at the code completion it’s remarkable how much is here: you can clip numbers, calculate distances and dot products, convert between Double, Float, and Int, and so much more – and this is just one of several parts of Accelerate.

Using Accelerate won’t always be faster than doing things manually. The key thing to remember is that Accelerate thrives on being given lots of data to chew on: if you’re working with 10 items in an array then there’s never going to be a meaningful difference between using Accelerate and not – unless you’re checking those items many, many times, that is. But when it’s fast, it’s fast and it’s often worth checking your code to see what’s possible.

For example, you probably know that we can use max() to find the largest value in an array, like this:

```
start = CFAbsoluteTimeGetCurrent()
let value1 = first.max() ?? 0
end = CFAbsoluteTimeGetCurrent()
print("1. Took \(end - start) to find \(value1)")
```

Well, vDSP.maximum() does almost the same thing, except rather than returning an optional integer you’ll get back negative infinity if the array you’re using is empty. Here’s how that looks in code:

```
start = CFAbsoluteTimeGetCurrent()
let value2 = vDSP.maximum(first)
end = CFAbsoluteTimeGetCurrent()
print("2. Took \(end - start) to find \(value2)")
```

If you run it back you’ll see that using max() is fast, but vDSP.maximum() is faster – about 3x faster in my test.

# Root mean squares
It’s worth adding that apart from just being faster, Accelerate is often significantly easier to write. To give you a practical example, it’s common to want to calculate the root mean square of a set of numbers – the RMS.

If you haven’t come across this before, RMS allows us to measure how large our error values are across a data set, or how far we deviated from a zero error.

For instance, think about the array 3, 3, and 3. If those were error values – if we were off by 3 every time – then the mean average error value would 3. Now think about the array 2, 3, and 4. Again, if you calculate the mean average of those numbers then you get ((2 + 3 + 4) / 3), which is also 3. Our two arrays both have a mean error of 3 even though one of them has a higher maximum error.

Calculating the root mean square means we first square all our numbers, then calculate the mean average, then calculate the square root of that mean average. So for 3, 3, 3 we would:

Square the numbers to get 9, 9, 9.
Add them together to get 27, and divide by 3 to get 9.
Calculate the square root of 9, which is 3.
So, for mean average and root mean square average, the array 3, 3, 3 yields the same result. But for the array 2, 3, 4 it would look like this:

Square the numbers to get 4, 9, 16.
Add them together to get 29, and divide by 3 to get 9.666.
Calculate the square root 9.666, which is about 3.1.
So, using the root mean squared has shown that 2, 3, 4 contains more error than 3, 3, 3, which is why it’s so commonly used with things like machine learning – it lets us measure how far the computer’s predictions were from accurate sample data.

Anyway, there’s a lot going on here, but Accelerate does it all in a single line of code:

```
let rms = vDSP.rootMeanSquare(first)
```

Think about it: squaring all the numbers can be done in parallel, and adding them all together can be done in parallel, so this is extraordinarily fast with Accelerate.

So, anywhere you have to manipulate large quantities of data, Accelerate can probably help you make it much faster.

But we can do better…

# Precision vs performance
Apple’s ARM64 CPUs have 64-bit general purpose registers, but 128-bit floating-point and vector registers. For context, the size of a Double in Swift is 64 bits.

All that is a fancy way of saying that when we use Accelerate it will effectively place two doubles into one of its registers – it will put two 64-bit things into a 128-bit slot, then execute its instruction.

I realize this might sound tedious, but there’s an important principle here: if you’re willing to accept less precision you can switch to a Float rather than a Double, and because they are 32-bit rather than 64-bit Accelerate can work on twice as many at a time.

To demonstrate this, change your two arrays to this:

```
let first = Array(running: { Float.random(in: 0...10) }, count: count)
let second = Array(running: { Float.random(in: 0...10) }, count: count)
```

And now change the result1 definition like so:

```
var result1: Float = 0.0
```

When you run the code again you’ll see something quite remarkable: the for loop and reduce() call haven’t changed in speed, but the call to vDSP.sum() is now running even faster.

Reminder: You are sacrificing accuracy when switching to Float: the larger your data set and/or the more operations you perform, the more accuracy you will lose. Test it out carefully to see what results you get on your own data!

So, we get to make a choice: if you want the most accuracy then use Double and you’ll get a healthy speed boost with Accelerate, but if you’re short on time and are willing to sacrifice some accuracy to get performance up, switch to Float and you’ll find Accelerate blows you away.

And remember, this is just one part of Accelerate. We have barely scratched the surface of what this framework can do, and I hope you’re already seeing many possibilities even with the tiny part we’ve explored.

# Challenges
If you’d like to take this tutorial further, here are two questions to consider:

vDSP contains sum() and sumOfSquares(), but also a separate method called sumAndSumOfSquares(). Why do you think this should be a separate method?
Why do you think vDSP is an enum? Why isn’t it a struct or something else?