//
//  TextSetting.h
//  PageCircus
//
//  Created by Yung-Luen Lan on 4/2/09.
//  Copyright 2009 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TextSetting : NSObject {
    NSString *_string;
    NSRect _boundingRect;
    CGFloat _fontSize;
    CGFloat _fontSizeCJK;
    NSString *_family;
    NSString *_familyCJK;
}
@property (copy) NSString *string;
@property NSRect boundingRect;
@property (readonly, retain) NSDictionary *textDictionary;
@property CGFloat fontSize;
@property CGFloat fontSizeCJK;
@property (copy) NSString *family;
@property (copy) NSString *familyCJK;

@end
