// PERectangle.m

#import "PERectangle.h"
#import "NSExtensions.h"
#import "PENSColorExtension.h"

@implementation PERectangle : PEDrawableElement
+ (id)rectangleWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    return [[[PERectangle alloc] initWithDictionary:dict boundingRect:boundingRect] autorelease];
    
}
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    NSDictionary *d = dict ? dict : [NSDictionary dictionary];
	if (self = (PERectangle*)[super initWithBoundingRect:boundingRect]) {
		_strokeColor = [[NSString alloc] initWithString:[d objectForKey:@"stroke-color" defaultValue:@"black"]];
		_strokeStyle = [[NSString alloc] initWithString:[d objectForKey:@"stroke-style" defaultValue:@"none"]];
		_fillColor = [[NSString alloc] initWithString:[d objectForKey:@"fill-color" defaultValue:@"none"]];
		_lineWidth = [[d objectForKey:@"line-width" defaultValue:[NSNumber numberWithFloat:1.0]] floatValue];
	}
	return self;
}
- (void)dealloc
{
    [_strokeColor release];
    [_strokeStyle release];
    [_fillColor release];
    [super dealloc];
}
- (NSDictionary*)internalDictionaryRepresentation
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
        @"rectangle", @"type",
        @"red", @"stroke-color",
        _strokeStyle, @"stroke-style",
		[NSNumber numberWithFloat:_lineWidth], @"line-width",
        _fillColor, @"fill-color", nil];
    
    return [[super internalDictionaryRepresentation] dictionaryByMergingDictionary:result];
}
- (void)drawWithOutputControl:(NSDictionary*)controlData
{
    [super drawWithOutputControl:controlData];

    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    
    // fill the background
    [[NSColor colorByName:_fillColor] setFill];
    [[NSColor colorByName:_strokeColor] setStroke];

    NSBezierPath *path;
    
    if (_boundingRect.size.width == 0.0 || _boundingRect.size.height == 0.0) {
        path = [NSBezierPath bezierPath];
        
        [path moveToPoint:_boundingRect.origin];
        [path lineToPoint:NSMakePoint(_boundingRect.origin.x + _boundingRect.size.width,
            _boundingRect.origin.y + _boundingRect.size.height)];
    }
    else {
        path = [NSBezierPath bezierPathWithRect:_boundingRect];
    }
    
    if ([_strokeStyle isEqualToString:@"dash"]) {
        float dashStyle[2] = { 6.0, 4.0 };
        [path setLineDash:dashStyle count:2 phase:0.0];
    }

	[path setLineWidth:_lineWidth];    
    [path fill];
    [path stroke];
    
    [context restoreGraphicsState];
}
@end
