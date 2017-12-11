/*
 *  IOSurfaceTestView.h
 *  IOSurfaceTest
 *
 *  Created by Paolo on 21/09/2009.
 *
 */

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <IOSurface/IOSurface.h>

@interface IOSurfaceTestView : NSOpenGLView {
	GLuint			_surfaceTexture;
	IOSurfaceRef	_surface;
	GLsizei			_texWidth;
	GLsizei			_texHeight;
	uint32_t		_seed;
}

- (void)setSurfaceID: (IOSurfaceID)anID;

@end
