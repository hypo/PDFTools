// DrawingTestsController.m

#import "DrawingTestController.h"
#import "DrawingTools.h"
#import "PageElements.h"

@interface DrawingTest : NSObject <PEImageProvider>
- (void)draw:(id)arg;
@end

@implementation DrawingTest : NSObject
- (NSImage*)useImage:(NSString*)source
{
    return [[[NSImage alloc] initWithContentsOfFile:source] autorelease];
}
- (void)draw:(id)arg
{
    if (arg) { }
    NSRect r;
    NSMutableDictionary *debug = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"true", @"debug-mode", nil];
    
    PEDrawableElement *pede;
    PETextBlock *petb;
    PEFont *pef;    
    NSMutableDictionary *td = [NSMutableDictionary dictionary];

    int i = 0;
//    NSArray *ca = [NSArray arrayWithObjects:@"black", @"red", @"orange", @"yellow", @"green", @"blue", @"cyan", @"purple", nil];
    NSArray *ca = [NSArray arrayWithObjects:@"black", @"red", @"cyan", @"yellow", @"green", @"blue", @"cyan", @"purple", nil];

    float rot = 0.0;

    r = DTMakeRectWithSizeInCM(15.0, 15.0);
    r.origin.x = 0.0;
    r.origin.y = 0.0;
    [td setObject:[NSString stringWithUTF8String:"散播音樂散播愛 spread da music 散播，、。．樂；樂：樂？樂！樂︰樂（樂"] forKey:@"text"];    
    [td setObject:@"center" forKey:@"align"];
    [td setObject:@"center" forKey:@"vertical-align"];
    [td setObject:@"clear" forKey:@"background-color"];
    
    pef = [PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"Futura", @"family-latin",
            @"HiraKakuStd-W8", @"family-cjk",
            [NSNumber numberWithFloat:15.0], @"size",
            nil]];
    [td setObject:[pef dictionaryRepresentation] forKey:@"font"];

    r = DTMakeRectWithSizeInCM(15.0, 15.0);    
    PEImageBox *peib = [PEImageBox imageBoxWithDictionary:
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    @"/Users/lukhnos/Desktop/default-book-example.pdf", @"original", nil], @"source",
                nil
            ]
        boundingRect:r];

    [peib drawWithOutputControl:[NSDictionary dictionaryWithObjectsAndKeys:self, @"image-provider", nil]];

    r = DTMakeRectInCM(4, 4, 11.0, 11.0);

	#define CHRF(c, f) [NSNumber numberWithFloat:f], [NSString stringWithUTF8String:c]
	NSDictionary *hshift = [NSDictionary dictionaryWithObjectsAndKeys:
		CHRF("：", 0.285),
		CHRF("；", 0.285),
		CHRF("！", 0.285),
		CHRF("？", 0.5),
		nil];

	NSDictionary *vshift = [NSDictionary dictionaryWithObjectsAndKeys:
		CHRF("，", 0.2),
		CHRF("。", 0.5),
		nil];

	
	#define CHRR(k, v) [NSString stringWithUTF8String:v], [NSString stringWithUTF8String:k]
	NSDictionary *charrep = [NSDictionary dictionaryWithObjectsAndKeys:
		CHRR("（", "︵"),
		nil];
		
	[debug setObject:vshift forKey:@"cjk-vertical-text-punctuation-vshift"];
	[debug setObject:hshift forKey:@"cjk-vertical-text-punctuation-hshift"];
	[debug setObject:charrep forKey:@"cjk-vertical-text-character-replacement"];
	
	[td removeObjectForKey:@"font"];
	[[PEVerticalTextBlock textBlockWithDictionary:td boundingRect:
		DTMakeRectInCM(0, 0, 1.0, 15.0)] drawWithOutputControl:debug];

    // r.origin.x -= DTcm2pt(7.5/2.0);
    for (i = 0 ; i <= 3; i++) {
        // r.origin.x += DTcm2pt((15.0/2.0)/36.0);
        [td setObject:[NSNumber numberWithFloat:rot] forKey:@"rotate"];
        [td setObject:[ca objectAtIndex: i % 8] forKey:@"color"];
        rot += 10.1;
        petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
        [petb drawWithOutputControl:debug];
    }
        

	

    [[PERectangle rectangleWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
        @"green", @"stroke-color",
        @"blue", @"fill-color",
        @"dash", @"stroke-style", nil
        ] boundingRect:NSMakeRect(15.0, 15.0, 85.0, 85.0)] drawWithOutputControl:debug];


    [[PERectangle rectangleWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
        @"blue", @"stroke-color",
        @"blue", @"fill-color", nil
        ] boundingRect:NSMakeRect(85.0, 85.0, 85.0, 85.0)] drawWithOutputControl:nil];


	

