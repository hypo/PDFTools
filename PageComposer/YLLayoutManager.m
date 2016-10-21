//
//  YLLayoutManager.m
//  PageComposer
//
//  Created by Yung-Luen Lan on 21/10/2016.
//
//

#import "YLLayoutManager.h"

@implementation YLLayoutManager
- (void) showCGGlyphs: (const CGGlyph *)glyphs
            positions: (const NSPoint *)positions
                count: (NSUInteger)glyphCount
                 font: (NSFont *)font
               matrix: (NSAffineTransform *)textMatrix
           attributes: (NSDictionary *)attributes
            inContext: (NSGraphicsContext *)graphicsContext
{
    NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity: glyphCount];
    
    for (NSUInteger idx = 0; idx < glyphCount; idx++) {
        NSBezierPath *p = [NSBezierPath bezierPath];
        [p moveToPoint: positions[idx]];
        [p appendBezierPathWithGlyph: glyphs[idx] inFont: font];
        
        NSAffineTransform *xfrm = [NSAffineTransform new];
        [xfrm translateXBy: 0 yBy: positions[idx].y];
        [xfrm scaleXBy: 1 yBy: -1];
        [xfrm translateXBy: 0 yBy: -positions[idx].y];
        
        [p transformUsingAffineTransform: xfrm];
        
        [paths addObject: p];
    }
    if (!self.textPath) {
        self.textPath = paths;
    } else {
        self.textPath = [self.textPath arrayByAddingObjectsFromArray: paths];
    }
    
    [super showCGGlyphs: glyphs positions: positions count: glyphCount font: font matrix: textMatrix attributes: attributes inContext: graphicsContext];
}
@end
