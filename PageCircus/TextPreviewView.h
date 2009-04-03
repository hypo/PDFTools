//
//  TextPreviewView.h
//  PageCircus
//
//  Created by Yung-Luen Lan on 4/2/09.
//  Copyright 2009 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextSetting.h"

@interface TextPreviewView : NSView {
    TextSetting *_setting;
}

@property (retain) IBOutlet TextSetting *setting;

@end
