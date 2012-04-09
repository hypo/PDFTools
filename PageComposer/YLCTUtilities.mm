//
//  YLCUtilities.m
//  PageComposer
//
//  Created by Yung-Luen Lan on 3/26/12.
//  Copyright (c) 2012 yllan@me.com. All rights reserved.
//

#import "YLCTUtilities.h"

static int HexValue(char c) {
	if ('0' <= c && c <= '9')
		return c - '0';
	if ('a' <= c && c <= 'f')
		return 10 + c - 'a';
	if ('A' <= c && c <= 'F')
		return 10 + c - 'A';
	return 0;
}

@implementation NSColor(PEColorByName)
+ (NSColor*)colorByName:(NSString*)name
{
	// 0xRRGGBB in hex.
	if ([name hasPrefix: @"0x"] && [name length] == 8) {
		const char *cString = [name UTF8String];
		CGFloat r = 16 * HexValue(cString[2]) + HexValue(cString[3]);
		CGFloat g = 16 * HexValue(cString[4]) + HexValue(cString[5]);
		CGFloat b = 16 * HexValue(cString[6]) + HexValue(cString[7]);
        
		return [NSColor colorWithDeviceRed: r / 255.0 green: g / 255.0 blue: b / 255.0 alpha: 1.0];
	}
	
	if ([name hasPrefix: @"CMYK:"])
	{
		NSString* strColor = [name substringFromIndex: 5];
		NSMutableArray* comps = [[[strColor componentsSeparatedByString:@","] mutableCopy] autorelease];
		for(NSString *s in comps)
			s = [s stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if ([comps count] == 4)
			[comps addObject:@"1.0"];
		
		if ([comps count] == 5)		
			return [NSColor colorWithDeviceCyan:[[comps objectAtIndex:0] floatValue] magenta:[[comps objectAtIndex:1] floatValue] yellow:[[comps objectAtIndex:2] floatValue] black:[[comps objectAtIndex:3] floatValue] alpha:[[comps objectAtIndex:4] floatValue]];
	}
	
    NSDictionary *colorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSColor clearColor], @"clear",
                               [NSColor clearColor], @"transparent",
                               [NSColor clearColor], @"none",
                               [NSColor brownColor], @"brown",
                               [NSColor cyanColor], @"cyan",
                               [NSColor darkGrayColor], @"darkgray",
                               [NSColor grayColor], @"gray",
                               [NSColor greenColor], @"green",
                               [NSColor lightGrayColor], @"lightgray",
                               [NSColor magentaColor], @"magenta",
                               [NSColor orangeColor], @"orange",
                               [NSColor purpleColor], @"purple",
                               [NSColor blueColor], @"blue",
                               [NSColor redColor], @"red",
                               [NSColor yellowColor], @"yellow",
                               [NSColor whiteColor], @"white", 
                               [NSColor colorWithDeviceCyan:0.0 magenta:0.0 yellow:0.0 black:0.5 alpha:1.0], @"50K",
                               [NSColor colorWithDeviceCyan:0.0 magenta:0.13 yellow:0.90 black:0.0 alpha:1.0], @"cheese",
                               [NSColor colorWithDeviceCyan:0.35 magenta:0.0 yellow:1.0 black:0.0 alpha:1.0], @"grass",
                               [NSColor colorWithDeviceCyan:0 magenta:0.09 yellow:0.5 black:0.24 alpha:1.0], @"chestnut",
                               [NSColor colorWithDeviceCyan:0.32 magenta:0 yellow:1.0 black:0.79 alpha:1.0], @"darkgreen",
                               [NSColor colorWithDeviceCyan:0.27 magenta:0 yellow:0.95 black:0.55 alpha:1.0], @"olive",
                               [NSColor colorWithDeviceCyan:0 magenta:0.90 yellow:0.86 black:0 alpha:1.0], @"christmasred",
                               [NSColor colorWithDeviceCyan:0.1 magenta:0.1 yellow:0.1 black:1.0 alpha:1.0], @"hypo-black",
                               [NSColor colorWithDeviceCyan:0.1 magenta:0.1 yellow:0.1 black:0.6 alpha:1.0], @"hypo-lightgray",
                               [NSColor colorWithDeviceCyan:0.05 magenta:0.05 yellow:0.05 black:0.3 alpha:1.0], @"hypo-ticketgray",
                               nil];
    return [colorDict objectForKey:name] ?: [NSColor colorWithDeviceCyan:0.0 magenta:0.0 yellow:0.0 black:1.0 alpha:1.0];
}
@end

