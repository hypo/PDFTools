// PEImageBox.h

// In JSON:
// {
//     "type":"image-box",
//     "source": {
//         "original": "(the URL/path for the original image)",
//         "large": "(the URL/path for the image with the longest side = 1024)",
//         "medium": "(the URL/path for the image with the longest side = 500)",
//         "small": "(the URL/path for the image with the longest side = 240)",
//         "thumbnail": "(the URL/path for the image with the longest side = 100)",
//         "square": "(the URL/path for the image 75x75, not used here)"
//     },
//     "crop": {
//         "x":0.0,     /* 1.0 = image width (unreleated to image height) */
//         "y":0.0,     /* 1.0 = image height (unrelated to image width) */
//         "w":1.0,     /* 1.0 = full width (unrelated to height) */
//         "h":1.0      /* 1.0 = full height (unrelated to width) */
//     },
//	   "rotation": 0.0,	/* image must be rotated before it can be really used */
//	   "dpi": 0.0,      /* the desirable DPI against the longest side of the draw rect */
//     "bleed": true,   /* false */
//     "raidus": 0.0    /* border radius of the image */
// }
//
// output-control directive:
//     "image-quality": "original"  /* large, medium, small, thumbnail, square */
//     "image-provider": {}         /* MUST PROVIDE AN id<PEImageProvider> image source */

#import <Cocoa/Cocoa.h>
#import "PEDrawableElement.h"

@protocol PEImageProvider <NSObject>
// imageSource can be a URI (e.g. beginning with http://) or a pathname
- (NSImage*)useImage:(NSString*)imageSource;
@end

@interface PEImageBox : PEDrawableElement <PEObjectInternalRepresentation, PEDrawableElementDraw>
{
	NSImage *_preparedImage;
	NSDictionary *_source;
	BOOL _bleed;
	float _cropX, _cropY, _cropW, _cropH;
	float _rotation;
	float _dpi;
	float _radius;
	
	BOOL _tiffPassThru;
}
+ (id)imageBoxWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect;
- (void)dealloc;
- (BOOL)prepareWithOutputControl:(NSDictionary*)controlData;
- (void)drawWithOutputControl:(NSDictionary*)controlData;
@end
