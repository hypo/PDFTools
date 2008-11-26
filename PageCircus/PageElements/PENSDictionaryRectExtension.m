// PENSDictionaryRectExtension.m

#import "PENSDictionaryRectExtension.h"
#import "NSExtensions.h"

@implementation NSDictionary(NSDictionaryRectExtension)
+ (NSDictionary*)dictionaryWithNSRect:(NSRect)rect
{
    #define FL(x) [NSNumber numberWithFloat:x]
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
        FL(rect.origin.x), @"x",
        FL(rect.origin.y), @"y",
        FL(rect.size.width), @"w",
        FL(rect.size.height), @"h",
        nil];
    
    #undef FL
}
- (NSRect)NSRect
{
    #define OTOF(x) (x ? ([x isKindOfClass:[NSNumber class]] ? [x floatValue] : 0.0) : 0.0)
 
    return NSMakeRect(OTOF([self objectForKey:@"x"]), OTOF([self objectForKey:@"y"]),
        OTOF([self objectForKey:@"w"]), OTOF([self objectForKey:@"h"]));   
    
    #undef OTOF
}
@end
