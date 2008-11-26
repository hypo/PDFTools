// PEObject.m

#import "PEObject.h"

@implementation PEObject : NSObject
- (NSDictionary*)dictionaryRepresentation
{
    return [self internalDictionaryRepresentation];
}

- (NSString*)description
{
    return [[self dictionaryRepresentation] description];
}
- (NSDictionary*)internalDictionaryRepresentation
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"page-element", @"type", nil];
}
@end
