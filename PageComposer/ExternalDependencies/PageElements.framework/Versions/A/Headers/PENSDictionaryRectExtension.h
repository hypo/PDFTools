// PENSDictionaryRectExtension.h

#import <Cocoa/Cocoa.h>

@interface NSDictionary(NSDictionaryRectExtension) 
+ (NSDictionary*)dictionaryWithNSRect:(NSRect)rect;
- (NSRect)NSRect;
@end
