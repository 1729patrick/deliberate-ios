# Finding and fixing slow rendering
Instruments is a powerful tool for identifying performance problems, but in this article I’ll show you how to find code that slows down rendering in your app, causing slow scrolling, wasted CPU time, and more – all through the simulator.

# Blended layers
Run the app and go to the Debug menu in the simulator, and click the Color Blend Layers option. This will redraw the simulator in varying shades of green and red, where any green color means you are showing opaque colors (very fast), and varying shades of red means you’re doing some amount of blending. The darker the red you see, the more blending you’re doing.

To understand why color blending is a bad thing, think about this: if UIKit needs to draw a solid blue color onto the screen, it doesn’t matter what comes below it – it could be a red color below, or white, or tartan; it doesn’t matter, because we’re about to paint solid blue over the top.

But if we’re painting a translucent blue over another color, now we have a problem: for every pixel on the display, iOS needs to read the current color, multiply it with the new color, and produce a new blended color. This isn’t slow when done sometimes, but if you see dark red patches it means iOS has had to blend multiple colors to get the final result and that’s never good.

In our app we have mostly green, apart from a little blending with the status bar. Let’s break that by adding these two lines to the end of viewDidLoad():

```
imageView.clipsToBounds = true
imageView.layer.cornerRadius = 20
```

If you run the code again you’ll see our whole image has gone red, because now UIKit is having to smooth the edges of the rounded corners by blending them into the background.

This is one of those places where you can introduce blending almost by surprise, and if you’re not careful end up with many layers of blending and that’s even worse.

There’s no magic solution here: if you want the rounded corners you need to be willing to pay for them in performance.

However, if you’re really struggling to get your frame rate smooth because of blending, one workaround you use is to render your image with the corner radius pre-rounded, blending it directly onto an opaque background color.

To try that here, first create a new class called RoundedImageView:

```
class RoundedImageView: UIView {
    var image: UIImage?
    var cornerRadius: CGFloat?

    override func draw(_ rect: CGRect) {
        if let cornerRadius = cornerRadius {
            let borderPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
            borderPath.addClip()
        }

        image?.draw(in: rect)
    }
}
```

Now change the image view in ViewController to this:

```
let imageView = RoundedImageView()
```

And finally, change viewDidLoad() to pass in the properties that the new rounded view needs to work:

```
imageView.image = UIImage(named: "example")
imageView.clipsToBounds = true
imageView.cornerRadius = 25
imageView.backgroundColor = .systemBackground
```

If you run that through Color Blended Layers you’ll see there is now no more blending – it’s all opaque.

Note: Before you continue, you should revert your changes to avoid getting problems later on. So, put the imageView property back to being a UIImageView, and remove the clipsToBounds, cornerRadius, and backgroundColor lines we added in viewDidLoad().

Copied images
The second option that’s interesting is quite rare, but worth mentioning just in case. It’s called Color Copied Images, and it will highlight any images that needed to be converted by the CPU before they could be drawn.

Honestly, iOS is pretty good at accepting a wide variety of images – JPEG, PNG, and others all work in various color depths and optimization levels.

If you hit this, and again it’s fairly unlikely, you need to be careful: these pictures can’t be drawn directly to the screen, and must be converted first. That’s slow, and won’t be cached by the system, so it can be a massive drag on your app.

To demonstrate the problem in action, I’ve included a couple of 32-bit TIF images with the project. These show the same picture as the regular 8-bit JPEGs, but iOS can’t natively draw 32-bit TIFs using its GPU.

To try it out, change the imageView.image line to load the TIF instead:

```
imageView.image = UIImage(named: "example-bad.tif")
```

Now if you run the app with Color Copied Images checked, you’ll see a turquoise overlay over the photo.

Honestly, the only chance you have of hitting this problem is if you request an image over the internet and it’s sent in an unhelpful format. If that happens to you, the best thing to do is re-render the image something like this:

```
func redraw(image: UIImage) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: image.size)
    return renderer.image { ctx in
       image.draw(in: CGRect(origin: .zero, size: image.size))
    }
}
```

You can then use that redrawn copy for your local cache, so it won’t slow down performance. If you don’t cache the resulting image there’s no point running the method – just let the CPU convert the image.

Note: Before you continue, please put the image back to UIImage(named: "example") rather than the TIF.

# Misaligned images
Rendering is fastest when views are drawn at their native size and at a sensible position on the screen. Either of these are easy to get wrong in UIKit, and can cause slow performance and even fuzzy drawing.

The most common time you’ll see this problem is when you’re rendering images at a non-native size – you’re stretching them somehow.

For example, we could use width and height constraints that aren’t correct for our image:

```
imageView.widthAnchor.constraint(equalToConstant: 150),
imageView.heightAnchor.constraint(equalToConstant: 100)
```

