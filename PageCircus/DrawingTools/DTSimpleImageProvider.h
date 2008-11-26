#import <Cocoa/Cocoa.h>
#import "OFHTTPRequest.h"
#import "DTImageProviderInterface.h"

// Objects of this class must be created in the main thread

@interface DTSimpleImageProvider : NSObject <DTImageProvider>
{
	id _delegate;
	NSImage *_img;
	NSURL *_url;
	NSURL *_downloadingURL;
	OFHTTPRequest *_req;
	NSLock *_lock;
	BOOL _hasError;
}
- (id)init;
- (void)dealloc;
- (void)setDelegate:(id)aDelegate;
- (int)imageStatus:(NSURL*)url;
- (NSImage*)useImage:(NSURL*)url;
- (NSLock*)sharedLock;
- (void)startFetchImage:(NSURL*)url;
@end

