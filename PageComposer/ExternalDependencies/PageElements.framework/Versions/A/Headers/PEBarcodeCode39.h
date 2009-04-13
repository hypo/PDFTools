// PEBarcodeCode39.h

// In JSON:
// {
//    "type":"barcode-code3of9",
//    "text":"",
//    "align":"center"
// }

#import <Cocoa/Cocoa.h>
#import "PEDrawableElement.h"

@interface PEBarcodeCode39 : PEDrawableElement <PEObjectInternalRepresentation, PEDrawableElementDraw>
{
    NSString *_text;
    NSString *_align;
    id _barcode;
    NSImage *_barcodeImage;
    BOOL _roundedCorner;
}
+ (id)barcodeWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (void)dealloc;
- (void)drawWithOutputControl:(NSDictionary*)controlData;
@end
