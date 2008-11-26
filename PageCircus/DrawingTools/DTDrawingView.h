/* DTDrawingView */

#import <Cocoa/Cocoa.h>

@interface DTDrawingView : NSView
{
	id _delegate;
	SEL _selector;
	id _argument;
}
- (id)initWithFrame:(NSRect)frame delegate:(id)aDelegate drawingSelector:(SEL)aSelector argument:(id)anArgument;
@end

// helper function
NSData *DTPDFDataByDrawingCallback(NSRect frame, id aDelegate, SEL aSelector, id anArgument);
