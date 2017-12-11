/*
 *  IOSurfacePlugIn.h
 *  IOSurfaceTest
 *
 *  Created by Paolo on 08/10/2009.
 *
 * Copyright (c) 2009 Paolo Manna
 * All rights reserved.
 *
 */

#import <Quartz/Quartz.h>
#import <OpenGL/OpenGL.h>
#import <IOSurface/IOSurface.h>
#import "TaskWrapper.h"

@interface IOSurfacePlugIn : QCPlugIn <TaskWrapperController>
{
    BOOL            _imageChanged;
    TaskWrapper     *moviePlayer;
    NSString        *inputRemainder;
    
    BOOL            _moviePlaying;
    BOOL            _frameReady;
    NSInteger       _surfaceID;
}

@property(assign) NSString                          *inputFileName;
@property(assign) BOOL                              inputPlay;
@property(assign) id<QCPlugInOutputImageProvider>   outputImage;

- (void)appendOutput: (NSString *)output fromProcess: (TaskWrapper *)aTask;
- (void)processStarted: (TaskWrapper *)aTask;
- (void)processFinished: (TaskWrapper *)aTask withStatus: (int)statusCode;

@end
