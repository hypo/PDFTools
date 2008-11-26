#import "PETransform.h"
#import "NSExtensions.h"

@implementation PETransform : PEDrawableElement
+ (id)transformWithDictionary:(NSDictionary*)dict
{
    return [[[PETransform alloc] initWithDictionary:dict] autorelease];
}
- (id)initWithDictionary:(NSDictionary*)dict
{
    NSDictionary *d = dict ? dict : [NSDictionary dictionary];
	if (self = (PETransform*)[super initWithBoundingRect:NSMakeRect(0.0, 0.0, 0.0, 0.0)]) {
		_moveX = [[d objectForKey:@"move-x" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];
		_moveY = [[d objectForKey:@"move-y" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];
		_rotate = [[d objectForKey:@"rotate" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];
	}
	return self;
}
- (void)dealloc
{
    [super dealloc];
}
- (NSDictionary*)internalDictionaryRepresentation
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
        @"transform", @"type",
        [NSNumber numberWithFloat:_moveX], @"move-x",
        [NSNumber numberWithFloat:_moveY], @"move-y",
        [NSNumber numberWithFloat:_rotate], @"rotate",
        nil];
    return [[super internalDictionaryRepresentation] dictionaryByMergingDictionary:result];
}

- (void)drawWithOutputControl:(NSDictionary*)controlData
{
    [super drawWithOutputControl:controlData];
	NSAffineTransform *transform = [NSAffineTransform transform];	
	if (_rotate != 0.0) [transform rotateByDegrees:_rotate];	
	if (_moveX != 0.0 || _moveY != 0.0) [transform translateXBy:_moveX yBy:_moveY];	
	[transform concat];
}
@end

