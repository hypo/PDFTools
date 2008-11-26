// BMHypoPhotoBook12cmx12cm.m

#import "BMHypoPhotoBook12cmx12cm.h"
#import "NSExtensions.h"
#import "DrawingTools.h"
#import "PageElements.h"

@implementation BMHypoPhotoBook12cmx12cm : NSObject
- (PETransform*)prepareTransform {
	return [PETransform transformWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:DTcm2pt(0.3)], @"move-x",
		[NSNumber numberWithFloat:DTcm2pt(0.3)], @"move-y", nil]];
}
- (PETransform*)preparePreviewTransform {
	return [PETransform transformWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:DTcm2pt(-0.3)], @"move-x",
		[NSNumber numberWithFloat:DTcm2pt(-0.3)], @"move-y", nil]];
}
- (PETransform*)prepareBookclothPreviewTransform {
	return [PETransform transformWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:DTcm2pt(-20.2)], @"move-x",
		[NSNumber numberWithFloat:DTcm2pt(0.0)], @"move-y", nil]];
}
- (PETransform*)prepareBookclothCoverPreviewTransform {
	return [PETransform transformWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:DTcm2pt(-20.5)], @"move-x",
		[NSNumber numberWithFloat:DTcm2pt(0.0)], @"move-y", nil]];
}
- (PETransform*)preparePageFrontTransform {
	return [PETransform transformWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:DTcm2pt(-12.3 + 0.3)], @"move-x",
		[NSNumber numberWithFloat:DTcm2pt(0.0 + 0.3)], @"move-y", nil]];
}
- (PETransform*)prepareStickerTransform {
	return [PETransform transformWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:180.0], @"rotate",
		[NSNumber numberWithFloat:DTcm2pt(-11.0)], @"move-x",
		[NSNumber numberWithFloat:DTcm2pt(-7.1)], @"move-y", nil]];
}
- (BOOL)isPreviewMode
{
    NSString *mode = [_outputControl objectForKey:@"mode" defaultValue:@""];
    if ([mode hasPrefix:@"preview"]) return YES;
    return NO;
}
- (BOOL)isDebugMode
{
	return [_outputControl isKeyTrue:@"debug-mode"];
}
- (NSDictionary*)prepareResult:(NSRect)pageRect elements:(NSMutableArray*)elements {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSValue valueWithRect:pageRect], @"page-rectangle",
        [NSArray arrayWithArray:elements], @"elements",
        nil];
}
- (NSDictionary*)prepareFont6pt {
    return [[PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:6.0], @"size", nil]] dictionaryRepresentation];
}
- (NSDictionary*)prepareFont8pt {
    return [[PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:8.0], @"size", 
			[NSNumber numberWithFloat:7.0], @"cjk-size", nil]] dictionaryRepresentation];
}
- (NSDictionary*)prepareFont8ptSameCJK {
    return [[PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:8.0], @"size", 
			[NSNumber numberWithFloat:8.0], @"cjk-size", nil]] dictionaryRepresentation];
}
- (NSDictionary*)prepareFont9pt {
    return [[PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:9.0], @"size", 
			[NSNumber numberWithFloat:8.0], @"cjk-size", nil]] dictionaryRepresentation];
}
- (NSDictionary*)prepareFont10pt {
    return [[PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:10.0], @"size", 
			[NSNumber numberWithFloat:9.0], @"cjk-size", nil]] dictionaryRepresentation];
}
- (NSDictionary*)prepareFont12pt {
    return [[PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:12.0], @"size", 
			[NSNumber numberWithFloat:11.0], @"cjk-size", nil]] dictionaryRepresentation];
}
- (NSDictionary*)prepareFont16pt {
    return [[PEFont fontWithDictionary:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:16.0], @"size", 
			[NSNumber numberWithFloat:15.0], @"cjk-size", nil]] dictionaryRepresentation];
}
- (NSDictionary*)prepareGiftWrappingCard:(NSDictionary*)instruction isPreview:(BOOL)preview {
    NSMutableDictionary *pages = [NSMutableDictionary dictionary];
    NSDictionary *emptyDict = [NSDictionary dictionary];

	NSDictionary *tiffPassThru = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"tiff-pass-through", nil];	
    
    NSDictionary *frontImage = [[instruction objectForKey:@"giftwrapping-card-front-image" defaultValue:emptyDict] dictionaryByMergingDictionary:tiffPassThru];
    NSDictionary *backImage = [[instruction objectForKey:@"giftwrapping-card-back-image" defaultValue:emptyDict] dictionaryByMergingDictionary:tiffPassThru];
    
    NSDictionary *backCardText = [instruction objectForKey:@"text" defaultValue:emptyDict];
    NSRect cardRect = preview ? DTMakeRectWithSizeInCM(5.0, 15.0) : DTMakeRectWithSizeInCM(5.6, 15.6);
    
    NSMutableArray *backCard = [NSMutableArray array];
    NSMutableArray *frontCard = [NSMutableArray array];    

    NSDictionary *textFont9ptLineheight13pt50K = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont9pt], @"font", @"50K", @"color", [NSNumber numberWithFloat:13.0], @"force-lineheight", nil];
    NSDictionary *topCenterAlign = [NSDictionary dictionaryWithObjectsAndKeys:@"center", @"align", @"top", @"vertical-align", nil];
    
    id obj;
    
    if (!preview) {
        [backCard addObject:[self prepareTransform]];
        [frontCard addObject:[self prepareTransform]];
    }
    
	
    // back card image
	obj = [PEImageBox imageBoxWithDictionary:backImage boundingRect:DTMakeRectInCM(-0.3, -0.3, 5.6, 15.6)];
    [backCard addObject:obj];
    	
    // bookcloth title
	obj = [PETextBlock textBlockWithDictionary:
        [[backCardText dictionaryByMergingDictionary:textFont9ptLineheight13pt50K] dictionaryByMergingDictionary:topCenterAlign]
        boundingRect:DTMakeRectInCM(0.5, 4.5, 4.0, 8.5)];
    [backCard addObject:obj];

    // front card
	obj = [PEImageBox imageBoxWithDictionary:frontImage boundingRect:DTMakeRectInCM(-0.3, -0.3, 5.6, 15.6)];
    [frontCard addObject:obj];

	[pages setObject:[self prepareResult:cardRect elements:backCard] forKey:@"giftwrapping-card-back"];        
	[pages setObject:[self prepareResult:cardRect elements:frontCard] forKey:@"giftwrapping-card-front"]; 
    return pages;    
    
}
- (NSDictionary*)prepareCover:(NSDictionary*)instruction isPreview:(BOOL)preview {
    NSMutableDictionary *pages = [NSMutableDictionary dictionary];
    
    NSDictionary *emptyDict = [NSDictionary dictionary];
    
    NSString *color = [instruction objectForKey:@"color" defaultValue:@"white"];

	

	NSString *textColor = @"black";
	
	if ([color isEqualToString:@"white"] || [color isEqualToString:@"cheese"] || [color isEqualToString:@"grass"])
		textColor = @"black";
	else
		textColor = @"white";

	NSString *coverSubtitleColor = textColor;
	if ([color isEqualToString:@"cheese"] || [color isEqualToString:@"grass"])
		coverSubtitleColor = @"white";

    NSDictionary *textFont6pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont6pt], @"font", textColor, @"color", nil];
    NSDictionary *textFont8pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont8pt], @"font", textColor, @"color", nil];
    NSDictionary *textFont8ptBlack = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont8pt], @"font", @"black", @"color", nil];
    NSDictionary *textFont9pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont9pt], @"font", textColor, @"color", nil];

	NSDictionary *coverSubtitleTextFont9pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont9pt], @"font", coverSubtitleColor, @"color", nil];

    NSDictionary *textFont9ptLineheight13pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont9pt], @"font", textColor, @"color", [NSNumber numberWithFloat:13.0], @"force-lineheight", nil];
    NSDictionary *textFont10pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont10pt], @"font", textColor, @"color", nil];
    NSDictionary *textFont10ptBlack = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont10pt], @"font", @"black", @"color", nil];
    NSDictionary *textFont12pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont12pt], @"font", textColor, @"color", nil];
    NSDictionary *textFont16pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont16pt], @"font", textColor, @"color", nil];
    NSDictionary *bottomRightAlign = [NSDictionary dictionaryWithObjectsAndKeys:@"right", @"align", @"bottom", @"vertical-align", nil];
    NSDictionary *bottomLeftAlign = [NSDictionary dictionaryWithObjectsAndKeys:@"left", @"align", @"bottom", @"vertical-align", nil];
    NSDictionary *bottomCenterAlign = [NSDictionary dictionaryWithObjectsAndKeys:@"center", @"align", @"bottom", @"vertical-align", nil];
    NSDictionary *topLeftAlign = [NSDictionary dictionaryWithObjectsAndKeys:@"left", @"align", @"top", @"vertical-align", nil];
    NSDictionary *topRightAlign = [NSDictionary dictionaryWithObjectsAndKeys:@"right", @"align", @"top", @"vertical-align", nil];
    NSDictionary *kerning200kerningCJK400 = [NSDictionary dictionaryWithObjectsAndKeys:@"2.0", @"kerning", @"4.0", @"kerning-cjk", nil];
    NSDictionary *kerning100kerningCJK200 = [NSDictionary dictionaryWithObjectsAndKeys:@"1.0", @"kerning", @"2.0", @"kerning-cjk", nil];

    NSDictionary *coverImage = [instruction objectForKey:@"cover-image" defaultValue:emptyDict];    
    NSDictionary *frontTitle = [instruction objectForKey:@"front-title" defaultValue:emptyDict];
    NSDictionary *frontSubtitle = [instruction objectForKey:@"front-subtitle" defaultValue:emptyDict];
