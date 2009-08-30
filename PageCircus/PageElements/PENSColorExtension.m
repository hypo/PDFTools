// PENSColorExtension.m

#import "PENSColorExtension.h"
#import "NSExtensions.h"

BOOL PEIsTransparentColor(NSString *c)
{
	if ([c isEqualToString:@"none"] || [c isEqualToString:@"transparent"] || [c isEqualToString:@"clear"]) return YES;
	return NO;
}

static int HexValue(char c) {
	if ('0' <= c && c <= '9')
		return c - '0';
	if ('a' <= c && c <= 'f')
		return 10 + c - 'a';
	if ('A' <= c && c <= 'F')
		return 10 + c - 'A';
	return 0;
}

@implementation NSColor(PEColorByName)
+ (NSColor*)colorByName:(NSString*)name
{
	// 0xRRGGBB in hex.
	if ([name hasPrefix: @"0x"] && [name length] == 8) {
		const char *cString = [name UTF8String];
		CGFloat r = 16 * HexValue(cString[2]) + HexValue(cString[3]);
		CGFloat g = 16 * HexValue(cString[4]) + HexValue(cString[5]);
		CGFloat b = 16 * HexValue(cString[6]) + HexValue(cString[7]);

		return [NSColor colorWithDeviceRed: r / 255.0 green: g / 255.0 blue: b / 255.0 alpha: 1.0];
	}
	
	if ([name hasPrefix: @"CMYK:"])
	{
		NSString* strColor = [name substringFromIndex: 5];
		NSMutableArray* comps = [[[strColor componentsSeparatedByString:@","] mutableCopy] autorelease];
		for(NSString *s in comps)
			s = [s stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if ([comps count] == 4)
			[comps addObject:@"1.0"];
		
		if ([comps count] == 5)		
			return [NSColor colorWithDeviceCyan:[[comps objectAtIndex:0] floatValue] magenta:[[comps objectAtIndex:1] floatValue] yellow:[[comps objectAtIndex:2] floatValue] black:[[comps objectAtIndex:3] floatValue] alpha:[[comps objectAtIndex:4] floatValue]];
	}
	
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
	    [NSColor colorWithDeviceCyan:0.1 magenta:0.1 yellow:0.1 black:1.0 alpha:1.0], @"hypo-black",
	    [NSColor colorWithDeviceCyan:0.1 magenta:0.1 yellow:0.1 black:0.6 alpha:1.0], @"hypo-lightgray",
		[NSColor colorWithDeviceCyan:0.05 magenta:0.05 yellow:0.05 black:0.3 alpha:1.0], @"hypo-ticketgray",
		nil];
    return [colorDict objectForKey:name defaultValue:[NSColor colorWithDeviceCyan:0.0 magenta:0.0 yellow:0.0 black:1.0 alpha:1.0]];
}
@end