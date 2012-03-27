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

NSAttributedString *attributedStringWithOptions(NSString *text, NSDictionary *options, BOOL vertical);
CTFrameRef createCTFrame(CFAttributedStringRef text, CGRect boundingRect, BOOL vertical);

@interface YLVerticalTextContainer : NSTextContainer

@end