//  NSDictionary *stickerTitle = [instruction objectForKey:@"sticker-title" defaultValue:emptyDict];
//  NSDictionary *stickerDate = [instruction objectForKey:@"sticker-date" defaultValue:emptyDict];
    NSDictionary *spineTitle = [instruction objectForKey:@"spine-title" defaultValue:emptyDict];
    NSDictionary *backTitle = [instruction objectForKey:@"back-title" defaultValue:emptyDict];
    NSDictionary *bookClothInsideRightImage = [instruction objectForKey:@"bookcloth-inside-right-image" defaultValue:emptyDict];
    NSDictionary *bookClothInsideRightDescription = [instruction objectForKey:@"bookcloth-inside-right-description" defaultValue:emptyDict];
    
    NSDictionary *barcode = [instruction objectForKey:@"barcode" defaultValue:emptyDict];
	
	NSDictionary *tiffPassThru = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"tiff-pass-through", nil];
	
    NSDictionary *promotionPartnerLogo = [instruction objectForKey:@"promotion-partner-logo"];    
    if (promotionPartnerLogo)
        promotionPartnerLogo = [promotionPartnerLogo dictionaryByMergingDictionary:tiffPassThru];
    
    NSDictionary *innerBackLogo1 = [[instruction objectForKey:@"inner-back-logo1" defaultValue:emptyDict] dictionaryByMergingDictionary:tiffPassThru];
    NSDictionary *innerBackLogo2 = [[instruction objectForKey:@"inner-back-logo2" defaultValue:emptyDict] dictionaryByMergingDictionary:tiffPassThru];;
	NSDictionary *bookclothLogo = [[instruction objectForKey:@"bookcloth-logo" defaultValue:emptyDict] dictionaryByMergingDictionary:tiffPassThru];
    
    NSDictionary *cuttingLine;
	NSDictionary *cropMark;
	NSDictionary *stickerHorizontalBar;

	cropMark = stickerHorizontalBar = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:0.2], @"line-width",
		@"gray", @"stroke-color", 
		@"none", @"fill-color", nil];

	stickerHorizontalBar = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:0.75], @"line-width",
		@"50K", @"stroke-color", 
		@"none", @"fill-color", nil];


    // prepare bookcloth: 41cm x (12cm + 0.2 cm)
    NSRect clothRect = preview ? DTMakeRectWithSizeInCM(41.0, 12.0) : DTMakeRectWithSizeInCM(41.6, 12.6);
	NSRect previewRect = preview ? DTMakeRectWithSizeInCM(20.8, 12.0) : DTMakeRectWithSizeInCM(21.4, 12.6);
	NSRect previewCoverRect = preview ? DTMakeRectWithSizeInCM(12.0, 12.0) : DTMakeRectWithSizeInCM(12.0, 12.0);
    NSRect debugRect = DTMakeRectWithSizeInCM(41.0, 12.0);
	NSRect stickerRect = DTMakeRectWithSizeInCM(12.5, 3.5);
    NSMutableArray *clothObjects = [NSMutableArray array];
    NSMutableArray *clothPreviewObjects = [NSMutableArray array];
    NSMutableArray *clothCoverObjects = [NSMutableArray array];
    NSMutableArray *stickerObjects =  [NSMutableArray array];
	
    #define MERGEDICT(a, b) [a dictionaryByMergingDictionary:b]
	
	
    // the fill color
	id obj;
	obj = [PERectangle rectangleWithDictionary:
			[NSDictionary dictionaryWithObjectsAndKeys:color, @"fill-color", color, @"stroke-color", nil]
		boundingRect:clothRect];
    [clothObjects addObject:obj];

	// preview's transform and fill rect
	[clothPreviewObjects addObject:[self prepareBookclothPreviewTransform]];
	[clothPreviewObjects addObject:obj];
	[clothCoverObjects addObject:[self prepareBookclothCoverPreviewTransform]];
	[clothCoverObjects addObject:obj];

	// sticker's fill color
	obj = [PERectangle rectangleWithDictionary:
			[NSDictionary dictionaryWithObjectsAndKeys:@"white", @"fill-color", @"white", @"stroke-color", nil]
		boundingRect:stickerRect];
	[stickerObjects addObject:obj];

	// transform object in non-preview mode
	if (!preview) {
		[clothObjects addObject:[self prepareTransform]];
		[clothPreviewObjects addObject:[self prepareTransform]];
	}
	
    // bookcloth cover image
	// obj = [PEImageBox imageBoxWithDictionary:coverImage boundingRect:DTMakeRectInCM(20.5, 3.0, 12.0, 9.0 + (preview ? 0.0 : 0.3))];
	obj = [PEImageBox imageBoxWithDictionary:coverImage boundingRect:DTMakeRectInCM(20.5, 3.0, 12.0, 9.0 + 0.3)];

    [clothObjects addObject:obj];
	[clothPreviewObjects addObject:obj];	
	[clothCoverObjects addObject:obj];
	
	
	// sticker image
	obj = [PEImageBox imageBoxWithDictionary:coverImage boundingRect:DTMakeRectInCM(0.25, 0.25, 3.0, 3.0)];
	[stickerObjects addObject: obj];
    	
    // bookcloth title
	obj = [PETextBlock textBlockWithDictionary:
	    MERGEDICT(MERGEDICT(MERGEDICT(frontTitle, textFont16pt), bottomRightAlign), kerning200kerningCJK400)
//      [[frontTitle dictionaryByMergingDictionary:textFont16pt] dictionaryByMergingDictionary:bottomRightAlign]
        boundingRect:DTMakeRectInCM(20.5 + 1.0, 1.7, 10.0, DTpt2cm(18.0))];
    [clothObjects addObject:obj];
	[clothPreviewObjects addObject:obj];	
	[clothCoverObjects addObject:obj];
	
	// sticker title from bookcloth title
	obj = [PETextBlock textBlockWithDictionary:
		[[frontTitle dictionaryByMergingDictionary:textFont10ptBlack] dictionaryByMergingDictionary:bottomLeftAlign]
		boundingRect:DTMakeRectInCM(3.5, 2.95, 8.75, DTpt2cm(12.0))];
	[stickerObjects addObject:obj];
        
    // bookcloth subtitle
	obj = [PETextBlock textBlockWithDictionary:
        MERGEDICT(MERGEDICT(MERGEDICT(frontSubtitle, coverSubtitleTextFont9pt), bottomRightAlign), kerning100kerningCJK200)	
//      [[frontSubtitle dictionaryByMergingDictionary:coverSubtitleTextFont9pt] dictionaryByMergingDictionary:bottomRightAlign]
        boundingRect:DTMakeRectInCM(20.5 + 1.0, 1.0, 10.0, DTpt2cm(12.0))];
    [clothObjects addObject:obj];
	[clothPreviewObjects addObject:obj];	
	[clothCoverObjects addObject:obj];

	// sticker subtitle from bookcloth subtitle
	obj = [PETextBlock textBlockWithDictionary:
		[[frontSubtitle dictionaryByMergingDictionary:textFont8ptBlack] dictionaryByMergingDictionary:bottomLeftAlign]
		boundingRect:DTMakeRectInCM(3.5, 2.30, 8.75, DTpt2cm(14.0))];
	[stickerObjects addObject:obj];

	// rotate
