/*
 *  ZRCGUtilities.c
 *  PageComposer
 *
 *  Created by Zero on 2009/8/30.
 *  Copyright 2009 Bigs Lab. All rights reserved.
 *
 */

#include "ZRCGUtilities.h"
#import <Cocoa/Cocoa.h>

void AddBorderRadiusPath(CGContextRef context, CGRect drawRect, float radius)
{
	if (radius > 0)
	{
		CGContextSaveGState(context);
		CGContextBeginPath(context);
		CGContextTranslateCTM(context, drawRect.origin.x, drawRect.origin.y);
		CGContextMoveToPoint(context, 0, radius);
		CGContextAddLineToPoint(context, 0, drawRect.size.height - radius);
		CGContextAddArc(context, radius, drawRect.size.height - radius, radius, M_PI / 4, M_PI / 2, 1);
		CGContextAddLineToPoint(context, drawRect.size.width - radius, drawRect.size.height);
		CGContextAddArc(context, drawRect.size.width - radius, drawRect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
		CGContextAddLineToPoint(context, drawRect.size.width, radius);
		CGContextAddArc(context, drawRect.size.width - radius, radius, radius, 0.0f, -M_PI / 2, 1);
		CGContextAddLineToPoint(context, radius, 0);
		CGContextAddArc(context, radius, radius, radius, -M_PI / 2, M_PI, 1);
		CGContextClosePath(context);
		CGContextRestoreGState(context);
		CGContextClip(context);
	}
}