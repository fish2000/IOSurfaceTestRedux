/*
 *  IOSurfaceTestAppDelegate.h
 *  IOSurfaceTest
 *
 *  Created by Paolo on 21/09/2009.
 *
 */

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"

@class IOSurfaceTestView;

@interface IOSurfaceTestAppDelegate : NSObject <NSApplicationDelegate, TaskWrapperController>
{
    NSWindow			*window;
	IOSurfaceTestView	*view;
	NSButton			*playButton;
	NSTextField			*fpsField;
	
	TaskWrapper			*moviePlayer;
	NSString			*moviePath;
	NSString			*inputRemainder;
	
	NSInteger			numFrames;
	NSTimer				*frameCounterTimer;
	
	BOOL				_moviePlaying;
}

@property (assign) IBOutlet NSWindow			*window;
@property (assign) IBOutlet IOSurfaceTestView	*view;
@property (assign) IBOutlet NSButton			*playButton;
@property (assign) IBOutlet NSTextField			*fpsField;
@property (retain) TaskWrapper					*moviePlayer;
@property (retain) NSString						*moviePath;

- (IBAction)chooseMovie: (id)sender;
- (IBAction)playMovie: (id)sender;

- (void)appendOutput:(NSString *)output fromProcess: (TaskWrapper *)aTask;
- (void)processStarted: (TaskWrapper *)aTask;
- (void)processFinished: (TaskWrapper *)aTask withStatus: (int)statusCode;

@end