//	[stickerObjects addObject:[self prepareStickerTransform]];
	
	// sticker title (flipped)
//	obj = [PETextBlock textBlockWithDictionary:
//		[[stickerTitle dictionaryByMergingDictionary:textFont9pt] dictionaryByMergingDictionary:bottomLeftAlign]
//		boundingRect:DTMakeRectInCM(0.5, 0.33, 11.0 - 1.0 - 2.0, 0.3)];
//	[stickerObjects addObject:obj];
	
	// sticker date (flipped)
//	obj = [PETextBlock textBlockWithDictionary:
//		[[stickerDate dictionaryByMergingDictionary:textFont9pt] dictionaryByMergingDictionary:bottomRightAlign]
//		boundingRect:DTMakeRectInCM(11.0 - 0.5 - 2.0, 0.33, 2.0, 0.3)];
//	[stickerObjects addObject:obj];

	// sticker horizontal bar
	obj = [PERectangle rectangleWithDictionary:stickerHorizontalBar boundingRect:DTMakeRectInCM(3.5, 2.75, 8.75, 0.0)];
	[stickerObjects addObject:obj];

    // spine title
    obj = [PEVerticalTextBlock textBlockWithDictionary:
        MERGEDICT(MERGEDICT(MERGEDICT(spineTitle, textFont8pt), topLeftAlign), kerning200kerningCJK400)
        // [[spineTitle dictionaryByMergingDictionary:textFont8pt] dictionaryByMergingDictionary:topLeftAlign]
        boundingRect:
        
        // shift the spine-title in preview mode 0.75mm to the right
        (preview ? DTMakeRectInCM(20.2 - 0.05 + 0.075, 0.0, 0.3, 11.0) : DTMakeRectInCM(20.2 - 0.05, 0.0, 0.3, 11.0))];
    [clothObjects addObject:obj];
	[clothPreviewObjects addObject:obj];	

	// inside right image (buddy icon) and description
	obj = [PETextBlock textBlockWithDictionary:
		[[bookClothInsideRightDescription dictionaryByMergingDictionary:textFont9ptLineheight13pt] dictionaryByMergingDictionary:topLeftAlign]
		boundingRect:DTMakeRectInCM(32.5 + 1.5, 2.5, 6.0, 8.5)];
    [clothObjects addObject:obj];
	[clothPreviewObjects addObject:obj];	

	obj = [PEImageBox imageBoxWithDictionary:bookClothInsideRightImage boundingRect:DTMakeRectInCM(39.0, 1.0, 1.0, 1.0)];
    [clothObjects addObject:obj];
	[clothPreviewObjects addObject:obj];	
        
    // back title
    // [clothObjects addObject:[PETextBlock textBlockWithDictionary: [[backTitle dictionaryByMergingDictionary:textFont10pt] dictionaryByMergingDictionary:bottomCenterAlign] boundingRect:DTMakeRectInCM(8.2 + 1.0, 1.0, 10.0, DTpt2cm(12.0))]];

    // back logo
    obj = [PEImageBox imageBoxWithDictionary:bookclothLogo boundingRect:DTMakeRectInCM(12.45, 1.0, 3.54, 0.48)];
    [clothObjects addObject:obj];	
    
    // barcode
    [clothObjects addObject:[PEBarcodeCode39 barcodeWithDictionary: [barcode dictionaryByMergingDictionary: [NSDictionary dictionaryWithObjectsAndKeys: @"YES", @"rounded-corner", nil]]
        boundingRect:DTMakeRectInCM(1.0, -0.3, 5.3, 1.9)]];

	// bounding rect in debug mode
	if ([self isDebugMode]) [clothObjects addObject:[PEDrawableElement elementWithBoundingRect:debugRect]];
	if ([self isDebugMode]) [clothPreviewObjects addObject:[PEDrawableElement elementWithBoundingRect:debugRect]];

    // cutting lines if in preview mode
    if (preview) {
        cuttingLine = [NSDictionary dictionaryWithObjectsAndKeys:
            textColor, @"stroke-color", 
            @"dash", @"stroke-style",
            @"none", @"fill-color", nil];
        
		obj = [PERectangle rectangleWithDictionary:cuttingLine boundingRect:DTMakeRectInCM(8.2, 0.0, 0.0, 12.0)];
		[clothObjects addObject:obj];
		[clothPreviewObjects addObject:obj];	
		obj = [PERectangle rectangleWithDictionary:cuttingLine boundingRect:DTMakeRectInCM(20.2, 0.0, 0.0, 12.0)];
		[clothObjects addObject:obj];
		[clothPreviewObjects addObject:obj];	
		obj = [PERectangle rectangleWithDictionary:cuttingLine boundingRect:DTMakeRectInCM(20.5, 0.0, 0.0, 12.0)];
		[clothObjects addObject:obj];
		[clothPreviewObjects addObject:obj];	
		obj = [PERectangle rectangleWithDictionary:cuttingLine boundingRect:DTMakeRectInCM(32.5, 0.0, 0.0, 12.0)];
		[clothObjects addObject:obj];
		[clothPreviewObjects addObject:obj];	
    }

	if (!preview) {
		#define DC(x1, y1, x2, y2) obj = [PERectangle rectangleWithDictionary:cropMark boundingRect:DTMakeRectInCM(x1 - 0.3, y1 - 0.3, x2-x1, y2-y1)]; [clothObjects addObject:obj];
		DC( 8.5, 0.0, 8.5, 0.2);
		DC(20.5, 0.0, 20.5, 0.2);
		DC(20.8, 0.0, 20.8, 0.2);
		DC(32.8, 0.0, 32.8, 0.2);
		DC( 8.5, 12.4, 8.5, 12.6);
		DC(20.5, 12.4, 20.5, 12.6);
		DC(20.8, 12.4, 20.8, 12.6);
		DC(32.8, 12.4, 32.8, 12.6);		
		#undef DC
	}

    // add bookcloth
    [pages setObject:[self prepareResult:clothRect elements:clothObjects] forKey:@"bookcloth"];
    [pages setObject:[self prepareResult:previewRect elements:clothPreviewObjects] forKey:@"bookcloth-preview"];
    [pages setObject:[self prepareResult:previewCoverRect elements:clothCoverObjects] forKey:@"bookcloth-cover-preview"];

	// add sticker
	[pages setObject:[self prepareResult:stickerRect elements:stickerObjects] forKey:@"sticker"];

    // prepare inner-cover, page-front and page-back
    textColor = @"black";
    textFont6pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont6pt], @"font", textColor, @"color", nil];
    textFont8pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont8pt], @"font", textColor, @"color", nil];
    textFont9pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont9pt], @"font", textColor, @"color", nil];
    textFont10pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont10pt], @"font", textColor, @"color", nil];
    textFont16pt = [NSDictionary dictionaryWithObjectsAndKeys:[self prepareFont16pt], @"font", textColor, @"color", nil];
    
    NSMutableArray *innerCoverObjs = [NSMutableArray array];
    NSRect innerCoverRect = preview? DTMakeRectWithSizeInCM(24.3, 12.0) : DTMakeRectWithSizeInCM(24.9, 12.6);
    debugRect = DTMakeRectWithSizeInCM(24.3, 12.0);
	
	// page front is always the production-only, so 12.6x1.6
	NSRect pageFBRect = DTMakeRectWithSizeInCM(12.6, 12.6);
	NSMutableArray *pageFrontObjs =  [NSMutableArray array];
	NSMutableArray *pageBackObjs =  [NSMutableArray array];

	// transform object in non-preview mode
	if (!preview) [innerCoverObjs addObject:[self prepareTransform]];
	[pageFrontObjs addObject:[self preparePageFrontTransform]];
	[pageBackObjs addObject:[self prepareTransform]];
	
    // inner-cover cover title
	obj = [PETextBlock textBlockWithDictionary:
        MERGEDICT(MERGEDICT(MERGEDICT(frontTitle, textFont16pt), bottomRightAlign), kerning200kerningCJK400)
        // [[frontTitle dictionaryByMergingDictionary:textFont16pt] dictionaryByMergingDictionary:bottomRightAlign]
        boundingRect:DTMakeRectInCM(12.3 + 1.0, 6.2, 10.0, DTpt2cm(18.0))];
    [innerCoverObjs addObject:obj];
	[pageFrontObjs addObject:obj];
        
    // inner-cover cover subtitle
	obj = [PETextBlock textBlockWithDictionary:
        MERGEDICT(MERGEDICT(MERGEDICT(frontSubtitle, textFont9pt), bottomRightAlign), kerning100kerningCJK200)	
        // [[frontSubtitle dictionaryByMergingDictionary:textFont9pt] dictionaryByMergingDictionary:bottomRightAlign]
        boundingRect:DTMakeRectInCM(12.3 + 1.0, 5.5, 10.0, DTpt2cm(14.0))];
    [innerCoverObjs addObject:obj];
	[pageFrontObjs addObject:obj];

    // inner-cover back title
	obj = [PETextBlock textBlockWithDictionary:
        [[frontTitle dictionaryByMergingDictionary:textFont6pt] dictionaryByMergingDictionary:bottomLeftAlign]
        boundingRect:DTMakeRectInCM(1.0, 10.3 + DTpt2cm(10.0), 10.0, DTpt2cm(10.0))];
    [innerCoverObjs addObject:obj];
	[pageBackObjs addObject:obj];
        
    // inner-cover back subtitle
    obj = [PETextBlock textBlockWithDictionary:
        [[frontSubtitle dictionaryByMergingDictionary:textFont6pt] dictionaryByMergingDictionary:bottomLeftAlign]
        boundingRect:DTMakeRectInCM(1.0, 10.3, 10.0, DTpt2cm(10.0))];
    [innerCoverObjs addObject:obj];
	[pageBackObjs addObject:obj];
        
    // barcode
    obj = [PEBarcodeCode39 barcodeWithDictionary:[barcode dictionaryByMergingDictionary:topLeftAlign]
        boundingRect:DTMakeRectInCM(1.0, 10.3 - DTpt2cm(5.0) - 1.06, 5.3, 1.06)];
    [innerCoverObjs addObject:obj];
	[pageBackObjs addObject:obj];
    
    // logo 1 & 2
    obj = [PEImageBox imageBoxWithDictionary:innerBackLogo1 boundingRect:DTMakeRectInCM(1.0, 1.0, 2.4, 1.2094)];
    [innerCoverObjs addObject:obj];
	[pageBackObjs addObject:obj];
        
    obj = [PEImageBox imageBoxWithDictionary:innerBackLogo2 boundingRect:DTMakeRectInCM(12.0 - 1.0 - 3.6, 1.0, 3.6, 0.9364)];
    [innerCoverObjs addObject:obj];
	[pageBackObjs addObject:obj];
    
    // promotional partner logo
    obj = [PEImageBox imageBoxWithDictionary:promotionPartnerLogo boundingRect:DTMakeRectInCM(4.7, 1.1, 1.943, 0.455)];
    [innerCoverObjs addObject:obj];
	[pageBackObjs addObject:obj];
    
    // cutting lines if in preview mode
    if (preview) {
        cuttingLine = [NSDictionary dictionaryWithObjectsAndKeys:
            textColor, @"stroke-color", 
            @"dash", @"stroke-style",
            @"none", @"fill-color", nil];
        
        [innerCoverObjs addObject:[PERectangle rectangleWithDictionary:cuttingLine boundingRect:
            DTMakeRectInCM(12.0, 0.0, 0.0, 12.0)]];
        [innerCoverObjs addObject:[PERectangle rectangleWithDictionary:cuttingLine boundingRect:
            DTMakeRectInCM(12.3, 0.0, 0.0, 12.0)]];
    }

	if (!preview) {
		#define DC(x1, y1, x2, y2) obj = [PERectangle rectangleWithDictionary:cropMark boundingRect:DTMakeRectInCM(x1 - 0.3, y1 - 0.3, x2-x1, y2-y1)]; [innerCoverObjs addObject:obj];
		DC(11.8, 0.0, 11.8, 0.2);
		DC(12.45, 0.0, 12.45, 0.2);
		DC(13.1, 0.0, 13.1, 0.2);

		DC(11.8, 12.4, 11.8, 12.6);
		DC(12.45, 12.4, 12.45, 12.6);
		DC(13.1, 12.4, 13.1, 12.6);
		#undef DC
	}
	// bounding rect in debug mode
	if ([self isDebugMode]) [innerCoverObjs addObject:[PEDrawableElement elementWithBoundingRect:debugRect]];

    // add inner-cover, page-front and page-back
    [pages setObject:[self prepareResult:innerCoverRect elements:innerCoverObjs] forKey:@"inner-cover"];
	[pages setObject:[self prepareResult:pageFBRect elements:pageFrontObjs] forKey:@"page-front"];
	[pages setObject:[self prepareResult:pageFBRect elements:pageBackObjs] forKey:@"page-back"];
    
    return pages;
}
- (NSDictionary*)prepareImageFull:(NSDictionary*)instruction {
    // the easiest type!
    NSRect pageRect = [self isPreviewMode] ? DTMakeRectWithSizeInCM(12.0, 12.0) : DTMakeRectWithSizeInCM(12.6, 12.6);
	NSRect imageRect = DTMakeRectWithSizeInCM(12.6, 12.6);

	NSMutableArray *array = [NSMutableArray array];
	if ([self isPreviewMode]) [array addObject:[self preparePreviewTransform]];
	[array addObject:[PEImageBox imageBoxWithDictionary:[instruction objectForKey:@"image" defaultValue:[NSDictionary dictionary]] boundingRect:imageRect]];
	
    return [self prepareResult:pageRect elements:array];
}
- (NSDictionary*)prepareBlankPage {
    NSRect pageRect = [self isPreviewMode] ? DTMakeRectWithSizeInCM(12.0, 12.0) : DTMakeRectWithSizeInCM(12.6, 12.6);
	return [self prepareResult:pageRect elements:
		[NSMutableArray arrayWithObject:
			[PERectangle rectangleWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"none", @"fill-color", @"none", @"stroke-color", nil]
			boundingRect:pageRect]]];
}
- (NSDictionary*)prepareImageLandscape:(NSDictionary*)instruction isLeftSide:(BOOL)leftSide
{
	float pageSize = 12.0;
	float imageOffsetX = 0.0;
	float imageOffsetY = 0.0;
	float imageSizeOffsetX = 0.0;
	float imageSizeOffsetY = 0.0;

	PEDrawableElement *bound = [PEDrawableElement elementWithBoundingRect:DTMakeRectWithSizeInCM(12.0, 12.0)];

	imageOffsetX = -0.3;
//	imageOffsetY = 0.15;
	imageSizeOffsetX = 0.6;
	imageSizeOffsetY = 0.45;

	if (![self isPreviewMode]) {
		pageSize = 12.6;
	}

    NSRect pageRect = DTMakeRectWithSizeInCM(pageSize, pageSize);
	
    NSDictionary *emptyDict = [NSDictionary dictionary];
    NSDictionary *instT = [instruction objectForKey:@"description" defaultValue:emptyDict];
    NSDictionary *instI = [instruction objectForKey:@"image" defaultValue:emptyDict];
    
    float textBoxHeight = DTpt2cm(10.0);
    
    PETextBlock *title = [PETextBlock
        textBlockWithDictionary:
            [instT dictionaryByMergingDictionary:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [self prepareFont8pt], @"font",
                    leftSide ? @"left" : @"right", @"align",
                    @"bottom", @"vertical-align",
                    nil]]
        boundingRect:
            leftSide ? DTMakeRectInCM(1.0, 0.5, 9.0, textBoxHeight) : 
                       DTMakeRectInCM(2.0, 0.5, 9.0, textBoxHeight)];
                       
    PEImageBox *image = [PEImageBox
        imageBoxWithDictionary:
            [[NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], @"bleed", nil] dictionaryByMergingDictionary:instI]
         boundingRect: DTMakeRectInCM(0.0 + imageOffsetX, 3.0 + imageOffsetY, 12.0 + imageSizeOffsetX, 9.0 + imageSizeOffsetY)];
         
	NSMutableArray *array = [NSMutableArray array];
	if (![self isPreviewMode]) [array addObject:[self prepareTransform]];
	if ([self isDebugMode]) [array addObject:bound];
	[array addObject:title];
	[array addObject:image];
		 
    return [self prepareResult:pageRect elements:array];
}
- (NSDictionary*)prepareImagePortrait:(NSDictionary*)instruction isLeftSide:(BOOL)leftSide {
	float pageSize = 12.0;
	float imageOffsetX = 0.0;
	float imageOffsetY = 0.0;
	float imageSizeOffsetX = 0.0;
	float imageSizeOffsetY = 0.0;

	PEDrawableElement *bound = [PEDrawableElement elementWithBoundingRect:DTMakeRectWithSizeInCM(12.0, 12.0)];

	imageOffsetX = leftSide ? -0.45 : 0;
	imageOffsetY = -0.3;
	imageSizeOffsetX = 0.45;
	imageSizeOffsetY = 0.6;

	if (![self isPreviewMode]) {
		pageSize = 12.6;
	}

    NSRect pageRect = DTMakeRectWithSizeInCM(pageSize, pageSize);
    
    NSDictionary *emptyDict = [NSDictionary dictionary];
    NSDictionary *instT = [instruction objectForKey:@"description" defaultValue:emptyDict];
    NSDictionary *instI = [instruction objectForKey:@"image" defaultValue:emptyDict];

    float textBoxWidth = DTpt2cm(10.0);
        
    PEVerticalTextBlock *title = [PEVerticalTextBlock
        textBlockWithDictionary:
            [instT dictionaryByMergingDictionary:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [self prepareFont8ptSameCJK], @"font",
                    leftSide ? @"left" : @"right", @"align",
                    @"top", @"vertical-align",
                    nil]]
        boundingRect:
            leftSide ? DTMakeRectInCM(9.5, 2.0, textBoxWidth, 9.0) : 
                       DTMakeRectInCM(3.0 - 0.5 - DTpt2cm(10.0), 2.0, DTpt2cm(10.0), 9.0)];
                       
    PEImageBox *image = [PEImageBox
        imageBoxWithDictionary:
            [instI dictionaryByMergingDictionary:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithBool:YES], @"bleed", nil]]
         boundingRect: 
            leftSide ? DTMakeRectInCM(0.0 + imageOffsetX, 0.0 + imageOffsetY, 9.0 + imageSizeOffsetX, 12.0 + imageSizeOffsetY) : 
					   DTMakeRectInCM(3.0 + imageOffsetX, 0.0 + imageOffsetY, 9.0 + imageSizeOffsetX, 12.0 + imageSizeOffsetY)];

	NSMutableArray *array = [NSMutableArray array];
	if (![self isPreviewMode]) [array addObject:[self prepareTransform]];
	if ([self isDebugMode]) [array addObject:bound];
	[array addObject:title];
	[array addObject:image];
		 
    return [self prepareResult:pageRect elements:array];
}
- (NSDictionary*)prepareImageCrossPage:(NSDictionary*)instruction isLeftSide:(BOOL)leftSide {
    NSDictionary *image = [instruction objectForKey:@"image" defaultValue:[NSDictionary dictionary]];
	NSRect pageRect = [self isPreviewMode] ? DTMakeRectWithSizeInCM(12.0, 12.0) : DTMakeRectWithSizeInCM(12.6, 12.6);
	NSRect imageRect = [self isPreviewMode] ? DTMakeRectWithSizeInCM(25.2, 12.6) : DTMakeRectWithSizeInCM(25.2, 12.6);
	
	PETransform *transform;
	
	transform = [PETransform transformWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:DTcm2pt(-12.4)], @"move-x",
		[NSNumber numberWithFloat:DTcm2pt(0.0)], @"move-y", nil]];
		
	PEImageBox *imagebox = [PEImageBox imageBoxWithDictionary:image boundingRect:imageRect];	

	NSMutableArray *array = [NSMutableArray array];
	if ([self isPreviewMode]) [array addObject:[self preparePreviewTransform]];
	if (!leftSide) [array addObject:transform];
	[array addObject:imagebox];
    return [self prepareResult:pageRect elements:array];
}
- (NSDictionary*)prepareWideBlankPage
{
    NSRect pageRect = DTMakeRectWithSizeInCM(24.0, 13.5);
	return [self prepareResult:pageRect elements:
		[NSMutableArray arrayWithObject:
			[PERectangle rectangleWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"none", @"fill-color", @"none", @"stroke-color", nil]
			boundingRect:pageRect]]];
}
- (NSDictionary*)prepareWideCover:(NSDictionary*)instruction isPreview:(BOOL)preview
{
	return nil;
}
- (NSDictionary*)prepareWideImageFull:(NSDictionary*)instruction isLeftSide:(BOOL)leftSide
{
    NSRect pageRect = DTMakeRectWithSizeInCM(24.0, 13.5);
	NSRect imageRect = leftSide
		? DTMakeRectInCM(0.0, 0.0, 18.0, 13.5)
		: DTMakeRectInCM(6.0, 0.0, 18.0, 13.5);
    return [self prepareResult:pageRect elements:
        [NSMutableArray arrayWithObject:
            [PEImageBox imageBoxWithDictionary:[instruction objectForKey:@"image" defaultValue:[NSDictionary dictionary]]
                boundingRect:pageRect]]];
}
- (NSDictionary*)prepareWideImageFullBleed:(NSDictionary*)instruction
{
    // the easiest type!
    NSRect pageRect = DTMakeRectWithSizeInCM(24.0, 13.5);
    return [self prepareResult:pageRect elements:
        [NSMutableArray arrayWithObject:
            [PEImageBox imageBoxWithDictionary:[instruction objectForKey:@"image" defaultValue:[NSDictionary dictionary]]
                boundingRect:pageRect]]];
}
- (NSDictionary*)prepareWideImageLandscape:(NSDictionary*)instruction isLeftSide:(BOOL)leftSide
{
	float pageWidth = 24.0;
	float pageHeight = 13.5;
	float imageWidth = 19.55;
	float imageHeight = 11.0;	
	float imageOffsetX = 0.75;
	float imageOffsetY = 1.75;
	float textWidth = 19.55;
	float textHeight = DTpt2cm(14.0);
	float textOffsetX = 0.75;
	float textOffsetY = 1.15;

	if (!leftSide) {
		imageOffsetX = 3.7;
		textOffsetX = 3.7;
	}

    NSRect pageRect = DTMakeRectWithSizeInCM(pageWidth, pageHeight);
	
    NSDictionary *emptyDict = [NSDictionary dictionary];
    NSDictionary *instT = [instruction objectForKey:@"description" defaultValue:emptyDict];
    NSDictionary *instI = [instruction objectForKey:@"image" defaultValue:emptyDict];
    
    PETextBlock *title = [PETextBlock
        textBlockWithDictionary:
            [instT dictionaryByMergingDictionary:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [self prepareFont9pt], @"font",
                    leftSide ? @"left" : @"right", @"align",
                    @"bottom", @"vertical-align",
//					@"white", @"color",
                    nil]]
        boundingRect:DTMakeRectInCM(textOffsetX, textOffsetY, textWidth, textHeight)];
                       
    PEImageBox *image = [PEImageBox
        imageBoxWithDictionary:
            [[NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], @"bleed", nil] dictionaryByMergingDictionary:instI]
         boundingRect: DTMakeRectInCM(imageOffsetX, imageOffsetY, imageWidth, imageHeight)];
         
	NSMutableArray *array = [NSMutableArray array];
	
