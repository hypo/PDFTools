// PETextBlock.m

#import "PETextBlock.h"
#import "PENSColorExtension.h"

UniChar _PECJKChars[] = {0x2013, 0x2014, 0x2025, 0x2026, 0x22ee, 0x22ef, 0x2500, 0x2502, 0x2048, 0x2049};
BOOL PEIsCJKCharacter(UniChar c)
{
	if (c >= 0x2e80) return YES;
	size_t i;
	for (i=0;i<sizeof(_PECJKChars);i++) if (c==_PECJKChars[i]) return YES;
	return NO;
}

@implementation PETextBlock : PEDrawableElement
+ (id)textBlockWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    return [[[PETextBlock alloc] initWithDictionary:dict boundingRect:boundingRect] autorelease];
}
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    NSDictionary *d = dict ? dict : [NSDictionary dictionary];
	if (self = (PETextBlock*)[super initWithBoundingRect:boundingRect]) {
		_string = [[NSString alloc] initWithString:[d objectForKey:@"text" defaultValue:@""]];
        _font = [[PEFont fontWithDictionary:[d objectForKey:@"font"]] retain];
        _align = [[NSString alloc] initWithString:
            [[NSArray arrayWithObjects:@"left", @"right", @"center", nil] useDefaultValue:@"left" unlessContains:
                [d objectForKey:@"align"]]];
        _verticalAlign = [[NSString alloc] initWithString:
            [[NSArray arrayWithObjects:@"top", @"bottom", @"center", nil] useDefaultValue:@"top" unlessContains:
                [d objectForKey:@"vertical-align"]]];
        _color = [[NSString alloc] initWithString:[d objectForKey:@"color" defaultValue:@"black"]];
        _backgroundColor = [[NSString alloc] initWithString:[d objectForKey:@"background-color" defaultValue:@"none"]];
		_rotationAngle = [[d objectForKey:@"rotate" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];
		_forceLineHeight = [[d objectForKey:@"force-lineheight" defaultValue:[NSNumber numberWithFloat:-1.0]] floatValue];
		_kerning = [[d objectForKey:@"kerning" defaultValue:[NSNumber numberWithFloat:0.5]] floatValue];
		_kerningCJK = [[d objectForKey:@"kerning-cjk" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];		
		_lineSpacing = [[d objectForKey:@"line-spacing" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];
		_ligature = [[d objectForKey:@"ligature" defaultValue:[NSNumber numberWithInt:0]] intValue];
	}
	return self;    
}
- (void)dealloc
{
    [_string release];
    [_font release];
    [_align release];
    [_verticalAlign release];
    [_color release];
    [_backgroundColor release];
    [super dealloc];
}
- (NSDictionary*)internalDictionaryRepresentation
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
        @"text-block", @"type",
        _string, @"text",
        [_font dictionaryRepresentation], @"font",
        _align, @"align",
        _verticalAlign, @"vertical-align",
        _color, @"color",
        _backgroundColor, @"background-color",
        [NSNumber numberWithFloat:_rotationAngle], @"rotate",
		[NSNumber numberWithFloat:_forceLineHeight], @"force-lineheight",
		[NSNumber numberWithFloat:_lineSpacing], @"line-spacing",
		[NSNumber numberWithInt:_ligature], @"ligature",
        nil];
    
    return [[super internalDictionaryRepresentation] dictionaryByMergingDictionary:result];
}
- (NSDictionary*)_superInternalDictionaryRepresentation
{
	return [super internalDictionaryRepresentation];
}
- (void)_superDrawWithOutputControl:(NSDictionary*)controlData
{
    [super drawWithOutputControl:controlData];
}
- (NSAttributedString *)attributedString;
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_string];
	
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle new] autorelease];
	if ([_align isEqualToString:@"center"]) {
        [paragraphStyle setAlignment:NSCenterTextAlignment];
    } else if ([_align isEqualToString:@"right"]) {
        [paragraphStyle setAlignment:NSRightTextAlignment];
    } else {
        [paragraphStyle setAlignment:NSLeftTextAlignment];
    }
	
	if (_forceLineHeight > 0.0) {
		[paragraphStyle setMinimumLineHeight:_forceLineHeight];
		[paragraphStyle setMaximumLineHeight:_forceLineHeight];
	}
	
	if (_lineSpacing > 0.0)
		[paragraphStyle setLineSpacing:_lineSpacing];
	
    unsigned int i=0, len=[_string length], p=0, q=0;
    BOOL cjkmode = NO;
    
    NSMutableDictionary *psd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								[_font fontLatin], NSFontAttributeName,
								[NSColor colorByName:_color], NSForegroundColorAttributeName,
								paragraphStyle, NSParagraphStyleAttributeName,
								[NSNumber numberWithFloat:_kerning], NSKernAttributeName,
								nil];
    
	// set ligature
	[psd setObject:[NSNumber numberWithInt:_ligature] forKey: NSLigatureAttributeName];
	
    // set Latin font and paragraph style
    [attrStr setAttributes:psd range:NSMakeRange(0, len)];
	
    [psd setObject:[_font fontCJK] forKey:NSFontAttributeName];
	[psd setObject:[NSNumber numberWithFloat:_kerningCJK] forKey:NSKernAttributeName];
	
    // set CJK characters with CJK font
    for (i = 0; i < len; i++) {
        UniChar uc = [_string characterAtIndex:i];
        if (cjkmode && !PEIsCJKCharacter(uc)) {
            q = i;
            cjkmode = NO;
            [attrStr setAttributes:psd range:NSMakeRange(p, q-p)];
        }
        else if (!cjkmode && PEIsCJKCharacter(uc)) {
            p = i;
            cjkmode = YES;
        }
    }
    
    // if the whole line is CJK text, but the loop is already ended
    if (cjkmode) {
        q = i;
        cjkmode = NO;
        [attrStr setAttributes:psd range:NSMakeRange(p, q-p)];
    }
	
	// cancel the kerning for the last character
	if ([_string length] > 0) {
		NSMutableDictionary *fixAttr = [[attrStr attributesAtIndex:([_string length] - 1) effectiveRange:NULL] mutableCopy];
		[fixAttr setObject:[NSNumber numberWithFloat:0] forKey:NSKernAttributeName];
		[attrStr setAttributes:fixAttr range:NSMakeRange([_string length] - 1, 1)];
	}
	return [attrStr autorelease];
}
- (BOOL) fitInsideWithAutowrap: (BOOL)autowrap
{
	NSRect resultRect = NSZeroRect;
	if (autowrap) 
		resultRect = [[self attributedString] boundingRectWithSize: NSMakeSize(_boundingRect.size.width, 0) options: NSStringDrawingUsesLineFragmentOrigin];
	else
		resultRect = [[self attributedString] boundingRectWithSize: NSMakeSize(0, 0) options: NSStringDrawingUsesLineFragmentOrigin];
	
	return (resultRect.size.width <= _boundingRect.size.width) && (resultRect.size.height <= _boundingRect.size.height);
}
- (void)drawWithOutputControl:(NSDictionary*)controlData
{
    [super drawWithOutputControl:controlData];

    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
	
    // fill the background
	if (!PEIsTransparentColor(_backgroundColor)) {
		[[NSColor colorByName:_backgroundColor] setFill];
		[NSBezierPath fillRect:_boundingRect];
	}

    NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithAttributedString: [self attributedString]] autorelease];

	NSRect textBound = [attrStr boundingRectWithSize:_boundingRect.size options:NSStringDrawingUsesLineFragmentOrigin];
	
	// fix the "no center/right alignment" problem
	textBound.size.width = _boundingRect.size.width;
	NSRect drawRect = _boundingRect;
	
	if ([_verticalAlign isEqualToString:@"bottom"]) {
		drawRect = textBound;
		drawRect.origin.x += _boundingRect.origin.x;
		drawRect.origin.y += _boundingRect.origin.y;
	}
	else if ([_verticalAlign isEqualToString:@"center"]) {
		drawRect = textBound;
		drawRect.origin.x += _boundingRect.origin.x;
		drawRect.origin.y += _boundingRect.origin.y + 
			(_boundingRect.size.height - drawRect.size.height) / 2;
			
		// and see if we can rotate
		if ([_align isEqualToString:@"center"]) {
			if (_rotationAngle != 0.0) {
				NSAffineTransform *transform = [NSAffineTransform transform];
				
				float nx = drawRect.origin.x + drawRect.size.width / 2;
				float ny = drawRect.origin.y + drawRect.size.height / 2;
				[transform translateXBy:nx yBy:ny];
				drawRect.origin.x = -drawRect.size.width / 2;
				drawRect.origin.y = -drawRect.size.height / 2;
				
				[transform rotateByDegrees:_rotationAngle];
				[transform concat];
			}
		}
		else if ([_align isEqualToString:@"left"]) {
			if (_rotationAngle != 0.0) {
				NSAffineTransform *transform = [NSAffineTransform transform];
				
				float nx = drawRect.origin.x + drawRect.size.width / 2;
				float ny = drawRect.origin.y + drawRect.size.height / 2;
				[transform translateXBy:nx yBy:ny];
				drawRect.origin.x = 0;
				drawRect.origin.y = -drawRect.size.height / 2;
				
				[transform rotateByDegrees:_rotationAngle];
				[transform concat];
			}
		}
	}
	
	[attrStr drawWithRect:drawRect options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingDisableScreenFontSubstitution];
    [context restoreGraphicsState];
}
- (BOOL)prepareWithOutputControl:(NSDictionary*)controlData
{
	return [super prepareWithOutputControl:controlData];
}
@end