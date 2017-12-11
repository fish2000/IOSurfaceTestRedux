/*
 *  IOSurfaceTestAppDelegate.m
 *  IOSurfaceTest
 *
 *  Created by Paolo on 21/09/2009.
 *
 */

#import "IOSurfaceTestAppDelegate.h"
#import "IOSurfaceTestView.h"
#import <QTKit/QTKit.h>

@implementation IOSurfaceTestAppDelegate

@synthesize window, moviePlayer, moviePath, view, playButton, fpsField;

- (void)dealloc
{
	if (_moviePlaying)
		[moviePlayer stopProcess];
	
	[inputRemainder release];
	[moviePath release];
	
	[frameCounterTimer invalidate];
	[frameCounterTimer release];
	
	[super dealloc];
}

- (void)_countFrames: (NSTimer *)aTimer
{
#pragma unused(aTimer)
	[fpsField setIntegerValue: numFrames];
	numFrames	= 0;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	
	frameCounterTimer	= [[NSTimer scheduledTimerWithTimeInterval: 1.0
															target: self
														  selector: @selector(_countFrames:)
														  userInfo: nil
														   repeats: YES] retain];
}

- (IBAction)chooseMovie: (id)sender
{
	NSOpenPanel *openPanel  = [NSOpenPanel openPanel];
	
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	if ([openPanel runModalForDirectory: nil
								   file: nil
								  types: [QTMovie movieFileTypes: QTIncludeCommonTypes]] == NSOKButton) {
		if (_moviePlaying) {
			[moviePlayer stopProcess];
			[playButton  setTitle: @"Play"];
		}
		self.moviePath	= [openPanel filename];
	} else {
		self.moviePath	= nil;
	}
}

- (IBAction)playMovie: (id)sender
{
	if (_moviePlaying) {
		[moviePlayer stopProcess];
		
		[sender setTitle: @"Play"];
	} else {
		NSString	*cliPath	= [[NSBundle mainBundle] pathForResource: @"IOSurfaceCLI" ofType: @""];
		NSArray		*args;
		
		if (self.moviePath && [self.moviePath length] > 1) {
			args		= [NSArray arrayWithObjects: cliPath, @"-g", self.moviePath, nil];
//			args		= [NSArray arrayWithObjects: cliPath, @"-g", @"-d", @"1.0", self.moviePath, nil];
		} else {
			args		= [NSArray arrayWithObjects: cliPath, @"-g", @"-i", nil];
		}
		
		if (moviePlayer	= [[TaskWrapper alloc] initWithController: self arguments: args userInfo: nil])
			[moviePlayer startProcess];
		else
			NSLog(@"Can't launch %@!", cliPath);
		
		[sender setTitle: @"Stop"];
	}

}

- (void)appendOutput:(NSString *)output fromProcess: (TaskWrapper *)aTask
{
	if (!inputRemainder)
		inputRemainder	= [[NSString alloc] initWithString:@""];
	
	NSArray			*outComps	= [[inputRemainder stringByAppendingString: output] componentsSeparatedByString: @"\n"];
	NSEnumerator	*enumCmds	= [outComps objectEnumerator];
	NSString		*cmdStr;
	
	while ((cmdStr = [enumCmds nextObject]) != nil) {
		if (([cmdStr length] > 3) && [[cmdStr substringToIndex: 3] isEqualToString: @"ID#"]) {
			long			surfaceID	= 0;
			
			sscanf([cmdStr UTF8String], "ID#%ld#", &surfaceID);
			if (surfaceID) {
				[view setSurfaceID: surfaceID];
				[view setNeedsDisplay: YES];
				numFrames++;
			}
		}
	}
	
	cmdStr	= [outComps lastObject];
	if (([cmdStr length] > 0) && ([cmdStr characterAtIndex: [cmdStr length] - 1] != '#')) {
		NSLog(@"Storing %@ for later concat", cmdStr);
		[inputRemainder release];
		inputRemainder	= [cmdStr retain];
	}
}

- (void)processStarted: (TaskWrapper *)aTask
{
	_moviePlaying	= YES;
}

- (void)processFinished: (TaskWrapper *)aTask withStatus: (int)statusCode
{
	_moviePlaying	= NO;
	
	[moviePlayer autorelease];
	moviePlayer		= nil;
}

@end
