// DTImageBox.h


// {
//     source: {
//         "original": "(the URL/path for the original image)",
//         "large": "(the URL/path for the image with the longest side = 1024)",
//         "medium": "(the URL/path for the image with the longest side = 500)",
//         "small": "(the URL/path for the image with the longest side = 240)",
//         "thumbnail": "(the URL/path for the image with the longest side = 100)",
//         "square": "(the URL/path for the image 75x75, not used here)"
//     },
//     crop: {
//         x:0.0,
//         y:0.0,
//         w:1.0,
//         h:1.0,
//     },
//     bleed: true
// }

#import <Cocoa/Cocoa.h>
#import "DTImageProviderInterface.h"
#import "DTElementInterface.h"

@interface DTImageBox : NSObject <DTElement>
{
	NSDictionary *_source;
	BOOL _bleed;
	float _cropX, _cropY, _cropW, _cropH;
	
	NSRect _boundingRect;
	NSString *_quality;
	id<DTImageProvider> _provider;
}
- (DTImageBox*)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect quality:(NSString*)quality imageProvider:(id<DTImageProvider>)provider;
+ (DTImageBox*)imageBoxWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect quality:(NSString*)quality imageProvider:(id<DTImageProvider>)provider;
- (void)dealloc;
- (void)draw;
@end

void DTDrawImageBoxInRect(NSRect boundingRect, NSDictionary *dict, NSString *quality, id<DTImageProvider> provider);
