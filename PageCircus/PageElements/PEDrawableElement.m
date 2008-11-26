#import "PEDrawableElement.h"
#import "NSExtensions.h"
#import "PENSDictionaryRectExtension.h"

@implementation PEDrawableElement : PEObject
+ (id)elementWithBoundingRect:(NSRect)boundingRect
{
	return [[[PEDrawableElement alloc] initWithBoundingRect:boundingRect] autorelease];
}
- (id)initWithBoundingRect:(NSRect)boundingRect
{
    if (self = [super init]) {
        _boundingRect = boundingRect;
    }
    return self;
}
- (void)dealloc
{
    [super dealloc];
}
- (NSRect)boundingRect
{
    return _boundingRect;
}
- (void)setBoundingRect:(NSRect)boundingRect
{
    _boundingRect = boundingRect;
}
- (NSDictionary*)internalDictionaryRepresentation
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
        @"drawable-element", @"type",
        [NSDictionary dictionaryWithNSRect:_boundingRect], @"bounding-rect",
        nil];
    
    return [[super internalDictionaryRepresentation] dictionaryByMergingDictionary:result];
}
- (BOOL)prepareWithOutputControl:(NSDictionary*)controlData
{
	if (controlData) ;
	return YES;
}
- (void)drawWithOutputControl:(NSDictionary*)controlData
{
    if (controlData && [controlData isKeyTrue:@"debug-mode"]) {
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        [context saveGraphicsState];
        [[NSColor redColor] setStroke];
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:[self className] attributes:
            [NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor], NSForegroundColorAttributeName, nil]];
        [NSBezierPath strokeRect:_boundingRect];
        [str drawAtPoint:_boundingRect.origin];
        [str release];
        [context restoreGraphicsState];
    }
}
@end
