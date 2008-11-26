// PENSColorExtension.h

#import <Cocoa/Cocoa.h>

BOOL PEIsTransparentColor(NSString *c);

@interface NSColor(PEColorByName)
+ (NSColor*)colorByName:(NSString*)name;
@end
