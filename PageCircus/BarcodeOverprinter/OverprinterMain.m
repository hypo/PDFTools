// [AUTO_HEADER]

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <NSExtensions/NSExtensions.h>
#import <DrawingTools/DrawingTools.h>
#import <PageElements/PageElements.h>

@interface ElementDrawer : NSObject
{
    PEDrawableElement *_element;
}
- (id)initWithElement:(PEDrawableElement*)element;
- (void)draw:(id)controlDictionary;
@end

@implementation ElementDrawer
- (id)initWithElement:(PEDrawableElement*)element
{
    if (self = [super init]) {
        _element = [element retain];
    }
    
    return self;
}
- (void)dealloc
{
    [_element release];
    [super dealloc];
}
- (void)draw:(id)controlDictionary
{
    [_element drawWithOutputControl:controlDictionary];    
}
@end


int main(int argc, char *argv[])
{
    if (argc < 5) {
        fprintf(stderr, "usage: BarcodeOverprinter file part barcode output\n");
        return 1;
    }
    
    NSApplicationLoad();
    id arp = [NSAutoreleasePool new];
    
    NSString *sourceFilename = [NSString stringWithUTF8String:argv[1]];
    NSString *partName = [NSString stringWithUTF8String:argv[2]];
    NSString *barcodeText = [NSString stringWithUTF8String:argv[3]];
    NSString *outputFilename = [NSString stringWithUTF8String:argv[4]];
    NSDictionary *topLeftAlignDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"left", @"align", @"top", @"vertical-align", nil];
    NSDictionary *alignDictionary;
    NSDictionary *barcodeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:barcodeText, @"text", nil];
    NSRect barcodeRect;
    NSPoint barcodeOrigin;
    
    if ([partName isEqualToString:@"bookcloth"]) {        
        barcodeRect = DTMakeRectInCM(0.0, 0.0, 5.3, 1.9);
        barcodeOrigin = DTMakePointInCM(1.0 + 0.3, -0.3 + 0.3);
        alignDictionary = [NSDictionary dictionaryWithObject: @"YES" forKey: @"rounded-corner"];
    }
	else if ([partName isEqualToString:@"inner-cover"]) {
        barcodeOrigin = DTMakePointInCM(1.0 + 0.3, 10.3 - DTpt2cm(5.0) - 1.06 + 0.3);
        barcodeRect = DTMakeRectInCM(0.0, 0.0, 5.3, 1.06);
        alignDictionary = topLeftAlignDictionary;
	}
    else {
		// page-40
        barcodeOrigin = DTMakePointInCM(1.0 + 0.3, 10.3 - DTpt2cm(5.0) - 1.06 + 0.3);
        barcodeRect = DTMakeRectInCM(0.0, 0.0, 5.3, 1.06);
        alignDictionary = topLeftAlignDictionary;
    }
        
    PEBarcodeCode39 *barcode = [PEBarcodeCode39 barcodeWithDictionary:[barcodeDictionary dictionaryByMergingDictionary:alignDictionary] boundingRect:barcodeRect];   
    ElementDrawer *barcodeDrawer = [[[ElementDrawer alloc] initWithElement:barcode] autorelease];
    
    NSLog(@"reading: %@", sourceFilename);
    NSData *sourceData = [NSData dataWithContentsOfFile:sourceFilename];
    if (!sourceData) {
        fprintf(stderr, "fatal error: cannot open %s\n", argv[1]);
        return 1;
    }
    
    CGDataProviderRef sourceDataProvider = CGDataProviderCreateWithCFData((CFDataRef)sourceData);
    if (!sourceDataProvider) {
        fprintf(stderr, "fatal error: cannot create source data provider\n");
        return 1;
    }    
    
    CGPDFDocumentRef sourcePDFDocument = CGPDFDocumentCreateWithProvider(sourceDataProvider);
    if (!sourcePDFDocument) {
        fprintf(stderr, "fatal error: cannot create source PDF document\n");
        return 1;
    }
    
    CGPDFPageRef sourcePage = CGPDFDocumentGetPage(sourcePDFDocument, 1);
    if (!sourcePage) {
        fprintf(stderr, "fatal error: cannot get source page 1\n");
        return 1;
    }
    
    CGRect sourcePageBox = CGPDFPageGetBoxRect(sourcePage, kCGPDFMediaBox);
    NSLog(@"Source page 1 media box: (%f, %f), (%f x %f)", sourcePageBox.origin.x, sourcePageBox.origin.y, sourcePageBox.size.width, sourcePageBox.size.height);
    
    NSMutableData *targetData = [NSMutableData data];    
    CGDataConsumerRef targetDataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)targetData);
    CGContextRef targetContext = CGPDFContextCreate(targetDataConsumer, &sourcePageBox, NULL);
    CGPDFContextBeginPage(targetContext, NULL);
    CGContextDrawPDFPage(targetContext, sourcePage);

    barcodeRect = [barcode boundingRect];
    DTDrawingView *barcodeDrawingView = [[[DTDrawingView alloc] initWithFrame:barcodeRect delegate:barcodeDrawer drawingSelector:@selector(draw:) argument:[NSDictionary dictionary]] autorelease];
    NSData *barcodeData = [barcodeDrawingView dataWithPDFInsideRect:barcodeRect];
    CGDataProviderRef barcodeDataProvider = CGDataProviderCreateWithCFData((CFDataRef)barcodeData);
    CGPDFDocumentRef barcodePDFDocument = CGPDFDocumentCreateWithProvider(barcodeDataProvider);
    CGPDFPageRef barcodePage = CGPDFDocumentGetPage(barcodePDFDocument, 1);
    
    CGRect drawRect = *(CGRect*)&barcodeRect;
    drawRect.origin = *(CGPoint*)&barcodeOrigin;
    CGContextDrawPDFDocument(targetContext, drawRect, barcodePDFDocument, 1);

    CGPDFContextEndPage(targetContext);
    // CGPDFContextClose(targetContext);
    CFRelease(targetContext);
    CFRelease(targetDataConsumer);
    
    [targetData writeToFile:outputFilename atomically:YES];
    
    CFRelease(sourcePDFDocument);
    CFRelease(sourceDataProvider);
    [arp release];
    return 0;
}
