//
//  PlaygroundController.m
//  PageCircus
//
//  Created by Yung-Luen Lan on 4/2/09.
//  Copyright 2009 yllan.org. All rights reserved.
//

#import "PlaygroundController.h"

@implementation PlaygroundController
@synthesize view = _view;

- (IBAction) updatePreview: (id)sender
{
    [_view setNeedsDisplay: YES];
}

@end
