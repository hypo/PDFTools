//
//  YLCUtilities.m
//  PageComposer
//
//  Created by Yung-Luen Lan on 3/26/12.
//  Copyright (c) 2012 yllan@me.com. All rights reserved.
//

#import "YLCTUtilities.h"
#import "PENSColorExtension.h"

UniChar _PECJKChars[] = {0x2013, 0x2014, 0x2025, 0x2026, 0x22ee, 0x22ef, 0x2500, 0x2502, 0x2048, 0x2049};
BOOL isCJK(UniChar c)
{
	if (c >= 0x2e80) return YES;
	size_t i;
	for (i=0;i<sizeof(_PECJKChars);i++) if (c==_PECJKChars[i]) return YES;
	return NO;
}

NSAttributedString *attributedStringWithOptions(NSString *text, NSDictionary *options, BOOL vertical)
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

//    if (vertical) {
//        [psd setObject: [NSArray arrayWithObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: NSTextLayoutOrientationVertical], NSTextLayoutSectionOrientation, nil]] forKey: NSTextLayoutSectionsAttribute];
//    }
    
    // set Latin font and paragraph style
    [attrString setAttributes: psd range: NSMakeRange(0, len)];
	
    [psd setObject: fontCJK forKey: NSFontAttributeName];
	[psd setObject:[NSNumber numberWithFloat: kerningCJK] forKey: NSKernAttributeName];
//    if (vertical) {
//        [psd setObject: [NSNumber numberWithBool:YES] forKey: (NSString *)kCTVerticalFormsAttributeName];
//    }
    
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

@implementation YLVerticalTextContainer

- (NSTextLayoutOrientation)layoutOrientation
{
    return NSTextLayoutOrientationVertical;
}

@end