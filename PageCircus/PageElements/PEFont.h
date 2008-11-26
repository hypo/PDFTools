// PEFont.h

// JSON representation:

// {
//     "type": "font",
//     "family": "Helvetica",
//     "family-cjk": "STHeiti",
//     "family-latin": "Helvetica",
//     "size": 10.0
// }

#import "PEObject.h"

// by default, PEFont uses Helvetica for Latin characters and
// STHeiti for CJK characters
@interface PEFont : PEObject <PEObjectInternalRepresentation>
{
	NSFont *_fontLatin;
	NSFont *_fontCJK;
	float _size;
	float _CJKSize;
}
+ (id)fontWithDictionary:(NSDictionary*)dictionary;
- (id)initWithDictionary:(NSDictionary*)dictionary;
- (void)dealloc;
- (NSFont*)font;
- (NSFont*)fontLatin;
- (NSFont*)fontCJK;
- (float)size;
- (float)CJKSize;
- (float)defaultLineHeight;
@end

