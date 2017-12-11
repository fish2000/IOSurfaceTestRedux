/*
 *  MovieRenderer.h
 *  IOSurfaceCLI
 *
 *  Created by Paolo on 21/09/2009.
 *
 */

#import <QTKit/QTKit.h>
#import <QuickTime/QuickTime.h>
#import <CoreAudio/CoreAudio.h>
#import <CoreVideo/CoreVideo.h>

// For OSAtomic operations
#import <libkern/OSAtomic.h>

//#define   DISABLE_IOSURFACE

#if defined(DISABLE_IOSURFACE) && defined(COREVIDEO_SUPPORTS_IOSURFACE)
#undef COREVIDEO_SUPPORTS_IOSURFACE
#define COREVIDEO_SUPPORTS_IOSURFACE    0
#endif

#define FRAME_QUEUE_SIZE    100

typedef struct _QueueItem {
    CVImageBufferRef    frameBuffer;
    NSTimeInterval      frameTime;
} QueueItem;

@interface MovieRenderer : NSObject {
    QTMovie                             *qtMovie;
    NSString                            *moviePath;
    QTVisualContextRef                  vContext;
    
    QTCaptureSession                    *captureSession;
    QTCaptureDeviceInput                *deviceInput;
    QTCaptureDecompressedVideoOutput    *videoOutput;
    
    OSSpinLock                          _movieLock;
    NSInteger                           maxQueueSize;
    NSInteger                           currentQueueIdx;
    NSTimeInterval                      refHostTime;
    NSTimeInterval                      frameStep;
    
    QueueItem                           frameQueue[FRAME_QUEUE_SIZE];
}

+ (void)setAudioDelay: (double)audioDelay;
+ (void)setAlphaSurface: (BOOL)doAlpha;

- (id)initWithDevice: (NSString *)uniqueID;
- (id)initWithPath: (NSString *)aPath;

- (void)startPlay;
- (void)stopAndReleaseMovie;
- (void)idle;

- (NSString *)moviePath;
- (NSTimeInterval)movieDuration;
- (NSTimeInterval)frameStep;
- (float)movieFrameRate;
- (NSTimeInterval)queuedMovieTime;

- (NSInteger)maxQueueSize;
- (void)setMaxQueueSize: (NSInteger)aSize;
- (float)movieRate;
- (void)setMovieRate: (float)aFloat;
- (float)movieVolume;
- (void)setMovieVolume: (float)aFloat;
- (NSTimeInterval)movieTime;
- (void)setMovieTime: (NSTimeInterval)aDouble;

- (NSDictionary *)pixelBufferAttributes;
#if COREVIDEO_SUPPORTS_IOSURFACE
- (IOSurfaceRef)currentSurface;
- (IOSurfaceID)currentSurfaceID;
#endif
- (id)currentFrame;
- (id)getFrameAtTime: (NSTimeInterval)aTime;
- (void)releaseFrameQueue;

@end
