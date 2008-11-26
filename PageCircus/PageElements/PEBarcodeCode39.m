// PEBarcodeCode39.m

#import "PEBarcodeCode39.h"
#import "NSExtensions.h"

#import "NKDBarcode.h"
#import "NKDBarcodeOffscreenView.h"
#import "NKDCode39Barcode.h"

@implementation PEBarcodeCode39 : PEDrawableElement
+ (id)barcodeWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    return [[[PEBarcodeCode39 alloc] initWithDictionary:dict boundingRect:boundingRect] autorelease];
    
}
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    NSDictionary *d = dict ? dict : [NSDictionary dictionary];
	if (self = (PEBarcodeCode39*)[super initWithBoundingRect:boundingRect]) {
        _roundedCorner = [[d objectForKey: @"rounded-corner" defaultValue: @"N"] boolValue];
        _text = [[NSString alloc] initWithString:[d objectForKey:@"text" defaultValue:@""]];
        _align = [[NSString alloc] initWithString:[d objectForKey:@"align" defaultValue:@"center"]];
        
        _barcode = [[NKDCode39Barcode alloc] initWithContent:_text printsCaption:YES];
        
        if ([_barcode isContentValid]) {
            float totalHeight = 1.0 / 2.54 * 72.0;
            float shift = 1.656543;
            
            [_barcode setBarWidth:10.0/1000.0*72];
            [_barcode setFontSize:9.0];
            [_barcode setCaptionHeight: 0.3 / 2.54 + shift / 72];
            [_barcode setHeight: totalHeight + shift];
            [_barcode calculateWidth];
            
            NKDBarcodeOffscreenView *v = [[NKDBarcodeOffscreenView alloc] initWithBarcode:_barcode];
            NSData *d =  [v dataWithPDFInsideRect:[v rectForPage:0]];
            [v release];
            _barcodeImage = [[NSImage alloc] initWithData:d];
        }
        if (_roundedCorner) {
            _boundingRect.size.width = [_barcodeImage size].width + 0.4 / 2.54 * 72;
//            _boundingRect.size.height = [_barcodeImage size].height + 0.6 / 2.54 * 72;
        }
	}
	return self;
}
- (void)dealloc
{
    [_barcode release];
    [_barcodeImage release];
    [_text release];
    [_align release];
    [super dealloc];
}
- (NSDictionary*)internalDictionaryRepresentation
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
        @"barcode-code3of9", @"type",
        _text, @"text", nil];
    
    return [[super internalDictionaryRepresentation] dictionaryByMergingDictionary:result];
}
- (void)drawWithOutputControl:(NSDictionary*)controlData
{    
    [super drawWithOutputControl:controlData];

    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    
    // fill the background
    [[NSColor whiteColor] setFill];

    if (!_roundedCorner) {
        [NSBezierPath fillRect:_boundingRect];        
    } else {
        float radius = 0.3 / 2.54 * 72;
        NSRect wholeRect = _boundingRect;
        NSLog(@"%@", NSStringFromRect(wholeRect));
        
        NSBezierPath *result = [NSBezierPath bezierPath];
        
        NSPoint topLeft = NSMakePoint(NSMinX(wholeRect), NSMaxY(wholeRect));
        NSPoint topRight = NSMakePoint(NSMaxX(wholeRect), NSMaxY(wholeRect));
        NSPoint bottomRight = NSMakePoint(NSMaxX(wholeRect), NSMinY(wholeRect));
        
        [result moveToPoint: wholeRect.origin];
        [result appendBezierPathWithArcFromPoint: topLeft toPoint: topRight radius: radius];
        [result appendBezierPathWithArcFromPoint: topRight toPoint: bottomRight radius: radius];
        [result lineToPoint: bottomRight];
        [result closePath];
        
        [[NSColor colorWithDeviceCyan: 0.0 magenta: 0.0 yellow: 0.0 black: 0.0 alpha: 1.0] set];
        [result fill];
        
        [[NSColor colorWithDeviceCyan: 0.0 magenta: 0.0 yellow: 0.0 black: 1.0 alpha: 1.0] set];
        [result setLineWidth: 0.5];
        [result stroke];
    }

    NSSize s = [_barcodeImage size];
    NSPoint p = NSMakePoint(
        [_align isEqualToString:@"center"] ? _boundingRect.origin.x + (_boundingRect.size.width - s.width)/2 : _boundingRect.origin.x, 
                            _roundedCorner ? NSMaxY(_boundingRect) - (0.3 / 2.54 * 72) - s.height : _boundingRect.origin.y + (_boundingRect.size.height - s.height)/2);
    if (_roundedCorner)
        p.x += 0.03 / 2.54 * 72; // make a little bit shift to center the barcode

    [_barcodeImage compositeToPoint:p operation:NSCompositeCopy];
    
    [context restoreGraphicsState];
}
@end

