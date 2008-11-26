// BMOutputTestController.m

#import "OutputTestController.h"
#import "BookMaker.h"
#import "DrawingTools.h"
#import "PageElements.h"
#import "NSDictionary+BSJSONAdditions.h"
#import "NSExtensions.h"
#import "LFHTTPRequest.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
typedef unsigned int NSUInteger;
typedef int NSInteger;
#define NSUIntegerMax UINT_MAX
#endif
@implementation OutputTestController
- (void)awakeFromNib 
{
    _lock = [[NSConditionLock alloc] initWithCondition:0];
    _preparedBook = nil;
    _image = nil;
    
	NSString *testfile = [[NSBundle mainBundle] pathForResource:@"BookMakerTests-TestCase01" ofType:@"js"];
    NSString *content = [NSString stringWithContentsOfFile:testfile encoding:NSUTF8StringEncoding error:nil];
    [textView setString:content];
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
    NSLog(@"did fetch data, length=%d bytes, written to /tmp/NSRunLoopStudy.output", [[request receivedData] length]);
    _image = [[NSImage alloc] initWithData: [request receivedData]];
    _reqEnded = YES;
}

- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
    if (error == LFHTTPRequestTimeoutError) {
        NSLog(@"time out!");
    } else {
        NSLog(@"Error! %@", error);
    }
}
- (void)httpRequest:(LFHTTPRequest *)request receivedBytes:(NSUInteger)bytesReceived expectedTotal:(NSUInteger)total
{
    double rB = (double)bytesReceived, lR = (double)_lastReceived;
    
    if ((int)total <=0 || (rB-lR)/(double)total > 0.1) {
        NSLog(@"Request in progress, received %u bytes, expected total %u bytes", bytesReceived, total);
        _lastReceived = bytesReceived;
    }
}

- (void)fetchImage:(NSString*)source
{
    id arp = [NSAutoreleasePool new];

    if (_image) {
        [_image release];
        _image = nil;
    }
    
    // NSLog(@"entering thread");
    [_lock lockWhenCondition:0];

    _lastReceived = 0;    
    _reqEnded = NO;
    LFHTTPRequest *req = [[[LFHTTPRequest alloc] init] autorelease];
    [req setDelegate: self];
    [req setTimeoutInterval: 5.0];
    if (![req performMethod: LFHTTPRequestGETMethod onURL: [NSURL URLWithString: source] withData: nil]) {
        NSLog(@"fatal error!");
        [_lock unlockWithCondition:1];
        [arp release];
        return;
    }
    
    double resolution = 1.0;
    BOOL isRunning;

    do {
        NSDate* next = [NSDate dateWithTimeIntervalSinceNow:resolution]; 
        isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:next];

    } while (isRunning && !_reqEnded);
    
    // _image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:source]];
    [_lock unlockWithCondition:1];
    [arp release];
    // NSLog(@"exit thread");

    
    [arp release];
}
- (NSImage*)useImage:(NSString*)source
{
    NSLog(@"fetching image: %@", source);
    
    [NSThread detachNewThreadSelector:@selector(fetchImage:) toTarget:self withObject:source];
    
    [_lock lockWhenCondition:1];
    // NSLog(@"image fetched");
    [_lock unlockWithCondition:0];
    return _image;
}
- (void)draw:(id)arg
{
    NSDictionary *debug = [NSDictionary dictionaryWithObjectsAndKeys:/* @"true", @"debug-mode", */
        self, @"image-provider", nil];
    [_preparedBook drawElementsOnPageLabelled:arg outputControl:[[_preparedBook outputControl] dictionaryByMergingDictionary:debug]];
}

- (IBAction)runAction:(id)sender
{
    NSDictionary *dict = [NSDictionary dictionaryWithJSONString:[[textView textStorage] string]];
    NSLog([dict description]);
    // NSLog([dict description]);

    _preparedBook = [[BMHypoPhotoBook12cmx12cm alloc] initWithInstruction:dict];
    // NSLog([hypo description]);

    NSArray *labels = [_preparedBook allPageLabels];
    unsigned i, c=[labels count];
    
    for (i=0; i<c; i++) {
        id arp = [NSAutoreleasePool new];
        NSString *label = [labels objectAtIndex:i];
        NSString *pdfFilename = [NSString stringWithFormat:@"/tmp/outputtest-%@.pdf", label];
        
        NSData *pdf = DTPDFDataByDrawingCallback(
            [_preparedBook boundingRectOfPageLabelled:label],
            self, @selector(draw:), label);

        NSLog(@"page %@ pdf size %d", label, [pdf length]);
        [pdf writeToFile:pdfFilename atomically:YES];
        [arp release];
    }    
/*    
    [[[[NSAppleScript alloc] initWithSource:
        @"tell application \"Preview\" to close window \"FOOBAR-drawingtest-test.pdf (1 page)\""] 
            autorelease] executeAndReturnError:nil];

    id test = [DrawingTest new];
    NSData *pdf = DTPDFDataByDrawingCallback(DTMakeRectWithSizeInCM(15.0, 15.0), test, @selector(draw:), nil);
    [pdf writeToFile:[@"/tmp/FOOBAR-drawingtest-test.pdf" stringByStandardizingPath] atomically:YES];    
    [test release];
    
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/FOOBAR-drawingtest-test.pdf"];
    
    NSImage *image = [[[NSImage alloc] initWithSize:DTMakeRectWithSizeInCM(15.0, 15.0).size] autorelease];
    NSBitmapImageRep *output;

    [image lockFocus];
    [test draw:nil];
    output = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:DTMakeRectWithSizeInCM(15.0, 15.0)] autorelease];

    [image unlockFocus];
    
    float quality = 0.5;
    
    // save as JPEG
    NSDictionary *properties =
        [NSDictionary dictionaryWithObjectsAndKeys:
	    [NSNumber numberWithFloat:quality],
	    NSImageCompressionFactor, NULL];    
    
    NSData *bitmapData = [output representationUsingType:NSJPEGFileType
				      properties:properties];

    [bitmapData writeToFile:@"/Users/lukhnos/Desktop/test.jpg" atomically:YES];
    
    */
}

@end
