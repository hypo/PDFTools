// PENSColorExtension.m

#import "PENSColorExtension.h"
#import "NSExtensions.h"

BOOL PEIsTransparentColor(NSString *c)
{
	if ([c isEqualToString:@"none"] || [c isEqualToString:@"transparent"] || [c isEqualToString:@"clear"]) return YES;
	return NO;
}

@implementation NSColor(PEColorByName)
+ (NSColor*)colorByName:(NSString*)name
{
    NSDictionary *colorDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSColor clearColor], @"clear",
        [NSColor clearColor], @"transparent",
        [NSColor clearColor], @"none",
        [NSColor brownColor], @"brown",
        [NSColor clearColor], @"clear",
        [NSColor cyanColor], @"cyan",
        [NSColor darkGrayColor], @"darkgray",
        [NSColor grayColor], @"gray",
        [NSColor greenColor], @"green",
        [NSColor lightGrayColor], @"lightgray",
        [NSColor magentaColor], @"magenta",
        [NSColor orangeColor], @"orange",
        [NSColor purpleColor], @"purple",
        [NSColor blueColor], @"blue",
        [NSColor redColor], @"red",
        [NSColor yellowColor], @"yellow",
        [NSColor whiteColor], @"white", 
		[NSColor colorWithDeviceCyan:0.0 magenta:0.0 yellow:0.0 black:0.5 alpha:1.0], @"50K",
		[NSColor colorWithDeviceCyan:0.0 magenta:0.13 yellow:0.90 black:0.0 alpha:1.0], @"cheese",
		[NSColor colorWithDeviceCyan:0.35 magenta:0.0 yellow:1.0 black:0.0 alpha:1.0], @"grass",
		[NSColor colorWithDeviceCyan:0 magenta:0.09 yellow:0.5 black:0.24 alpha:1.0], @"chestnut",
		[NSColor colorWithDeviceCyan:0.32 magenta:0 yellow:1.0 black:0.79 alpha:1.0], @"darkgreen",
		[NSColor colorWithDeviceCyan:0.27 magenta:0 yellow:0.95 black:0.55 alpha:1.0], @"olive",
		[NSColor colorWithDeviceCyan:0 magenta:0.90 yellow:0.86 black:0 alpha:1.0], @"christmasred",
		nil];

    return [colorDict objectForKey:name defaultValue:[NSColor colorWithDeviceCyan:0.0 magenta:0.0 yellow:0.0 black:1.0 alpha:1.0]];
}
@end