// NSArrayExtension.h

#import <Cocoa/Cocoa.h>

@interface NSArray(NSArrayExtension)
- (id)useDefaultValue:(id)defaultValue unlessContains:(id)anObject;
// redudant!
// - (NSArray*)arrayByMergingArray:(NSArray*)otherArray;
@end
