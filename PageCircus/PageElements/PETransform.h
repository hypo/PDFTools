// PETransform.h

// In JSON:
// {
//     "type":"transform",
//	   "move-x": 0.0,
//	   "move-y": 0,0,
//	   "rotate": 0.0
// }

#import "PEDrawableElement.h"

@interface PETransform : PEDrawableElement <PEObjectInternalRepresentation, PEDrawableElementDraw>
{
	float _moveX, _moveY;
	float _rotate;
}
+ (id)transformWithDictionary:(NSDictionary*)dict;
- (id)initWithDictionary:(NSDictionary*)dict;
- (void)dealloc;
- (void)drawWithOutputControl:(NSDictionary*)controlData;
@end

