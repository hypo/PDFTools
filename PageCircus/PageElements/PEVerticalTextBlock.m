// PEVerticalTextBlock.m

#import "PEVerticalTextBlock.h"
#import "NSExtensions.h"
#import "PENSColorExtension.h"

UniChar _PENonVerticalCJKChars[] = {0xff5e};
BOOL PEIsNonVerticalCJKCharacter(UniChar c)
{
	size_t i;
	for (i=0;i<sizeof(_PENonVerticalCJKChars);i++) if (c==_PENonVerticalCJKChars[i]) return YES;
	return NO;
}


@interface PETextBlock (PrivateSuperExtensions)
- (void)_superDrawWithOutputControl:(NSDictionary*)controlData;
- (NSDictionary*)_superInternalDictionaryRepresentation;
@end 

@implementation PEVerticalTextBlock : PETextBlock
+ (id)textBlockWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    return [[[PEVerticalTextBlock alloc] initWithDictionary:dict boundingRect:boundingRect] autorelease];
}
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
	if (self = [super initWithDictionary:dict boundingRect:boundingRect]) {
	}
	return self;    
}
- (void)dealloc
{
    [super dealloc];
}
- (NSDictionary*)internalDictionaryRepresentation
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
        @"vertical-text-block", @"type",
        _string, @"text",
        [_font dictionaryRepresentation], @"font",
        _align, @"align",
        _verticalAlign, @"vertical-align",
        _color, @"color",
        _backgroundColor, @"background-color",
        [NSNumber numberWithFloat:_rotationAngle], @"rotate",
        nil];
    
    return [(NSDictionary*)[super _superInternalDictionaryRepresentation] dictionaryByMergingDictionary:result];
}
- (NSSize)drawRange:(NSRange)r ofString:(NSAttributedString*)str startAt:(NSPoint)orig
{
	if (!r.length) return NSMakeSize(0.0, 0.0);
	
	NSAttributedString *substr= [str attributedSubstringFromRange:r];

	[substr drawAtPoint:orig];
	return [substr size];
}

- (void)drawWithOutputControl:(NSDictionary*)controlData
{
    [super _superDrawWithOutputControl:controlData];

	NSDictionary *CJKPunctuationVShift = [controlData objectForKey:@"cjk-vertical-text-punctuation-vshift" defaultValue:[NSDictionary dictionary]];
	NSDictionary *CJKPunctuationHShift = [controlData objectForKey:@"cjk-vertical-text-punctuation-hshift" defaultValue:[NSDictionary dictionary]];
	NSDictionary *CJKCharReplacement = [controlData objectForKey:@"cjk-vertical-text-character-replacement" defaultValue:[NSDictionary dictionary]];

    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    
    // fill the background
	if (!PEIsTransparentColor(_backgroundColor)) {
		[[NSColor colorByName:_backgroundColor] setFill];
		[NSBezierPath fillRect:_boundingRect];
	}

    NSMutableAttributedString *_attrStr = [[NSMutableAttributedString alloc] initWithString:_string];

	NSAffineTransform *transform = [NSAffineTransform transform];
	
	// we use the upper-left corner as the orignin of the vertical text box
	[transform translateXBy:_boundingRect.origin.x yBy:_boundingRect.origin.y+_boundingRect.size.height];
	[transform rotateByDegrees:270.0];
	[transform concat];

	unsigned i, sl = [_string length];
	unsigned start = 0;
	BOOL isCJK = YES;
	    
    NSMutableDictionary *psd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                [_font fontLatin], NSFontAttributeName,
				[NSNumber numberWithFloat:_kerning], NSKernAttributeName,                
                [NSColor colorByName:_color], NSForegroundColorAttributeName, nil];

    // set Latin font and paragraph style
    [_attrStr setAttributes:psd range:NSMakeRange(0, sl)];
	[psd setObject:[NSNumber numberWithFloat:_kerningCJK] forKey:NSKernAttributeName];

	// prepare the CJK style
    [psd setObject:[_font fontCJK] forKey:NSFontAttributeName];

	NSPoint orig=NSMakePoint(0.0, 0.0);
	NSSize size;
	
	for (i = 0; i < sl ; i++) {
		if (PEIsCJKCharacter([_string characterAtIndex:i]) && !PEIsNonVerticalCJKCharacter([_string characterAtIndex:i])) {
			if (!isCJK) {
				isCJK = YES;
				size = [self drawRange:NSMakeRange(start, i-start) ofString:_attrStr startAt:orig];
				orig.x += size.width;
			}
 			
			[_attrStr setAttributes:psd range:NSMakeRange(i, 1)];
			NSAttributedString *substr = [_attrStr attributedSubstringFromRange:NSMakeRange(i, 1)];
			
			id rstr;
			if (rstr = [CJKCharReplacement objectForKey:[substr string]]) {
				substr = [[[NSAttributedString alloc] initWithString:rstr attributes:[substr attributesAtIndex:0 effectiveRange:NULL]] autorelease];
			}
			
			NSAffineTransform *vtr = [NSAffineTransform transform];

			// shift some characters's y (yBy:orig.y) here to adjust the vertical alignment
			float puncOffsetY = 0.0, puncOffsetX = 0.0;
			id vshift;
			if (vshift = [CJKPunctuationVShift objectForKey:[substr string]]) {
				puncOffsetX = [_font size] * [vshift floatValue];
			}

			id hshift;
			if (hshift = [CJKPunctuationHShift objectForKey:[substr string]]) {
				puncOffsetY = [_font size] * [hshift floatValue];
			}

			
			[context saveGraphicsState];
			
			if (puncOffsetX >= 0.0) {
				[vtr translateXBy:orig.x+[substr size].height - 1.0 - puncOffsetX  yBy:orig.y + puncOffsetY];
			}
			else {
				[vtr translateXBy:orig.x+[substr size].height - 1.25 - puncOffsetX  yBy:orig.y + puncOffsetY];
			}
			
			
			[vtr rotateByDegrees:90.0];
			[vtr concat];
			[substr drawAtPoint:NSMakePoint(0.0, 0.0)];
			[context restoreGraphicsState];
			orig.x += [substr size].width;
			orig.x += abs(puncOffsetX);
		}
		else {
			if (isCJK) {
				// after the CJK block, Latin block again, but we need to offset
				// the x axis a bit to make it prettier

				if ([_font size] <= 12.0) {
					orig.x += [_font size]/2.0;
				}
				else if ([_font size] <= 16.0) {
					orig.x += [_font size]/4.0;
				}
				else {
					orig.x += [_font size]/6.0;
				}
				
				isCJK = NO;
				start = i;
			}
		}
	}

	// draw the last section
	if (!isCJK) {
		[self drawRange:NSMakeRange(start, i-start) ofString:_attrStr startAt:orig];
	}

    [_attrStr release];
    [context restoreGraphicsState];
}
- (BOOL)prepareWithOutputControl:(NSDictionary*)controlData
{
	return [super prepareWithOutputControl:controlData];
}
@end


