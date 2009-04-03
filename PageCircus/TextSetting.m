//
//  TextSetting.m
//  PageCircus
//
//  Created by Yung-Luen Lan on 4/2/09.
//  Copyright 2009 yllan.org. All rights reserved.
//

#import "TextSetting.h"

@implementation TextSetting
@synthesize string = _string;
@synthesize boundingRect = _boundingRect;
@synthesize fontSize = _fontSize;
@synthesize fontSizeCJK = _fontSizeCJK;
@synthesize family = _family;
@synthesize familyCJK = _familyCJK;

- (TextSetting *) init
{
    if ([super init]) {
        self.string = @"Hello, jump. 姑蘇城外寒山寺";
        self.boundingRect = NSMakeRect(10, 10, 300, 300);
        self.fontSize = 36;
        self.fontSizeCJK = 36;
        self.family = @"Optima";
        self.familyCJK = @"LiHei Pro";
    }
    return self;
}

- (NSDictionary *) textDictionary
{
    NSDictionary *fontDictionary = [NSDictionary dictionaryWithObjectsAndKeys: 
                                    [NSNumber numberWithFloat: _fontSize], @"size",
                                    [NSNumber numberWithFloat: _fontSizeCJK], @"cjk-size",
                                    self.family, @"family",
                                    self.familyCJK, @"family-cjk",
                                    nil];
    NSFont *eFont = [NSFont fontWithName: [fontDictionary objectForKey: @"family"] size: [[fontDictionary objectForKey: @"size"] floatValue]];
    NSFont *cFont = [NSFont fontWithName: [fontDictionary objectForKey: @"family-cjk"] size: [[fontDictionary objectForKey: @"cjk-size"] floatValue]];
    
    CGFloat lineHeight = 0;
    NSLayoutManager *layoutManager = [[NSLayoutManager new] autorelease];
    NSLog(@"E: %f + %f = %f, line = %f", [eFont ascender], [eFont descender], [eFont ascender] - [eFont descender], [layoutManager defaultLineHeightForFont: eFont]);
    NSLog(@"C: %f + %f = %f, line = %f", [cFont ascender], [cFont descender], [cFont ascender] - [cFont descender], [layoutManager defaultLineHeightForFont: cFont]);
    lineHeight = [layoutManager defaultLineHeightForFont: eFont];
    return [NSDictionary dictionaryWithObjectsAndKeys: 
            self.string, @"text", 
            fontDictionary, @"font", 
            @"left", @"align",
            @"top", @"vertical-align",
            [NSNumber numberWithFloat: lineHeight], @"force-lineheight",
            [NSNumber numberWithFloat: 0], @"line-spacing",
            nil];
}
@end
