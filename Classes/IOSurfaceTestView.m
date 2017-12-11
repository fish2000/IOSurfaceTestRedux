/*
 *  IOSurfaceTestView.m
 *  IOSurfaceTest
 *
 *  Created by Paolo on 21/09/2009.
 *
 */

#import "IOSurfaceTestView.h"
#import <OpenGL/CGLMacro.h>


@implementation IOSurfaceTestView

- (NSOpenGLPixelFormat*) basicPixelFormat
{
    NSOpenGLPixelFormatAttribute	mAttrs []	= {
		NSOpenGLPFAWindow,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAColorSize,		(NSOpenGLPixelFormatAttribute)32,
		NSOpenGLPFAAlphaSize,		(NSOpenGLPixelFormatAttribute)8,
		NSOpenGLPFADepthSize,		(NSOpenGLPixelFormatAttribute)24,
		(NSOpenGLPixelFormatAttribute) 0
	};
	
	return [[[NSOpenGLPixelFormat alloc] initWithAttributes: mAttrs] autorelease];
}

- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame: frameRect pixelFormat: [self basicPixelFormat]]) {
		CGLContextObj   cgl_ctx			= [[self openGLContext]  CGLContextObj];
		long			swapInterval	= 1;
		
		[[self openGLContext] setValues:(GLint*)(&swapInterval)
						   forParameter: NSOpenGLCPSwapInterval];
		glEnable(GL_TEXTURE_RECTANGLE_ARB);
		glGenTextures(1, &_surfaceTexture);
		glDisable(GL_TEXTURE_RECTANGLE_ARB);
	}
	
	return self;
}

- (void)dealloc
{
	CGLContextObj   cgl_ctx = [[self openGLContext]  CGLContextObj];
	
	glDeleteTextures(1, &_surfaceTexture);
	
	[super dealloc];
}

- (void)_bindSurfaceToTexture: (IOSurfaceRef)aSurface
{
	if (_surface && (_surface != aSurface)) {
		CFRelease(_surface);
	}
	
	if ((_surface = aSurface) != nil) {
		CGLContextObj   cgl_ctx = [[self openGLContext]  CGLContextObj];
		
		_texWidth	= IOSurfaceGetWidth(_surface);
		_texHeight	= IOSurfaceGetHeight(_surface);
		
		glEnable(GL_TEXTURE_RECTANGLE_ARB);
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, _surfaceTexture);
		CGLTexImageIOSurface2D(cgl_ctx, GL_TEXTURE_RECTANGLE_ARB, GL_RGB8,
							   _texWidth, _texHeight,
							   GL_YCBCR_422_APPLE, GL_UNSIGNED_SHORT_8_8_APPLE, _surface, 0);
//		CGLTexImageIOSurface2D(cgl_ctx, GL_TEXTURE_RECTANGLE_ARB, GL_RGBA8,
//							   _texWidth, _texHeight,
//							   GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, _surface, 0);
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
		glDisable(GL_TEXTURE_RECTANGLE_ARB);
	}
}


- (void)setSurfaceID: (IOSurfaceID)anID
{
	if (anID) {
		[self _bindSurfaceToTexture: IOSurfaceLookup(anID)];
	}
}

- (void)reshape
{
 	CGLContextObj   cgl_ctx = [[self openGLContext]  CGLContextObj];
	
	glViewport(0, 0, [self bounds].size.width, [self bounds].size.height);
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	[[self openGLContext] flushBuffer];
}

- (void)drawRect:(NSRect)rect
{
#pragma unused(rect)
 	CGLContextObj   cgl_ctx		= [[self openGLContext]  CGLContextObj];
	
	//Clear background
	glClearColor(0.0, 1.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	if (_surface) {
		GLfloat		texMatrix[16]	= {0};
		GLint		saveMatrixMode;
		
		// Reverses and normalizes the texture
		texMatrix[0]	= (GLfloat)_texWidth;
		texMatrix[5]	= -(GLfloat)_texHeight;
		texMatrix[10]	= 1.0;
		texMatrix[13]	= (GLfloat)_texHeight;
		texMatrix[15]	= 1.0;
		
		glGetIntegerv(GL_MATRIX_MODE, &saveMatrixMode);
		glMatrixMode(GL_TEXTURE);
		glPushMatrix();
		glLoadMatrixf(texMatrix);
		glMatrixMode(saveMatrixMode);
		
		glEnable(GL_TEXTURE_RECTANGLE_ARB);
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, _surfaceTexture);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	} else {
		glColor4f(0.4, 0.4, 0.4, 0.4);
	}
	
	//Draw textured quad
	glBegin(GL_QUADS);
		glTexCoord2f(0.0, 0.0);
		glVertex3f(-1.0, -1.0, 0.0);
		glTexCoord2f(1.0, 0.0);
		glVertex3f(1.0, -1.0, 0.0);
		glTexCoord2f(1.0, 1.0);
		glVertex3f(1.0, 1.0, 0.0);
		glTexCoord2f(0.0, 1.0);
		glVertex3f(-1.0, 1.0, 0.0);
	glEnd();
	
	//Restore texturing settings
	if (_surface) {
		GLint		saveMatrixMode;
		
		glDisable(GL_TEXTURE_RECTANGLE_ARB);
		
		glGetIntegerv(GL_MATRIX_MODE, &saveMatrixMode);
		glMatrixMode(GL_TEXTURE);
		glPopMatrix();
		glMatrixMode(saveMatrixMode);
	}
	
	[[self openGLContext] flushBuffer];
}

@end
