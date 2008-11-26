// PagePreviewer.m

#import "PagePreviewer.h"
#import "LFHTTPRequest.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
typedef unsigned int NSUInteger;
typedef int NSInteger;
#define NSUIntegerMax UINT_MAX
#endif

@implementation PagePreviewer
- (BOOL)isRunning
{
	return _isRunning;
}
- (int)errorCode
{
	return _errorCode;
}
- (id)initWithSourceFile:(NSString*)source pageLabel:(NSString*)label resolution:(NSString*)resolution outputFile:(NSString*)output
{
    if (self = [super init]) {
        _lastReceived = 0;
        _image = nil;
		_imageData = nil;
        _lock = [[NSConditionLock alloc] initWithCondition:0];
        NSString *content = [NSString stringWithContentsOfFile:source encoding:NSUTF8StringEncoding error:nil];
        _sourceContent = [[NSDictionary dictionaryWithJSONString:content] retain];
        _pageLabel = [[NSString alloc] initWithString:label];
        _resolution = [resolution floatValue];
        _outputFile = [[NSString alloc] initWithString:output];
		_isRunning = YES;
		_errorCode = 0;
		_currentURLString = [[NSMutableString string] retain];

		_matchReplaceImageData = nil;
		_replacementImageData = nil;
    }
    return self;
}
- (void)dealloc
{
	[_currentURLString release];
	[_lock release];
	[_sourceContent release];
	[_pageLabel release];
	[_outputFile release];
	[_matchReplaceImageData release];
	[_replacementImageData release];
	[super dealloc];
}
- (void)setMatchReplaceImageData:(NSData*)data
{
	NSData *tmp = _matchReplaceImageData;
	_matchReplaceImageData = [data retain];
	[tmp release];
}
- (void)setReplacementImageData:(NSData*)data
{
	NSData *tmp = _replacementImageData;
	_replacementImageData = [data retain];
	[tmp release];
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
    NSData *data = [request receivedData];
	bool replaced = false;
	
	if (_matchReplaceImageData && _replacementImageData) {
		if ([data length] == [_matchReplaceImageData length]) {
			if ([data isEqualTo:_matchReplaceImageData]) {
				NSLog(@"Received image data matches replacement condition, using replacement data");
				replaced = true;
				_imageData = [_replacementImageData copy];
			}
		} else {
			NSLog(@"Using received image data");
		}
	}
	
	if (!replaced)
		_imageData = [data retain];

    _image = [[NSImage alloc] initWithData:_imageData];
    _reqEnded = YES;    
}
- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
    if (error == LFHTTPRequestTimeoutError) {
        NSLog(@"time out!");
        _errorCode = 2;        
    } else {
        NSLog(@"Error! %@", error);
        _errorCode = 1;        
    }
    _reqEnded = YES;
}
- (void)httpRequest:(LFHTTPRequest *)request receivedBytes:(NSUInteger)bytesReceived expectedTotal:(NSUInteger)total
{
    double rB = (double)bytesReceived, lR = (double)_lastReceived;
    // NSLog(@"%d %d", receivedBytes, _lastReceived);

    if ((int)total <=0 || (rB-lR)/(double)total > 0.10) {
        NSLog(@"Received %d bytes (of %d)", bytesReceived, total);
        _lastReceived = bytesReceived;
    }
}
- (void)fetchImage:(NSString*)source
{
    id arp = [NSAutoreleasePool new];
	
	if (_imageData) {
		[_imageData release];
		_imageData = nil;
	}
	
    if (_image) {
        [_image release];
        _image = nil;
    }
    
    NSLog(@"entering thread");
    [_lock lockWhenCondition:0];

    _lastReceived = 0;    
    _reqEnded = NO;
    LFHTTPRequest *req = [[[LFHTTPRequest alloc] init] autorelease];
    [req setDelegate: self];
    [req setTimeoutInterval: 10.0];
	
	[_currentURLString setString:source];
    if (![req performMethod: LFHTTPRequestGETMethod onURL: [NSURL URLWithString: source] withData: nil]) {
        NSLog(@"fatal error!");
        [_lock unlockWithCondition: 1];
        [arp release];
        return;
    }
    
    double resolution = 0.1;
    BOOL isRunning;

    do {
        NSDate* next = [NSDate dateWithTimeIntervalSinceNow:resolution]; 
        isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:next];

    } while (isRunning && !_reqEnded);
    
    // _image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:source]];
    [_lock unlockWithCondition:1];
    NSLog(@"exit thread");
    [arp release];
}
- (NSImage*)useImage:(NSString*)source
{
    NSLog(@"fetching: %@", source);
    [NSThread detachNewThreadSelector:@selector(fetchImage:) toTarget:self withObject:source];    
    [_lock lockWhenCondition:1];
    NSLog(@"image fetched");
    [_lock unlockWithCondition:0];
    return _image;
}
- (NSDictionary*)outputControl
{
    NSString *quality;
    if (_resolution < 160.0) { quality = @"thumbnail";  }
	else if (_resolution < 400.0) { quality = @"small"; }
	else quality = @"medium";
    
    NSDictionary *debug = [NSDictionary dictionaryWithObjectsAndKeys: /* @"true", @"debug-mode", */
		@"preview", @"mode",
        self, @"image-provider", 
        quality, @"image-quality", nil];

	return debug;
}
- (void)draw:(id)arg
{
    // NSLog(@"drawing view");
    [_preparedBook drawElementsOnPageLabelled:arg outputControl:[self outputControl]];
}

- (void)run
{
    id arp = [NSAutoreleasePool new];
	id cache = [NSURLCache sharedURLCache];

    _preparedBook = [[[BMHypoPhotoBook12cmx12cm alloc] initWithInstruction:_sourceContent] autorelease];

    NSRect boundingRect = [_preparedBook boundingRectOfPageLabelled:_pageLabel];
    float w = boundingRect.size.width;
    float h = boundingRect.size.height;
    NSSize imageSize = (w > h) ? NSMakeSize(_resolution * (w/h), _resolution) : NSMakeSize(_resolution, _resolution*(h/w));

    NSRect viewRect;
    viewRect.origin = NSMakePoint(0.0, 0.0);
    viewRect.size = imageSize;

	// prepare image
	[_preparedBook prepareElementsOnPageLabelled:_pageLabel outputControl:[self outputControl]];

    DTDrawingView *v = [[DTDrawingView alloc] initWithFrame:boundingRect delegate:self drawingSelector:@selector(draw:) argument:_pageLabel];
    [v autorelease];

    NSData *d = [v dataWithPDFInsideRect:boundingRect];
    
    NSImage *image = [[NSImage alloc] initWithData:d];
//	[image setCacheMode:NSImageCacheNever];
//	NSLog(@"cache mode = %d", [image cacheMode]);
    [image setScalesWhenResized:YES];
    [image setSize:imageSize];
    [image lockFocus];
    NSBitmapImageRep *output;
    output = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:viewRect] autorelease];
    [image unlockFocus];
    
    float quality = 0.8;
        
    // save as JPEG
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:quality], NSImageCompressionFactor, NULL];        
    NSData *bitmapData = [output representationUsingType:NSJPEGFileType properties:properties];
    [bitmapData writeToFile:_outputFile atomically:YES];
	
	chmod([_outputFile UTF8String], 0644);

    [arp release];
	_isRunning = NO;
}
@end



