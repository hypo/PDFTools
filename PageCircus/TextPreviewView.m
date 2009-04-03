//
//  TextPreviewView.m
//  PageCircus
//
//  Created by Yung-Luen Lan on 4/2/09.
//  Copyright 2009 yllan.org. All rights reserved.
//

#import "TextPreviewView.h"
#import <PageElements/PageElements.h>

@implementation TextPreviewView
@synthesize setting = _setting;

- (id) initWithFrame: (NSRect)frame
{
    if ([super initWithFrame: frame]) {

    }
    return self;
}

- (void) drawRect: (NSRect)rect
{
    [NSBezierPath strokeRect: _setting.boundingRect];
    PETextBlock *textBlock = [PETextBlock textBlockWithDictionary: _setting.textDictionary boundingRect: _setting.boundingRect];
    [textBlock drawWithOutputControl: nil];

    NSRect r = NSMakeRect(50, 400, 300, 100);
    [NSBezierPath strokeRect: r];
    
    NSMutableAttributedString *attrS = [[NSMutableAttributedString alloc] initWithString: @"Hello, jump."];
    
//    [attrS setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Hiragino Kaku Gothic ProN" size: 36], NSFontAttributeName, nil] range: NSMakeRange(0, [attrS length])];
    [attrS setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Optima" size: 36], NSFontAttributeName, nil] range: NSMakeRange(0, [attrS length])];
//    [attrS setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"DFPHeiMedium-UN" size: 36], NSFontAttributeName, nil] range: NSMakeRange(0, [attrS length])];

//    [attrS setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"LiHei Pro" size: 36], NSFontAttributeName, nil] range: NSMakeRange(0, [attrS length])];
    
    [attrS drawWithRect: r options: NSStringDrawingUsesLineFragmentOrigin];
    
    
    [attrS release];
}

@end
