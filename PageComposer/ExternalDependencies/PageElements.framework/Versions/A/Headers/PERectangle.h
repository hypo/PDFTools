// PERectangle.h

// In JSON:
// {
//    "type":"rectangle",
//    "stroke-color":"black",
//    "line-width":1,
//    "stroke-style":"solid", /* dashed */
//    "fill-color":"black",
//    "bounding-rect":{} /* inherited from PEDrawingElement
// }

#import <Cocoa/Cocoa.h>
#import "PEDrawableElement.h"

@interface PERectangle : PEDrawableElement <PEObjectInternalRepresentation, PEDrawableElementDraw>
{
    NSString *_strokeColor;
    NSString *_strokeStyle;
    NSString *_fillColor;
	float _lineWidth;
}
+ (id)rectangleWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (void)dealloc;
- (void)drawWithOutputControl:(NSDictionary*)controlData;
@end
