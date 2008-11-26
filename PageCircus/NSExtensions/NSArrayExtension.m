// NSArrayExtension.m

#import "NSArrayExtension.h"

@implementation NSArray(NSArrayExtension) 
- (id)useDefaultValue:(id)defaultValue unlessContains:(id)anObject
{
    if ([self containsObject:anObject]) return anObject;
    return defaultValue;
}
/*
- (NSArray*)arrayByMergingArray:(NSArray*)otherArray
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:self];
    if (otherArray) [result addObjectsFromArray:otherArray];
    return [NSArray arrayWithArray:result];
}
*/

@end
