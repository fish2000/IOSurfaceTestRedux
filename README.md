
Hidden Gems of Snow Leopard: IOSurface
=================================

Snow Leopard may have looked not so different from its predecessor from the average user point of view: however, for developers like myself, a lot of things have changed, some well advertised (say, GCD, OpenCL and 64 bits), some still to discover. [A good overview can be found at Ars Technica](http://arstechnica.com/apple/reviews/2009/08/mac-os-x-10-6.ars).

As one of the long overdue issues, not to mention all the limitations derived from its venerable age, Apple has introduced a first step to the future of the old Quicktime (that will stay in 32 bit universe) with the new Quicktime X: however, Quicktime isn't so easy to replace in one shot, and it's still present in the system, transparently invoked by Quicktime X (or, for us developers, by QTKit) whenever it's needed.

But, how can a 64-bit software (like the Quicktime X Player, or the Finder itself) use a 32-bit library? The answer is, it doesn't, the technique used behind the scenes is far more interesting: when a 64-bit software needs a frame from a movie it can't process otherwise, a specific software is launched (you'll see it in the Activity Monitor as "QTKitServer-(<caller process id>) <caller process name>") that gives back the frames to the 64-bit app.

*Hey, isn't that nice?* Graphics passed from one process to another, how can they do that? The answer looks like it's in a new framework, _IOSurface_.

> Disclaimer: the following statements are the result of personal experimentation: as such, they don't represent any
> official documentation nor endorsement.

IOSurface is included in the new public frameworks, but no mention of it exists in the official documentation: looking at the various C headers, however (not only in `IOSurface.framework`, but overall in the graphics libraries - Spotlight's your friend), it's possible to have a glimpse at its capabilities.

Putting together some sample code
-----------------------------------------------

A good example of how IOSurface works could be a quick and dirty implementation of a QTKitServer-lookalike, that plays any Quicktime movie in a 32-bit faceless application, and its 64-bit companion that shows the frames in an OpenGL view.

More in detail, a IOSurface can be attached to many kinds of graphic surfaces and passed around to different tasks, that makes it the perfect candidate for our own version of a QTKitServer-clone. The link to the Xcode project is below - 10.6-only, of course.

The faceless movie player
-----------------------------------

Now, let's see how to create frames on IOSurfaces. For a start, we can create Core Video pixel buffers (one of the possibilities to define an offscreen destination for QT movies - see the excellent QTCoreVideo sample projects) that will have IOSurfaces bound to them: when we create the QTPixelBufferContext, introducing the proper items in the optional dictionary will instruct Core Video to attach IOSurfaces to each pixel buffer we'll get back. Each CVPixelBuffer we'll get from Core Video will then be asked for the related IOSurfaceRef: IOSurfaceRefs are the references to use inside the same application, and each surface has also a unique IOSurfaceID that can be referred to in other processes to obtain a local IOSurfaceRef.

For the sample I've put together, I've used the simplest way of passing IOSurfaces, i.e. asking them to be created "global" and passing around the IDs: not the ideal solution in the long term, but the other way (i.e. passing them through Mach ports) looks more complex and prone to errors to implement without the docs.

The small CLI app gets as the only argument the movie to play, and passes back the IDs of the surfaces through a simple pipe. Using the kIOSurfaceIsGlobal option puts also a limit in the consumer side: as the CLI doesn't know anything about the consumer, surfaces will be reused as soon as possible, so they'll have to be consumed at once. Binding them to Mach ports, however, would force the framework to create new surfaces until the previous ports are deallocated.

The 64-bit GUI application
-----------------------------------

Our 64-bit app is a very simple GUI: nothing really special here, a movie is chosen and passed to our faceless app launched in background as a NSTask, whose output is captured and parsed for IOSurfaceIDs. The interesting part is in the few lines that get the IOSurfaceID and build up a texture that we can use: the new call is CGLTexImageIOSurface2D, that is meant to be the IOSurface equivalent of glTexImage2D used in "regular" OpenGL to upload images.

The QCPlugin
-------------------

To extend the sample, I've now added a Quartz Composer plugin that spawns the CLI application: it's also possible to choose in the compilation if the image has to be provided to QC as GL texture or a pixel buffer.
A sample composition has been included in the code.

Video input
---------------

I've modified the command line tool to accept some more params, in order to use as frame source a video input. The code, thanks to the QTCapture framework, is pretty straightforward, and it's interesting to note that very little was needed to get it working. Clearly, although with little documentation, IOSurface integrates perfectly in the existing technologies!

NB.:
-------

- The code is only good as a demo of the capabilities and for experimenting, in many aspects a real-world solution will use very different techniques!
- The embedded CLI application is set as a dependency for the other 2 projects, and should be compiled automatically: however, in certain cases it appears that Xcode "forgets" to apply the build flags, and tries to compile in 64 bits (that fails). To solve this issue, compile the IOSurfaceCLI target separately.
- A bug seems to affect Quartz Composer whenever a movie is started and stopped multiple times: the projection matrix, for some reason, isn't reset, and the frame appears much bigger. A report has been posted to Apple.

