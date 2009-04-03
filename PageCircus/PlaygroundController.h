//
//  PlaygroundController.h
//  PageCircus
//
//  Created by Yung-Luen Lan on 4/2/09.
//  Copyright 2009 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextPreviewView.h"

@interface PlaygroundController : NSObject {
    TextPreviewView *_view;
}
@property (retain) IBOutlet TextPreviewView *view;

- (IBAction) updatePreview: (id)sender;

@end