UniChar _PECJKChars[] = {0x2013, 0x2014, 0x2025, 0x2026, 0x22ee, 0x22ef, 0x2500, 0x2502, 0x2048, 0x2049};
BOOL isCJK(UniChar c)
{
	if (c >= 0x2e80) return YES;
	size_t i;
	for (i=0;i<sizeof(_PECJKChars);i++) if (c==_PECJKChars[i]) return YES;
	return NO;
}

NSAttributedString *attributedStringWithOptions(NSString *text, NSDictionary *options)
{
    NSString *fontFamilyCJK = [options objectForKey: @"TypefaceCJK"] ?: @"HiraginoSansGB-W3";
    NSString *fontFamilyLatin = [options objectForKey: @"Typeface"] ?: @"Helvetica";
    NSString *fontFamilySubstitution = [options objectForKey: @"TypefaceSubstitution"] ?: @"STHeitiTC-Light";
    
    CGFloat fontSizeCJK = [([options objectForKey: @"FontSizeCJK"] ?: [NSNumber numberWithFloat: 12.0]) floatValue];
    CGFloat fontSizeLatin = [([options objectForKey: @"FontSize"] ?: [NSNumber numberWithFloat: 12.0]) floatValue];
    CGFloat fontSizeSubstitution = [([options objectForKey: @"FontSizeSubstitution"] ?: [NSNumber numberWithFloat: 12.0]) floatValue];
    
    NSFont *fontCJK = [NSFont fontWithName: fontFamilyCJK size: fontSizeCJK];
    NSFont *fontLatin = [NSFont fontWithName: fontFamilyLatin size: fontSizeLatin];
    NSFont *fontSubstitution = [NSFont fontWithName: fontFamilySubstitution size: fontSizeSubstitution];

    NSString *align = [options objectForKey: @"TextAlign"] ?: @"left"; // [left|center|right]
    NSString *verticalAlign = [options objectForKey: @"TextVerticalAlign"] ?: @"top"; // [top|center|bottom]

    NSString *colorName = [options objectForKey: @"Color"] ?: @"black";
    NSString *backgroundColorName = [options objectForKey: @"BackgroundColor"] ?: @"transparent";
    
    CGFloat kerningLatin = [([options objectForKey: @"Kerning"] ?: [NSNumber numberWithFloat: 0.5]) floatValue];
    CGFloat kerningCJK = [([options objectForKey: @"KerningCJK"] ?: [NSNumber numberWithFloat: 0.0]) floatValue];

    CGFloat lineSpacing = [([options objectForKey: @"LineSpacing"] ?: [NSNumber numberWithFloat: 0.0]) floatValue];
    CGFloat lineHeight = [([options objectForKey: @"LineHeight"] ?: [NSNumber numberWithFloat: -1.0]) floatValue];
    int ligature = [([options objectForKey: @"Ligature"] ?: [NSNumber numberWithInt: 1]) intValue];

    NSString *symbolSubstitution = [options objectForKey: @"SymbolSubstitution"];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString: text];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle new] autorelease];
	if ([align isEqualToString: @"center"]) {
        [paragraphStyle setAlignment: NSCenterTextAlignment];
    } else if ([align isEqualToString: @"right"]) {
        [paragraphStyle setAlignment: NSRightTextAlignment];
    } else {
        [paragraphStyle setAlignment: NSLeftTextAlignment];
    }
	
	if (lineHeight > 0.0) {
		[paragraphStyle setMinimumLineHeight: lineHeight];
		[paragraphStyle setMaximumLineHeight: lineHeight];
	}
	
	if (lineSpacing > 0.0)
		[paragraphStyle setLineSpacing: lineSpacing];

    unsigned int i=0, len=[text length], p=0, q=0;
    BOOL cjkmode = NO;
    
    NSMutableDictionary *psd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								fontLatin, NSFontAttributeName,
								[NSColor colorByName: colorName], NSForegroundColorAttributeName,
								paragraphStyle, NSParagraphStyleAttributeName,
								[NSNumber numberWithFloat: kerningLatin], NSKernAttributeName,
								nil];
	// set ligature
	[psd setObject:[NSNumber numberWithInt: ligature] forKey: NSLigatureAttributeName];
    
    // set Latin font and paragraph style
    [attrString setAttributes: psd range: NSMakeRange(0, len)];
	
    [psd setObject: fontCJK forKey: NSFontAttributeName];
	[psd setObject:[NSNumber numberWithFloat: kerningCJK] forKey: NSKernAttributeName];
    
    // set CJK characters with CJK font
    for (i = 0; i < len; i++) {
        UniChar uc = [text characterAtIndex:i];
        if (cjkmode && !isCJK(uc)) {
            q = i;
            cjkmode = NO;
            [attrString setAttributes: psd range: NSMakeRange(p, q-p)];
        }
        else if (!cjkmode && isCJK(uc)) {
            p = i;
            cjkmode = YES;
        }
    }
    
    // if the whole line is CJK text, but the loop is already ended
    if (cjkmode) {
        q = i;
        cjkmode = NO;
        [attrString setAttributes: psd range: NSMakeRange(p, q-p)];
    }
	
	// cancel the kerning for the last character
	if ([text length] > 0) {
		NSMutableDictionary *fixAttr = [[attrString attributesAtIndex:([text length] - 1) effectiveRange:NULL] mutableCopy];
		[fixAttr setObject: [NSNumber numberWithFloat:0] forKey: NSKernAttributeName];
		[attrString setAttributes: fixAttr range: NSMakeRange([text length] - 1, 1)];
	}
    
    if (symbolSubstitution) {
        NSString *haystack = [attrString string];
        [symbolSubstitution enumerateSubstringsInRange: NSMakeRange(0, [symbolSubstitution length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *needle, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            
            NSRange searchRange = NSMakeRange(0, [haystack length]);
            NSRange matchedRange = NSMakeRange(NSNotFound, 0);
            while ((matchedRange = [haystack rangeOfString: needle options: 0 range: searchRange]).location != NSNotFound) {
                [attrString addAttribute: NSFontAttributeName value: fontSubstitution range: matchedRange];
                searchRange = NSMakeRange(matchedRange.location + matchedRange.length, [haystack length] - matchedRange.location - matchedRange.length);
            }
        }];
    }
	return [attrString autorelease];
}