//    [array addObject:[PERectangle rectangleWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"black", @"fill-color", @"black", @"stroke-color", nil] boundingRect:pageRect]];	
	[array addObject:title];
	[array addObject:image];
		 
    return [self prepareResult:pageRect elements:array];
}
- (NSDictionary*)prepareWideImagePortrait:(NSDictionary*)instruction isLeftSide:(BOOL)leftSide
{
	float pageWidth = 24.0;
	float pageHeight = 13.5;
	float imageWidth = 12.0;
	float imageHeight = 12.0;	
	float imageOffsetX = 0.75;
	float imageOffsetY = 0.75;
	float textWidth = 5.5;
	float textHeight = 12.0;
	float textOffsetX = 13.25;
	float textOffsetY = 0.75;

	if (!leftSide) {
		imageOffsetX = 11.25;
		textOffsetX = 5.25;
	}

    NSRect pageRect = DTMakeRectWithSizeInCM(pageWidth, pageHeight);

	
    NSDictionary *emptyDict = [NSDictionary dictionary];
    NSDictionary *instT = [instruction objectForKey:@"description" defaultValue:emptyDict];
    NSDictionary *instI = [instruction objectForKey:@"image" defaultValue:emptyDict];
    
    PETextBlock *title = [PETextBlock
        textBlockWithDictionary:
            [instT dictionaryByMergingDictionary:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [self prepareFont9pt], @"font",
                    @"left", @"align",
                    @"top", @"vertical-align",
//					@"white", @"color",					
                    nil]]
        boundingRect:DTMakeRectInCM(textOffsetX, textOffsetY, textWidth, textHeight)];
                       
    PEImageBox *image = [PEImageBox
        imageBoxWithDictionary:
            [[NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], @"bleed", nil] dictionaryByMergingDictionary:instI]
         boundingRect: DTMakeRectInCM(imageOffsetX, imageOffsetY, imageWidth, imageHeight)];
         
	NSMutableArray *array = [NSMutableArray array];