/*
    r= DTMakeRectWithSizeInCM(2.5, 2.5);
    r.origin = DTMakePointInCM(0.0, 7.5);

    pede = [[[PEDrawableElement alloc] initWithBoundingRect:r] autorelease];
    [pede drawWithOutputControl:nil];

    r.origin = DTMakePointInCM(2.5, 7.5);
    pede = [[[PEDrawableElement alloc] initWithBoundingRect:r] autorelease];
    [pede drawWithOutputControl:debug];

    r.origin = DTMakePointInCM(5.0, 7.5);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:nil];

    r.origin = DTMakePointInCM(7.5, 7.5);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:debug];
    
    [td setObject:@"hello, world!" forKey:@"text"];
    r.origin = DTMakePointInCM(0.0, 5.0);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:nil];

    r.origin = DTMakePointInCM(2.5, 5.0);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:debug];
    
    
    pef = [PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"Futura", @"family-latin",
            @"HiraKakuStd-W8", @"family-cjk",
            [NSNumber numberWithFloat:5.0], @"size",
            nil]];
    [td setObject:[pef dictionaryRepresentation] forKey:@"font"];


    [td setObject:[NSString stringWithUTF8String:"hello 漢字,\nworld 世界!"] forKey:@"text"];
    r.origin = DTMakePointInCM(5.0, 5.0);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:nil];

    r.origin = DTMakePointInCM(7.5, 5.0);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:debug];


    [td setObject:@"center" forKey:@"align"];
    r.origin = DTMakePointInCM(0.0, 2.5);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:debug];    

    [td setObject:@"right" forKey:@"align"];
    r.origin = DTMakePointInCM(2.5, 2.5);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:nil];    

    [td setObject:@"center" forKey:@"vertical-align"];
    r.origin = DTMakePointInCM(5.0, 2.5);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:debug];    

    [td setObject:@"center" forKey:@"align"];
    [td setObject:@"bottom" forKey:@"vertical-align"];
    r.origin = DTMakePointInCM(7.5, 2.5);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:nil];    


    [td setObject:@"left" forKey:@"align"];
    [td setObject:@"center" forKey:@"vertical-align"];
    r.origin = DTMakePointInCM(0.0, 0.0);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:nil];    

    [td setObject:@"center" forKey:@"align"];
    [td setObject:@"center" forKey:@"vertical-align"];
    r.origin = DTMakePointInCM(2.5, 0.0);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:debug];    

    [td setObject:@"center" forKey:@"align"];
    [td setObject:@"center" forKey:@"vertical-align"];
    [td setObject:[NSNumber numberWithFloat:30.0] forKey:@"rotate"];
    r.origin = DTMakePointInCM(5.0, 0.0);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:nil];    

    [td setObject:@"center" forKey:@"align"];
    [td setObject:@"center" forKey:@"vertical-align"];
    [td setObject:[NSNumber numberWithFloat:-30.0] forKey:@"rotate"];
    r.origin = DTMakePointInCM(7.5, 0.0);
    petb = [PETextBlock textBlockWithDictionary:td boundingRect:r];
    [petb drawWithOutputControl:debug];    
*/

}
@end

