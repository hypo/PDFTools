// PEDrawableElement.h

// In JSON:
// {
//     "type":"drawable-element",
//     "bounding-rect": {
//         "x":0.0,
//         "y":0.0,
//         "w":0.0,
//         "h":0.0
//     }
// }

// output-control block constraints:
//     "debug-mode":false   /* true */

#import "PEObject.h"

@protocol PEDrawableElementDraw
- (BOOL)prepareWithOutputControl:(NSDictionary*)controlData;
- (void)drawWithOutputControl:(NSDictionary*)controlData;
@end

@interface PEDrawableElement : PEObject <PEObjectInternalRepresentation, PEDrawableElementDraw>
{
    NSRect _boundingRect;
}
+ (id)elementWithBoundingRect:(NSRect)boundingRect;
- (id)initWithBoundingRect:(NSRect)boundingRect;
- (void)dealloc;
- (NSRect)boundingRect;
- (void)setBoundingRect:(NSRect)boundingRect;
- (BOOL)prepareWithOutputControl:(NSDictionary*)controlData;
@end