//    [array addObject:[PERectangle rectangleWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"black", @"fill-color", @"black", @"stroke-color", nil] boundingRect:pageRect]];	
	[array addObject:title];
	[array addObject:image];
		 
    return [self prepareResult:pageRect elements:array];
}
- (id)initWithInstruction:(NSDictionary*)instruction
{
    if (self = [super init]) {
        _numberOfPages = 0;
        _instruction = [[NSDictionary dictionaryWithDictionary:instruction] retain];
        _outputControl = [[NSDictionary dictionaryWithDictionary:[_instruction objectForKey:@"output-control" defaultValue:[NSDictionary dictionary]]] retain];
        
        // prepare cover
        NSMutableDictionary *prepared = [NSMutableDictionary dictionary];
        NSDictionary *objs;
        
        // cover is a special case, instruction may generate different pages
        // (e.g. bookcloth, cover, back, etc.)
        NSDictionary *coverobj = [_instruction objectForKey:@"cover"];
        
        if (coverobj) {
            objs = [self prepareCover:[_instruction objectForKey:@"cover"] isPreview:[self isPreviewMode]];
            if (objs) [prepared addEntriesFromDictionary:objs];

            objs = [self prepareWideCover:[_instruction objectForKey:@"cover"] isPreview:[self isPreviewMode]];
            if (objs) [prepared addEntriesFromDictionary:objs];
        }
        
        NSDictionary *giftwrappingObj = [_instruction objectForKey:@"giftwrapping-card"];
        
        if (giftwrappingObj) {
            objs = [self prepareGiftWrappingCard:giftwrappingObj isPreview:[self isPreviewMode]];
            [prepared addEntriesFromDictionary:objs];
        }
        
        // prepare pages
        NSArray *pages = [_instruction objectForKey:@"pages" defaultValue:[NSArray array]];
        unsigned int i, c=[pages count], pageno=1;
        BOOL isLeftSide;

        
        for (i=0; i<c; i++, pageno++) {
            // remember, real page number starts from 1
            NSString *pageTitle = [NSString stringWithFormat:@"page-%d", pageno];

            NSString *widePageTitle = [NSString stringWithFormat:@"wide-page-%d", pageno];
            
            // determine if it's a left-side page
            isLeftSide = (pageno%2) ? NO : YES;

            // prepare each page according to its type
            NSDictionary *pg = [pages objectAtIndex:i];
            NSString *type = [pg objectForKey:@"type" defaultValue:@""];
            
            if ([type isEqualToString:@"image-full"]) {
                objs = [self prepareImageFull:pg];
                [prepared setObject:objs forKey:pageTitle];

                objs = [self prepareWideImageFull:pg isLeftSide:isLeftSide];
                [prepared setObject:objs forKey:widePageTitle];
            }
            else if ([type isEqualToString:@"image-landscape"]) {
                objs = [self prepareImageLandscape:pg isLeftSide:isLeftSide];
                [prepared setObject:objs forKey:pageTitle];

                objs = [self prepareWideImageLandscape:pg isLeftSide:isLeftSide];
                [prepared setObject:objs forKey:widePageTitle];
            }
            else if ([type isEqualToString:@"image-portrait"]) {
                objs = [self prepareImagePortrait:pg isLeftSide:isLeftSide];
                [prepared setObject:objs forKey:pageTitle];
				
                objs = [self prepareWideImagePortrait:pg isLeftSide:isLeftSide];
                [prepared setObject:objs forKey:widePageTitle];				
            }
            else if ([type isEqualToString:@"image-crosspage"]) {
                objs = [self prepareImageCrossPage:pg isLeftSide:YES];
                [prepared setObject:objs forKey:pageTitle];            

                objs = [self prepareWideImageFullBleed:pg];
                [prepared setObject:objs forKey:widePageTitle];

                pageno++;
                pageTitle = [NSString stringWithFormat:@"page-%d", pageno];
				widePageTitle = [NSString stringWithFormat:@"wide-page-%d", pageno];
								
                objs = [self prepareImageCrossPage:pg isLeftSide:NO];
                [prepared setObject:objs forKey:pageTitle]; 

                [prepared setObject:[self prepareWideBlankPage] forKey:widePageTitle];
                [prepared setObject:objs forKey:pageTitle];    
            }
            else {
                // we just ignore it, or?
                // NSLog(@"unrecognized page type %@ at array index %d (page number %d)", type, i, i+1);
				objs = [self prepareBlankPage];
				[prepared setObject:objs forKey:pageTitle];
            }
        }
        
		// generate a blank page
		[prepared setObject:[self prepareBlankPage] forKey:@"blank1"];
		[prepared setObject:[self prepareBlankPage] forKey:@"blank2"];

		[prepared setObject:[self prepareWideBlankPage] forKey:@"wide-blank1"];
		[prepared setObject:[self prepareWideBlankPage] forKey:@"wide-blank2"];
		
        _numberOfPages = pageno - 1;
        _preparedPages = [[NSDictionary dictionaryWithDictionary:prepared] retain];
    }
    return self; 
}
- (void)dealloc {
    [_instruction release];
    [_outputControl release];
    [_preparedPages release];
    [super dealloc];
}
- (NSDictionary*)outputControl
{
    return _outputControl;
}
- (NSString*)description {
    return [[NSDictionary dictionaryWithObjectsAndKeys:
        _instruction, @"instruction",
        _outputControl, @"output-control",
        _preparedPages, @"prepared-pages",
        nil] description];
}
- (NSArray*)allPageLabels
{
    NSMutableArray *labels = [NSMutableArray array];
    
    [labels addObject:@"bookcloth"];
    [labels addObject:@"bookcloth-preview"];
    [labels addObject:@"bookcloth-cover-preview"];
    [labels addObject:@"inner-cover"];

    unsigned int i;
    for (i=1; i<=_numberOfPages; i++) [labels addObject:[self labelOfPageNumbered:i]];
    return [NSArray arrayWithArray:labels];
}
- (void)prepareElementsOnPageLabelled:(NSString*)label outputControl:(NSDictionary*)control
{
    NSDictionary *p = [_preparedPages objectForKey:label];
    if (!p) return;
    NSArray *e = [p objectForKey:@"elements"];
    if (!e) return;
    
    NSDictionary *mergedControl = [_outputControl dictionaryByMergingDictionary:control];
    
    unsigned int i, c=[e count];
    for (i=0; i<c; i++) {
        PEDrawableElement *de = [e objectAtIndex:i];
        [de prepareWithOutputControl:mergedControl];
    }
}
- (void)drawElementsOnPageLabelled:(NSString*)label outputControl:(NSDictionary*)control
{
    NSDictionary *p = [_preparedPages objectForKey:label];
    if (!p) return;
    NSArray *e = [p objectForKey:@"elements"];
    if (!e) return;
    
    NSDictionary *mergedControl = [_outputControl dictionaryByMergingDictionary:control];
    
    unsigned int i, c=[e count];
    for (i=0; i<c; i++) {
        PEDrawableElement *de = [e objectAtIndex:i];
        [de drawWithOutputControl:mergedControl];
    }
}
- (NSRect)boundingRectOfPageLabelled:(NSString*)label
{
    NSRect emptyRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    NSDictionary *p = [_preparedPages objectForKey:label];
    if (!p) return emptyRect;
    NSValue *v = [p objectForKey:@"page-rectangle"];
    if (!v) return emptyRect;
    return [v rectValue];
}
- (NSString*)labelOfPageNumbered:(unsigned int)pageNumber
{
    if (pageNumber < 1 || pageNumber > _numberOfPages) return nil;
    return [NSString stringWithFormat:@"page-%d", pageNumber];
}
@end
