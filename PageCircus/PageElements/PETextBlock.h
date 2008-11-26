// PETextBlock.h

// TO-DO: add color's #rrggbb notation support (needs to beef up NSColor)
// TO-DO: add alpha support
// TO-DO: add background-color support
// TO-DO: add font.weight support
// TO-DO: add size-cjk support (?)
// TO-DO: better dictionary and description methods

// TextBox object in JSON:
// {
//     "type": "text-block",
//     "text": "",
//     "font": { /* font object */ },
//     "align": "center", /* left, center, right */
//     "vertical-align": "top", /* center, bottom */
//     "color": "black", /* black/white/red/... #rrggbb notation to be implemented */
//     "background-color" : "white",
//     "rotate": "0.0",
//     "bounding-rect": { /* inherited from PEDrawableElement */ },
//	   "kerning" : "0.0",
//	   "kering-cjk" : "0.0",
//     "line-spacing" : "0.0",
// }

#import "PEDrawableElement.h"
#import "PEFont.h"

BOOL PEIsCJKCharacter(UniChar c);

@interface PETextBlock : PEDrawableElement <PEObjectInternalRepresentation, PEDrawableElementDraw>
{
	NSString *_string;
    PEFont *_font;
    NSString *_align;
    NSString *_verticalAlign;
	NSString *_color;
    NSString *_backgroundColor;
	float _rotationAngle;
	float _forceLineHeight;
	float _kerning;
	float _kerningCJK;
	float _lineSpacing;
}
+ (id)textBlockWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (void)dealloc;
- (void)drawWithOutputControl:(NSDictionary*)controlData;
@end
