//
//  YLCUtilities.h
//  PageComposer
//
//  Created by Yung-Luen Lan on 3/26/12.
//  Copyright (c) 2012 yllan@me.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>

@interface NSColor(PEColorByName)
+ (NSColor*)colorByName:(NSString*)name;
@end

NSAttributedString *attributedStringWithOptions(NSString *text, NSDictionary *options);
CTFrameRef createCTFrame(CFAttributedStringRef text, CGRect boundingRect, BOOL vertical);

@interface YLTextContainer : NSTextContainer
{
    BOOL verticalText;
}
@property BOOL verticalText;
@end