The aspect ratio is correct – this image isn’t being warped – but the pixel count is different from the image’s natural size. This means iOS has to redraw the image with smooth blending to make it fit into the smaller space.

So, run the app again, and check Color Misaligned Images. The simulator should draw a yellow color over the picture to show that it’s a minor problem.

And it is a minor problem. Sure, it isn’t ideal, but as performance problems go it’s one of the lesser ones – GPUs are extremely good at stretching textures in the way, so I wouldn’t be terribly worried about doing it sometimes.

However, things get more interesting when we choose slightly unusual values. Try these, for example:

```
imageView.widthAnchor.constraint(equalToConstant: 300),
imageView.heightAnchor.constraint(equalToConstant: 202)
```

Now the image is drawn normally, with no yellow over it even though the frame clearly is different from the 300x200 we had originally. This is possible because our image view uses the aspect fit content mode, meaning that when the frame is a little too big in one dimension iOS will just adjust the position of the image rather than stretch it.

In this case, we gave the image 2 points too much space vertically, so iOS will just move it 1 point down so there is 1 point of space above and 1 point of space below.

Now try this:

```
imageView.widthAnchor.constraint(equalToConstant: 300),
imageView.heightAnchor.constraint(equalToConstant: 201)
```

If you run that you’ll see the image has a blue color, which is a more serious problem. Here we’re giving the image only 1 point too much space vertically, so iOS will make the image fit by moving it 0.5 points down.

The image itself won’t get stretched, because it still fits into the space provided, however now iOS can’t simply map pixels from the image into pixels on the screen. Instead, it needs to blend every single image pixel so that it’s drawn half on one pixel and half on another, which is Very Bad Indeed.

Now, in the case of images like this one it won’t matter. Sure, it’s slow, but users probably won’t notice. But with things where pixel alignment matters, such as 1-point borders or fine text, this will result in your content being blurry.

If you aren’t using Auto Layout, you’ll sometimes see folks write code like this:

```
imageView.frame = imageView.frame.integral
```

That should round down all the floating-point coordinate values and round up any floating-point size values, producing a slightly larger frame that is pixel aligned.

However, things are a bit more gnarly if you are using Auto Layout. Your best bet is to ensure you’re using artwork that is evenly divisible by the screen scale.

You’ll be pleased to know that SwiftUI doesn’t allow half-pixel rendering like this – views are always snapped to the nearest whole pixel.

Tip: To avoid problems, you should put your width and height constraints back to 300x200 and remove the imageView.frame line before continuing.

# Color off-screen rendered
The last option I want to look at is called Color Off-screen Rendered, and when checked this will highlight in yellow any views that had to be rendered off-screen first using a separate drawing pass, then composited onto the screen in a second pass. This is as slow as it sounds, but again it’s surprisingly easy to trigger.

For example, one of the most common ways to require off-screen rendering is with a shadow, such as this:

```
imageView.layer.shadowOpacity = 1
imageView.layer.shadowOffset = .zero
imageView.layer.shadowRadius = 10
```

Put that into viewDidLoad() and run the app again, then check the Color Off-screen Rendered option – you should see our image gets colored yellow.

iOS applies its shadows accurately around shapes by rendering them and looking for transparency. This allows it to apply shadows around individual letters in a UILabel rather than just using a simple rectangle, for example.

However, here our image is totally opaque, so we don’t actually need iOS to perform that opacity-detection pass – we can see it’s a rectangle! So, we can add this line of code so iOS doesn’t need to do the work itself:

```
imageView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 300, height: 200)).cgPath
```

But if you need that transparency detection to happen – if you have a complex shape that you want iOS to scan to get the shadow perfect – then a second option to try is to rasterize the layer. This won’t allow iOS to skip its off-screen render pass, but will allow it to cache the whole result in memory for faster drawing later.

To enable rasterization for a view, use this:

```
imageView.layer.shouldRasterize = true
imageView.layer.rasterizationScale = UIScreen.main.scale
```

The second line is important, because by default views will rasterize at 1x scale rather than the default scale for the current device.

Rasterizing layers in this way actually adds more work in the short term, because now iOS has to stash the rendered view away somewhere and there’s a CPU and memory cost to that. It’s also unwise to use rasterization if you’re changing the view regularly, because iOS will need to throw away its rendered copy every time a change is made.

However, if this view is used quite a lot then it’s often worth spending that extra memory on rasterization, because it can make a huge difference – particularly when scrolling.

# Challenges
Here are some suggestions to help you take this code further:

Improve the RoundedImageView class so that it supports different content modes – can you get aspectFit to work?
Improve the redraw(image:) method so that it takes an optional CGSize, which, if set, will scale the image down to those proportions. This makes the function much more useful when handling images from the internet, which could come in at any size.
Experiment with the shadowPath property to see if you can create something more than just a flat shadow. If you’re looking for inspiration, try my article: </articles/155/advanced-uiview-shadow-effects-using-shadowpath>