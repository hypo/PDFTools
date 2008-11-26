// PEVerticalTextBlock.h

#import "PETextBlock.h"

// VerticalTextBox object in JSON:
// {
//     "type": "vertical-text-block",
//	   /* same as TextBox */
// }

@interface PEVerticalTextBlock : PETextBlock <PEObjectInternalRepresentation, PEDrawableElementDraw>
{
}
+ (id)textBlockWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (void)dealloc;
- (void)drawWithOutputControl:(NSDictionary*)controlData;
@end


