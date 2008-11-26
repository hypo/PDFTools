#import "DTDrawingView.h"

@implementation DTDrawingView
- (id)initWithFrame:(NSRect)frame delegate:aDelegate drawingSelector:(SEL)aSelector argument:(id)anArgument
{
	if ((self = [super initWithFrame:frame]) != nil) {
		// NSLog(@"Drawing view created, frame size=(%f, %f)", frame.size.width, frame.size.height);
		_delegate = [aDelegate retain];
		_selector = aSelector;
		_argument = [anArgument retain];
	}
	return self;
}
- (void)dealloc
{
	// NSLog(@"Drawing view deleted");
	[_delegate release];
	[_argument release];
	[super dealloc];
}
- (void)drawRect:(NSRect)rect
{
	[_delegate performSelector:_selector withObject:_argument];
}
@end

NSData *DTPDFDataByDrawingCallback(NSRect frame, id aDelegate, SEL aSelector, id anArgument)
{
	DTDrawingView *dv = [[DTDrawingView alloc] initWithFrame:frame delegate:aDelegate
		drawingSelector:aSelector argument:anArgument];
	NSData *pdfdata = [dv dataWithPDFInsideRect:frame];
	// NSLog(@"generated PDF data length=%d", [pdfdata length]);
	[dv release];
	return pdfdata;
}
