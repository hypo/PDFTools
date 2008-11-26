// PEObject.h

#import <Cocoa/Cocoa.h>

// child classes of PEObject must implement this
@protocol PEObjectInternalRepresentation
- (NSDictionary*)internalDictionaryRepresentation;
@end

@interface PEObject : NSObject <PEObjectInternalRepresentation>
{
}
- (NSDictionary*)dictionaryRepresentation;
- (NSString*)description;
@end
