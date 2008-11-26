// DTTextBox.h: textbox object

// TO-DO: add color's #rrggbb notation support (needs to beef up NSColor)
// TO-DO: add alpha support
// TO-DO: add background-color support
// TO-DO: add font.weight support
// TO-DO: add size-cjk support (?)
// TO-DO: better dictionary and description methods

// TextBox object in JSON notation:
// {
//     "text": ""
//     "font": {
//         "family": "Helvetica"
//         "family-cjk": "STHeiti"
//         "family-latin": "Helvetica"
//         "size": "10.0"
//     }
//     "align": "left" (left, center, right; default=center)
//     "vertical-align": "top" (top, center, bottom)
//     "color": "black" (black/white/red/.../(#rrggbb notation--not implemented))
//     "rotate": "0.0"
// }

#import <Cocoa/Cocoa.h>
#import "DTElementInterface.h"

enum {
	DTTextBoxLeftAlignment = 0,
	DTTextBoxRightAlignment = 1,
	DTTextBoxCenterAlignment = 2,
	DTTextBoxTopAlignment = 3,
	DTTextBoxBottomAlignment = 4
};

@interface DTTextBox : NSObject
{
	NSMutableAttributedString *_attrStr;
	NSFont *_fontLatin;
	NSFont *_fontCJK;
	int _alignment;
	int _verticalAlignment;
	NSColor *_color;
	float _rotationAngle;
	
	NSRect _boundingRect;
}
+ (DTTextBox*)textBoxWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)bound;
- (DTTextBox*)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)bound;
- (void)dealloc;
- (float)defaultLineHeight;
- (void)setBoundingRect:(NSRect)boundingRect;
- (void)draw;
@end

void DTDrawTextBoxInRect(NSRect boundingRect, NSDictionary *dict);
void DTDrawTextBoxInRectWithAttributes(NSRect boundingRect, 
	NSString *string, NSString *fontFamilyLatin, NSString *fontFamilyCJK,
	float size, NSString *alignment, NSString *verticalAlignment,
	NSString *colorName, float rotateAngle);