@implementation DrawingTestController
- (void)awakeFromNib 
{
    [NSColor blackColor];
    NSColor *c = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
    // NSLog(@"%f %f %f %f", [c cyanComponent], [c magentaComponent], [c yellowComponent], [c blackComponent]);
    
    NSLog(@"black color space = %@", [c colorSpaceName]);
    
    NSColor *d = [c colorUsingColorSpaceName:NSDeviceCMYKColorSpace];

    NSLog(@"converted black color space = %@", [d colorSpaceName]);

    NSLog(@"%f %f %f %f", [d cyanComponent], [d magentaComponent], [d yellowComponent], [d blackComponent]);

//    float cmyk[5]={0.0, 0.0, 0.0, 1.0, 1.0};

    c = [NSColor colorWithDeviceCyan:0.0 magenta:0.0 yellow:0.0 black:1.0 alpha:1.0];
    NSLog(@"CMYK color space = %@", [c colorSpaceName]);

    // c= [NSColor colorWithColorSpace:[NSColorSpace genericCMYKColorSpace] components:cmyk count:5];
    // NSLog(@"%f %f %f %f", [c cyanComponent], [c magentaComponent], [c yellowComponent], [c blackComponent]);
    
    d = [c colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    NSLog(@"? converted CMYK color space = %@", [d colorSpaceName]);

    NSLog(@"RGB = %f %f %f", [d redComponent], [d greenComponent], [d blueComponent]);
    
    NSColor *e = [d colorUsingColorSpaceName:NSDeviceCMYKColorSpace];
    NSLog(@"RGB->CMYK %f %f %f %f", [e cyanComponent], [e magentaComponent], [e yellowComponent], [e blackComponent]);
    
}

- (IBAction)runAction:(id)sender
{
    // enable Preview.app's AppleScript with:
    //
    //  defaults write /Applications/Preview.app/Contents/Info NSAppleScriptEnabled -bool YES    
    //
    // or:
    //
    //   try
    //     tell application "Finder"
    //       set the Preview_app to (application file id "com.apple.Preview") as alias
    //     end tell
    //     set the plist_filepath to the quoted form of ¬
    //      ((POSIX path of the Preview_app) & "Contents/Info")
    //     do shell script "defaults write " & the plist_filepath & space ¬
    //      & "NSAppleScriptEnabled -bool YES"
    //   end try    
    
    [[[[NSAppleScript alloc] initWithSource:
        @"tell application \"Preview\" to close window \"FOOBAR-drawingtest-test.pdf (1 page)\""] 
            autorelease] executeAndReturnError:nil];

    id test = [DrawingTest new];
    NSData *pdf = DTPDFDataByDrawingCallback(DTMakeRectWithSizeInCM(15.0, 15.0), test, @selector(draw:), nil);
    [pdf writeToFile:[@"/tmp/FOOBAR-drawingtest-test.pdf" stringByStandardizingPath] atomically:YES];    
    [test release];
    
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/FOOBAR-drawingtest-test.pdf"];
    
    NSImage *image = [[[NSImage alloc] initWithSize:DTMakeRectWithSizeInCM(15.0, 15.0).size] autorelease];
    NSBitmapImageRep *output;

    [image lockFocus];
    [test draw:nil];
    output = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:DTMakeRectWithSizeInCM(15.0, 15.0)] autorelease];

    [image unlockFocus];
    
    float quality = 0.5;
    
    // save as JPEG
    NSDictionary *properties =
        [NSDictionary dictionaryWithObjectsAndKeys:
	    [NSNumber numberWithFloat:quality],
	    NSImageCompressionFactor, NULL];    
    
    NSData *bitmapData = [output representationUsingType:NSJPEGFileType
				      properties:properties];

    [bitmapData writeToFile:@"/Users/lukhnos/Desktop/test.jpg" atomically:YES];
}

@end
