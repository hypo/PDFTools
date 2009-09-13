#import "PagePreviewer.h"
#import "LFHTTPRequest.h"

@interface PageFixer : PagePreviewer
{
	NSConditionLock *resizeLock;
	int _EXIFOrientation;
}
- (id)initWithSourceFile:(NSString*)source pageLabel:(NSString*)label outputFile:(NSString*)output maxResolution:(NSString*)resolution;
- (void)run;
@end


@implementation PageFixer
- (id)initWithSourceFile:(NSString*)source pageLabel:(NSString*)label outputFile:(NSString*)output maxResolution:(NSString*)resolution
{
    if (self = [super initWithSourceFile:source pageLabel:label resolution:resolution outputFile:output]) {
		resizeLock = [[NSConditionLock alloc] initWithCondition:0];
		_EXIFOrientation = 1;
    }
    return self;
}
- (void)dealloc
{
	[resizeLock dealloc];
	[super dealloc];
}
- (void)httpRequestDidComplete: (LFHTTPRequest *)request
{
	_imageData = [[request receivedData] retain];
    _image = [[NSImage alloc] initWithData:_imageData];
    _reqEnded = YES;
	
}
- (NSImage*)useImage:(NSString*)source
{
	NSString *us = source;
	if ([source hasSuffix:@".tif"] || [source hasSuffix:@".tiff"]) {
		us = [NSString stringWithFormat:@"%@?%d", source, random()];
		NSLog(@"applying tiff fix, now URL string = %@", us);
		[super useImage:us];
	}
	else if (getenv("FIXER_USER_ID") != NULL)
	{
		NSLog(@"Found user id: %s, try fetcher.", getenv("FIXER_USER_ID"));
		[super useImage:[NSString stringWithFormat:@"http://fetcher.hypo.cc/fetch?userid=%s&url=%@", getenv("FIXER_USER_ID"), source]];
		if (_image == nil)
		{
			NSLog(@"Fetcher down? Try direct mode.");
			[super useImage:us];
		}
	}
	
	return _image;
}

- (void)draw:(id)arg
{
//	NSLog(@"drawing");
    NSDictionary *control = [NSDictionary dictionaryWithObjectsAndKeys: self, @"image-provider", [NSNumber numberWithFloat:_resolution], @"maximum-longest-side", nil];
    [_preparedBook drawElementsOnPageLabelled:arg outputControl:control];
}

- (void)run
{
    id arp = [NSAutoreleasePool new];
    _preparedBook = [[[BMHypoPhotoBook12cmx12cm alloc] initWithInstruction:_sourceContent] autorelease];
    NSRect boundingRect = [_preparedBook boundingRectOfPageLabelled:_pageLabel];

	// prepare image
    NSDictionary *control = [NSDictionary dictionaryWithObjectsAndKeys: self, @"image-provider", [NSNumber numberWithFloat:_resolution], @"maximum-longest-side", nil];
	[_preparedBook prepareElementsOnPageLabelled:_pageLabel outputControl:control];
	
    DTDrawingView *v = [[[DTDrawingView alloc] initWithFrame:boundingRect delegate:self drawingSelector:@selector(draw:) argument:_pageLabel] autorelease];
    NSData *d = [v dataWithPDFInsideRect:boundingRect];
    NSLog(@"writing pdf size = %d", [d length]);
    [d writeToFile:_outputFile atomically:YES];
//	NSLog(@"Starting to release memory");
    [arp release];
//	NSLog(@"autorelease pool released");
	_isRunning = NO;
//	NSLog(@"no longer running");
}
@end

int main(int argc, char *argv[]) {
	int rsp;
/*
	if (argc < 4) {
		fprintf(stderr, "usage: PageFixer json-source page-label output-filename (max-resolution-in-px)\n");
		return 0;
	}
*/			
	srand(time(0));
	
	NSApplicationLoad();
	id arp = [NSAutoreleasePool new];
    
    fprintf (stderr, "running: %s %s %s %s\n", argv[1], argv[2], argv[3], argc > 4 ? argv[4] : "");
	if (getenv("FIXER_USER_ID") != NULL)
		fprintf(stderr, "detected user_id: %s\n", getenv("FIXER_USER_ID"));

	id ppreview = [[PageFixer alloc] initWithSourceFile:[NSString stringWithUTF8String:argv[1]]
		pageLabel:[NSString stringWithUTF8String:argv[2]]
		outputFile:[NSString stringWithUTF8String:argv[3]]
		maxResolution:(argc > 4 ? [NSString stringWithUTF8String:argv[4]] : @"0.0")];

	
/*	id ppreview = [[PageFixer alloc] initWithSourceFile:@"/Users/Zero/test.js"
											  pageLabel:@"bookcloth"
											 outputFile:@"/Users/Zero/test.pdf"
										  maxResolution:@"1690"];*/
	
	[NSThread detachNewThreadSelector:@selector(run) toTarget:ppreview withObject:nil];

	double resolution = 0.1;
	BOOL isRunning;
	do {
		NSDate* next = [NSDate dateWithTimeIntervalSinceNow:resolution]; 
		isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:next];
//		NSLog(@"event loop running");
	} while (isRunning && [ppreview isRunning]);
	
	rsp = [ppreview errorCode];
	[ppreview release];
	[arp release];
	
	exit(rsp);
}
