// DTImageProviderInterface.h

#import <Cocoa/Cocoa.h>

enum {
	DTImageNotYetAvailable = 0,
	DTImageReady = 1,
	DTImageFetchError = 2
};

@protocol DTImageProvider <NSObject>
- (int)imageStatus:(NSURL*)url;
- (NSImage*)useImage:(NSURL*)url;

// this returns a shared lock
- (NSLock*)sharedLock;

// this method MUST be called on the main thread
// usde performSelectorOnMainThread:withObject:waitUntilDone: to do it
// (with waitUntilDone: set to YES)
// after the method is performed, a shared NSLock will be locked, 
// the calling thread (the consumer) must wait until it's unlocked.
// NOTA BENE:
// you should still call imageStatus to check if an image is ready
// for consumption, because file transfer may fail
- (void)startFetchImage:(NSURL*)url;

- (void)setDelegate:(id)aDelegate;
@end

@interface NSObject (DTImageProviderDelegate)
- (void)imageProvider:(id<DTImageProvider>)provider progress:(size_t)received expectedTotal:(size_t)total;
@end



