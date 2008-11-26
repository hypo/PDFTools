// DTTextBox.m: textbox object

#import "DTTextBox.h"
#import "DTUtilities.h"
#import "NSDictionaryExtension.h"

@implementation DTTextBox
+ (DTTextBox*)textBoxWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)bound
{
	return [[[DTTextBox alloc] initWithDictionary:dict boundingRect:bound] autorelease];
}
- (DTTextBox*)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)bound
{
	// NSLog(@"textbox");
	// NSLog([dict description]);
	
	if (self = [super init]) {
		_boundingRect = bound;
	
		NSString *str = [dict objectForKey:@"text" defaultValue:@""];
		_attrStr = [[NSMutableAttributedString alloc] initWithString:str];

		NSDictionary *fontDict = [dict objectForKey:@"font" defaultValue:[NSDictionary dictionary]];		
		NSString *fontFamily = [fontDict objectForKey:@"family" defaultValue:@"GillSans-Bold"];
		NSString *fontFamilyLatin = [fontDict objectForKey:@"family-latin" defaultValue:fontFamily];
		NSString *fontFamilyCJK = [fontDict objectForKey:@"family-cjk" defaultValue:fontFamily];
		float fontSize = [[fontDict objectForKey:@"size" defaultValue:[NSNumber numberWithFloat:10.0]] floatValue];

		#define NI(x) [NSNumber numberWithInt:x]

		// we make use of a perk provided by objectForKey:default:, i.e.,
		// if the key is null, we still get the default value
		NSDictionary *alignmentDict = [NSDictionary dictionaryWithObjectsAndKeys:
			NI(DTTextBoxLeftAlignment), @"left",
			NI(DTTextBoxCenterAlignment), @"center",
			NI(DTTextBoxRightAlignment), @"right", nil];
		NSDictionary *verticalAlignmentDict = [NSDictionary dictionaryWithObjectsAndKeys:
			NI(DTTextBoxTopAlignment), @"top",
			NI(DTTextBoxCenterAlignment), @"center",
			NI(DTTextBoxBottomAlignment), @"bottom", nil];
		
		_alignment = [[alignmentDict objectForKey:[dict objectForKey:@"align"]
			defaultValue:NI(DTTextBoxLeftAlignment)] intValue];
		_verticalAlignment = [[verticalAlignmentDict objectForKey:[dict objectForKey:@"vertical-align"]
			defaultValue:NI(DTTextBoxTopAlignment)] intValue];
			
		NSDictionary *colorDict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor brownColor], @"brown",
			[NSColor clearColor], @"clear",
			[NSColor cyanColor], @"cyan",
			[NSColor darkGrayColor], @"darkgray",
			[NSColor grayColor], @"gray",
			[NSColor greenColor], @"green",
			[NSColor lightGrayColor], @"lightgray",
			[NSColor magentaColor], @"magenta",
			[NSColor orangeColor], @"orange",
			[NSColor purpleColor], @"purple",
			[NSColor redColor], @"red",
			[NSColor whiteColor], @"white", nil];
		_color = [[colorDict objectForKey:[dict objectForKey:@"color"] defaultValue:[NSColor blackColor]] retain];
		
		_fontLatin = [[NSFont fontWithName:fontFamilyLatin size:fontSize] retain];
		_fontCJK = [[NSFont fontWithName:fontFamilyCJK size:fontSize] retain];

		_rotationAngle = [[dict objectForKey:@"rotate" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];
		
		
		// now all value set, we have to do the alignment and CJK font fix
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		switch (_alignment) {
			case DTTextBoxCenterAlignment:
				[paragraphStyle setAlignment:NSCenterTextAlignment];
				break;
			case DTTextBoxRightAlignment:
				[paragraphStyle setAlignment:NSRightTextAlignment];
				break;
			case DTTextBoxLeftAlignment:
			default:
				[paragraphStyle setAlignment:NSLeftTextAlignment];
				break;				
		}

		unsigned int i=0, len=[str length], p=0, q=0;
		BOOL cjkmode = NO;
		
		// set Latin font and paragraph style
		[_attrStr
			setAttributes:
				[NSDictionary dictionaryWithObjectsAndKeys:
					_fontLatin, NSFontAttributeName,
					_color, NSForegroundColorAttributeName,
					paragraphStyle, NSParagraphStyleAttributeName, nil]
			range:NSMakeRange(0, len)];
			
		// set CJK characters with CJK font
		for (i = 0; i < len; i++) {
			UniChar uc = [str characterAtIndex:i];
			if (cjkmode && !DTIsCJKChar(uc)) {
				q = i;
				cjkmode = NO;
				[_attrStr
					setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_fontCJK, NSFontAttributeName, nil]
					range:NSMakeRange(p, q-p+1)];
			}
			else if (!cjkmode && DTIsCJKChar(uc)) {
				p = i;
				cjkmode = YES;
			}
		}
		
		#undef NI
	}
	return self;
}
- (void)dealloc
{
	[_attrStr release];
	[_color release];
	[_fontLatin release];
	[_fontCJK release];
	[super dealloc];
}
- (float)defaultLineHeight
{
	NSLayoutManager *layout = [NSLayoutManager new];
	float fontLatinHeight = [layout defaultLineHeightForFont:_fontLatin];
	float fontCJKHeight = [layout defaultLineHeightForFont:_fontCJK];
	[layout release];
	
	if (fontLatinHeight > fontCJKHeight) return fontLatinHeight;
	return fontCJKHeight;
}
- (void)setBoundingRect:(NSRect)boundingRect
{
	_boundingRect = boundingRect;
}
- (void)draw
{
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];

	NSRect textBound = [_attrStr boundingRectWithSize:_boundingRect.size options:NSStringDrawingUsesLineFragmentOrigin];
	
	// fix the "no center/right alignment" problem
	textBound.size.width = _boundingRect.size.width;
	NSRect drawRect = _boundingRect;
	
	if (_verticalAlignment == DTTextBoxBottomAlignment) {
		drawRect = textBound;
		drawRect.origin.x += _boundingRect.origin.x;
		drawRect.origin.y += _boundingRect.origin.y;
	}
	else if (_verticalAlignment == DTTextBoxCenterAlignment) {
		drawRect = textBound;
		drawRect.origin.x += _boundingRect.origin.x;
		drawRect.origin.y += _boundingRect.origin.y + 
			(_boundingRect.size.height - drawRect.size.height) / 2;
			
		DTLogRect(drawRect);
		// and see if we can rotate
		if (_alignment == DTTextBoxCenterAlignment) {
			if (_rotationAngle != 0.0) {
				NSAffineTransform *transform = [NSAffineTransform transform];
				
				float nx = drawRect.origin.x + drawRect.size.width / 2;
				float ny = drawRect.origin.y + drawRect.size.height / 2;
				[transform translateXBy:nx yBy:ny];
				drawRect.origin.x = -drawRect.size.width / 2;
				drawRect.origin.y = -drawRect.size.height / 2;
				DTLogRect(drawRect);
				
				[transform rotateByDegrees:_rotationAngle];
				[transform concat];
			}
		}
	}
	
	[_attrStr drawWithRect:drawRect options:NSStringDrawingUsesLineFragmentOrigin];
	[context restoreGraphicsState];
	
	// draw the bounding rect--debug only
	// [context saveGraphicsState];
	// [[NSColor redColor] setStroke];
	// [NSBezierPath strokeRect:_boundingRect];
	// [context restoreGraphicsState];
}