CTFrameRef createCTFrame(CFAttributedStringRef text, CGRect boundingRect, BOOL vertical)
{
    CGRect transformedBoundingRect = boundingRect;
    if (vertical) {
        transformedBoundingRect.origin.x = CGRectGetMaxX(boundingRect) - CGRectGetHeight(boundingRect);
        transformedBoundingRect.origin.y = CGRectGetMaxY(boundingRect) - CGRectGetWidth(boundingRect);
        transformedBoundingRect.size.width = CGRectGetHeight(boundingRect);
        transformedBoundingRect.size.height = CGRectGetWidth(boundingRect);
    }
    CGPathRef boundingPath = CGPathCreateWithRect(transformedBoundingRect, NULL);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(text);
    
    CFDictionaryRef frameAttribute = (CFDictionaryRef)[NSDictionary dictionaryWithObject: [NSNumber numberWithInt: vertical ? kCTFrameProgressionRightToLeft : kCTFrameProgressionTopToBottom] forKey: (NSString *)kCTFrameProgressionAttributeName];
        
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), boundingPath, frameAttribute);
    
    CFRelease(framesetter);
    CGPathRelease(boundingPath);
    
    return frame;
}

@implementation YLTextContainer
@synthesize verticalText;
- (NSTextLayoutOrientation)layoutOrientation
{
    return verticalText ? NSTextLayoutOrientationVertical : NSTextLayoutOrientationHorizontal;
}

@end