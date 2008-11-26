#import <Cocoa/Cocoa.h>
#import "DTSimpleImageProvider.h"

@implementation DTSimpleImageProvider
- (id)init
{
	if ((self = [super init])) {
		_delegate = nil;
		_img = nil;
		_url = nil;
		_downloadingURL = nil;
		_req = [[OFHTTPRequest requestWithDelegate:self timeoutInterval:OFHTTPDefaultTimeoutInterval] retain];
		_lock = [[NSLock alloc] init];
		_hasError = NO;
	}
	return self;
}
- (void)dealloc
{
	if (_delegate) [_delegate release];
	if (_url) [_url release];
	if (_downloadingURL) [_downloadingURL release];
	if (_img) [_img release];
	[_req release];
	[_lock release];
	[super dealloc];
}
- (void)setDelegate:(id)aDelegate
{
	if (_delegate) [_delegate release];
	_delegate = [aDelegate retain];
}
- (int)imageStatus:(NSURL*)url
{
	if (_url) {
		if ([_url isEqualTo:url]) {
			NSLog(@"Image ready");
			return DTImageReady;
		}
	}
	if (_hasError) return DTImageFetchError;
	return DTImageNotYetAvailable;
}
- (NSImage*)useImage:(NSURL*)url
{
	if (_url) {
		NSLog(@"Image already in store, retuning the image");
		if ([_url isEqualTo:url]) return _img;
	}
	return nil;
}
- (NSLock*)sharedLock
{
	return _lock;
}
- (void)internalFetch:(NSURL*)url
{
	if (![_lock tryLock]) {
		// d'oh!
		_hasError = YES;
		return;
	}
	
	// enter critical section
	if (_url) {
		[_url release];
		_url = nil;
	}

	if (_downloadingURL) {
		[_downloadingURL release];
		_downloadingURL = nil;
	}

	// the clone is already retained
	_downloadingURL = [url copy];

	_hasError = NO;
	if (_img) {
		[_img release];
		_img = nil;
	}

	// see if it's a file
	if ([_downloadingURL isFileURL]) {
		NSLog(@"loading from file: %@", [_downloadingURL absoluteString]);
		_img = [[NSImage alloc] initWithContentsOfURL:_downloadingURL];
		[_lock unlock];
		
		if (_img) {
			_url = _downloadingURL;
			_downloadingURL = nil;
			return;
		}
		_hasError = YES;
		[_downloadingURL release];
		_downloadingURL = nil;
	}
		
	if (![_req GET:[_downloadingURL absoluteString] userInfo:nil]) {
		[_lock unlock];
		[_downloadingURL release];
		_downloadingURL = nil;
		_hasError = YES;
		return;
	}
}

- (void)startFetchImage:(NSURL*)url
{
	if (_url) {
		if ([_url isEqualTo:url]) return;
	}

	[self performSelectorOnMainThread:@selector(internalFetch:) withObject:url waitUntilDone:YES];

}
- (void)HTTPRequest:(OFHTTPRequest*)request didCancel:(id)userinfo
{
	_hasError = YES;
	[_downloadingURL release];
	_downloadingURL = nil;
	[_lock unlock];
}
- (void)HTTPRequest:(OFHTTPRequest*)request didFetchData:(NSData*)data userInfo:(id)userinfo
{
	_img = [[NSImage alloc] initWithData:data];
	_url = _downloadingURL;
	_downloadingURL = nil;
	[_lock unlock];
}
- (void)HTTPRequest:(OFHTTPRequest*)request didTimeout:(id)userinfo
{
	_hasError = YES;
	[_downloadingURL release];
	_downloadingURL = nil;
	[_lock unlock];
}
- (void)HTTPRequest:(OFHTTPRequest*)request error:(NSError*)err userInfo:(id)userinfo
{
	_hasError = YES;
	[_downloadingURL release];
	_downloadingURL = nil;
	[_lock unlock];
}
- (void)HTTPRequest:(OFHTTPRequest*)request progress:(size_t)receivedBytes expectedTotal:(size_t)total userInfo:(id)userinfo
{
	if ([_delegate respondsToSelector:@selector(imageProvider:progress:expectedTotal:)]) {
		[_delegate imageProvider:self progress:receivedBytes expectedTotal:total];
	}
}
@end