// internals, not exposed yet
- (NSDictionary*)dictionary
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[NSValue valueWithRect:_boundingRect], @"bound",
		[_attrStr string], @"text",
		[NSDictionary dictionaryWithObjectsAndKeys:
			_fontLatin, @"family",
			_fontLatin, @"family-latin",
			_fontCJK, @"family-cjk",
			[NSNumber numberWithFloat:[_fontLatin pointSize]], @"size",
			nil], @"font",
		[NSNumber numberWithInt:_alignment], @"align",
		[NSNumber numberWithInt:_verticalAlignment], @"vertical-align",
		_color, @"color",
		[NSNumber numberWithFloat:_rotationAngle], @"rotate",
		nil];
}
- (NSString*)description
{
	return [[self dictionary] description];
}
@end

void DTDrawTextBoxInRect(NSRect boundingRect, NSDictionary *dict)
{
	DTTextBox *t = [[DTTextBox alloc] initWithDictionary:dict boundingRect:boundingRect];
	[t draw];
	[t release];
}

void DTDrawTextBoxInRectWithAttributes(NSRect boundingRect, 
	NSString *string,
	NSString *fontFamilyLatin,
	NSString *fontFamilyCJK,
	float size,
	NSString *alignment,
	NSString *verticalAlignment,
	NSString *colorName,
	float rotateAngle)
{
	NSMutableDictionary *f = [NSMutableDictionary dictionary];
	NSMutableDictionary *d = [NSMutableDictionary dictionary];
	
	// SVE = set value if exists; SVEC = with condition
	#define SVE(d, k, v) do { if (v) [d setObject:v forKey:k]; } while(0)
	#define SVEC(d, c, k, v) do { if (c) [d setObject:v forKey:k]; } while(0)

	SVE(d, @"text", string);
	SVE(f, @"family-latin", fontFamilyLatin);
	SVE(f, @"family-cjk", fontFamilyCJK);
	SVEC(f, (size != 0.0), @"size", [NSNumber numberWithFloat:size]);
	SVE(d, @"font", f);
	SVE(d, @"align", alignment);
	SVE(d, @"vertical-align", verticalAlignment);
	SVE(d, @"color", colorName);
	SVEC(d, (rotateAngle != 0.0), @"rotate", [NSNumber numberWithFloat:rotateAngle]);
	#undef SVE
	#undef SVEC
	
	DTDrawTextBoxInRect(boundingRect, d);
}
