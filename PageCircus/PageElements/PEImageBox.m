// PEImageBox.m

#import "PEImageBox.h"
#import "NSExtensions.h"

void PEDrawImageInRect(NSImage *image, NSRect frame, BOOL bleed, BOOL useCropRect, NSRect cropRect, BOOL wantJPEGCompression);

@implementation PEImageBox : PEDrawableElement
+ (id)imageBoxWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    return [[[PEImageBox alloc] initWithDictionary:dict boundingRect:boundingRect] autorelease];
}
- (id)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect
{
    if (self = (PEImageBox*)[super initWithBoundingRect:boundingRect]) {
        _source = [[NSDictionary alloc] initWithDictionary:[dict objectForKey:@"source" defaultValue:[NSDictionary dictionary]]];
        _bleed = [dict objectForKey:@"bleed"] ? [dict isKeyTrue:@"bleed"] : YES;

        _tiffPassThru = [dict objectForKey:@"tiff-pass-through"] ? [dict isKeyTrue:@"tiff-pass-through"] : NO;

		NSDictionary *crop = [dict objectForKey:@"crop" defaultValue:[NSDictionary dictionary]];
		#define FV(dd, kk, ff) [[dd objectForKey:kk defaultValue:[NSNumber numberWithFloat:ff]] floatValue]
		_cropX = FV(crop, @"x", 0.0);
		_cropY = FV(crop, @"y", 0.0);
		_cropW = FV(crop, @"w", 1.0);
		_cropH = FV(crop, @"h", 1.0);
		#undef FV

		_rotation = [[dict objectForKey:@"original-rotation" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];
		_dpi = [[dict objectForKey:@"dpi" defaultValue:[NSNumber numberWithFloat:0.0]] floatValue];
		
		_preparedImage = nil;
    }
    return self;
}
- (void)dealloc
{
	[_preparedImage release];
    [_source release];
    [super dealloc];
}
- (NSDictionary*)internalDictionaryRepresentation
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
        @"image-box", @"type",
        _source, @"source",
        [NSNumber numberWithBool:_bleed], @"bleed",
		[NSNumber numberWithFloat:_dpi], @"dpi",
		[NSNumber numberWithFloat:_rotation], @"rotation",
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:_cropX], @"x",
            [NSNumber numberWithFloat:_cropY], @"y",
            [NSNumber numberWithFloat:_cropW], @"w",
            [NSNumber numberWithFloat:_cropH], @"h", nil], @"crop",
        nil];
    
    return [[super internalDictionaryRepresentation] dictionaryByMergingDictionary:result];
}
- (NSString*)chooseSourceWithQuality:(NSString*)quality fallbackDictionary:(NSDictionary*)dict
{
	// fba = fallback array
	NSArray *ofba = [NSArray arrayWithObjects:@"original", @"large", @"medium", @"small", @"thumbnail", nil];
	NSArray *lfba = [NSArray arrayWithObjects:@"large", @"medium", @"small", @"thumbnail", nil];
	NSArray *mfba = [NSArray arrayWithObjects:@"medium", @"small", @"thumbnail", nil];
	NSArray *sfba = [NSArray arrayWithObjects:@"small", @"thumbnail", nil];
	NSArray *tfba = [NSArray arrayWithObjects:@"thumbnail", nil];
	NSDictionary *fbd = [NSDictionary dictionaryWithObjectsAndKeys:
		ofba, @"original",
		lfba, @"large",
		mfba, @"medium",
		sfba, @"small",
		tfba, @"thumbnail", nil];
	
	NSArray *fba = [fbd objectForKey:quality];
	if (!fba) return nil;
	
	unsigned int i, c = [fba count];
	for (i = 0; i < c; i++) {
		NSString *str = [dict objectForKey:[fba objectAtIndex:i]];
		if (str) {
			return str;
		}
	}
	return nil;
}
- (NSString*)imageQuality:(NSDictionary*)controlData
{
	float threshold = 0.8;		
	NSString *quality = [controlData objectForKey:@"image-quality" defaultValue:@"original"];
	
	if ([controlData isKeyTrue:@"upgrade-preview-image-quality"]) {
		if (_cropW < threshold || _cropH < threshold) {
			NSString *newquality = quality;
			if ([quality isEqualToString:@"thumbnail"])  newquality = @"small";
			if ([quality isEqualToString:@"small"]) newquality = @"medium";
			if ([quality isEqualToString:@"medium"]) {
				NSString *large = [_source objectForKey:@"large"];
				NSString *original = [_source objectForKey:@"original"];				
				if (large && original) {
					if ([large isEqualToString:original]) {
						newquality = @"large";
					}
				}
			}
			if ([quality isEqualToString:@"large"]) {
				NSString *large = [_source objectForKey:@"large"];
				NSString *original = [_source objectForKey:@"original"];				
				if (large && original) {
					if ([large isEqualToString:original]) {
						newquality = @"original";
					}
				}
			}
			quality = newquality;
			
			NSLog(@"quality upgrade, original=%@, now=%@", [controlData objectForKey:@"image-quality" defaultValue:@"original"], quality);
		}
	}
	return quality;
}
- (void)drawWithOutputControl:(NSDictionary*)controlData
{
    [super drawWithOutputControl:controlData];

    id provider = [controlData objectForKey:@"image-provider"];
    if (![provider conformsToProtocol:@protocol(PEImageProvider)]) return;
    
    NSString *quality = [self imageQuality:controlData];
    NSString *source = [self chooseSourceWithQuality:quality fallbackDictionary:_source];
    if (!source) return;
	if (![source isKindOfClass:[NSString class]]) {
		NSLog(@"Cannot draw a source that is NULL");
		return;
	}

    if (![source length]) return;
	
    NSImage *image = _preparedImage;
	if (image) {
		NSLog(@"using prepared image!");
	}
	
	if (!image) {
		NSLog(@"no prepared image available, loading image from provider");
		image = [provider useImage:source];
	}
	
    if (!image) return;
	    
    NSSize size = [image size];
	
	NSLog(@"actual drawing, size=%.2f x %.2f", size.width, size.height);
	
    NSRect cropRect = NSMakeRect(size.width * _cropX, size.height * (1 - (_cropY + _cropH)), size.width * _cropW, size.height * _cropH);

    NSString *extension = [[source pathExtension] lowercaseString];

    if ([extension isEqualToString: @"jpeg"] || [extension isEqualToString: @"jpg"]) {
        PEDrawImageInRect(image, _boundingRect, _bleed, YES, cropRect, YES);
    } else {
        PEDrawImageInRect(image, _boundingRect, _bleed, YES, cropRect, NO);
    }
}
- (BOOL)prepareWithOutputControl:(NSDictionary*)controlData
{
	if (![super prepareWithOutputControl:controlData]) return NO;
	
	if (controlData) ;
	// get the image

    id provider = [controlData objectForKey:@"image-provider"];
    if (![provider conformsToProtocol:@protocol(PEImageProvider)]) return NO;
    
    NSString *quality = [self imageQuality:controlData];
	
	NSLog(@"prepare block, quality=%@, rotation=%f", quality, _rotation);
	
    NSString *source = [self chooseSourceWithQuality:quality fallbackDictionary:_source];
    if (!source) return NO;
	if (![source isKindOfClass:[NSString class]]) {
		NSLog(@"strange things happened, why is this not an NSString?");
		return NO;
	}
	
    if (![source length]) return NO;
	
	if (![quality isEqualToString:@"original"] /* || _rotation==0.0 */ || _tiffPassThru) {
		NSLog(@"using the original image only, no clipping");
		
		_preparedImage = [provider useImage:source];
		if (!_preparedImage) return NO;
		
		[_preparedImage retain];
		return YES;
	}

	NSLog(@"drawing rotated image");
	NSImage *sourceImage = [provider useImage:source];
	if (!sourceImage) return NO;
	
	[sourceImage setCacheMode:NSImageCacheNever];
	
	NSBitmapImageRep *bitmap = [[sourceImage representations] objectAtIndex:0];
	
	float maxLongSide = [[controlData objectForKey:@"maximum-longest-side" defaultValue:[NSNumber numberWithFloat:-1.0]] floatValue];
	
	float width = [bitmap pixelsWide];
	float height = [bitmap pixelsHigh];
	
	float longSide, shortSide;
	if (width > height) {
		longSide = width;
		shortSide = height;
	}
	else {
		longSide = height;
		shortSide = width;		
	}
	
	NSLog(@"original width=%.2f, height=%.2f, short/long=%.2f, max=%.2f", width, height, shortSide/longSide, maxLongSide);
	
	if (maxLongSide > 0.0) {
		if (longSide > maxLongSide && (shortSide/longSide)>=0.65) {
			if (width > height) {
				width = maxLongSide;
				height = width * (shortSide/longSide);
			}
			else {
				height = maxLongSide;
				width = height * (shortSide/longSide);
			}
			
			NSLog(@"after adjustment, width=%.2f, height=%.2f", width, height);
		}
		else {
			NSLog(@"no adjustment");
		}
	}
	
	// width = width * 2.0;
	// height = height * 2.0;
	
	NSRect sourceRect, targetRect;
	sourceRect.origin = NSMakePoint(0.0, 0.0);
	sourceRect.size = [sourceImage size];
	targetRect.origin = NSMakePoint(0.0, 0.0);
	
	
	// we must retain this aspect ratio because we're drawing the rotated image as if it wasn't rotated
	targetRect.size = NSMakeSize(width, height);
	
	if (_rotation != 180.0 && _rotation != 0.0) {
		float tmp = width;
		width = height;
		height = tmp;
	}
		
	NSLog(@"source rect = %.1f, %1f; %.1f x %.1f", sourceRect.origin.x, sourceRect.origin.y, sourceRect.size.width, sourceRect.size.height);
	NSLog(@"target rect = %.1f, %1f; %.1f x %.1f", targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height);
	
	_preparedImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
	[_preparedImage lockFocus];

	NSRect imageRect = NSMakeRect(0.0, 0.0, width, height);
	
	NSRect cropRect = NSMakeRect(width * _cropX - 2.0, height * (1.0 - (_cropY + _cropH)) - 2.0, width * _cropW + 4.0, height * _cropH + 4.0);
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[_preparedImage setCacheMode:NSImageCacheNever];
	
	NSBezierPath *cropPath = [NSBezierPath bezierPathWithRect:cropRect];
	[cropPath setClip];

/*	
	if (abs(sourceRect.size.width - targetRect.size.width) > 0.9) {
		NSLog(@"scale %f, %f", targetRect.size.width / sourceRect.size.width, targetRect.size.height / sourceRect.size.height);
		[transform translateXBy:targetRect.size.width / sourceRect.size.width yBy:targetRect.size.height / sourceRect.size.height];
	}
*/

	NSLog(@"(NO!) scale %f, %f", targetRect.size.width / sourceRect.size.width, targetRect.size.height / sourceRect.size.height);

	if (_rotation != 0.0) {
		float realrotation = 360.0 - _rotation;
		
		
		[transform rotateByDegrees:realrotation];
		
		if (realrotation == 90.0) {
			[transform translateXBy:0 yBy:-targetRect.size.height];
		}
		else if (realrotation == 180.0) {
			[transform translateXBy:-targetRect.size.width yBy:-targetRect.size.height];
		}
		else if (realrotation == 270.0) {
			[transform translateXBy:-targetRect.size.width yBy:0.0];
		}

		[transform concat];
	}
	
	[sourceImage drawInRect:targetRect fromRect:sourceRect operation:NSCompositeCopy fraction:1.0];
	
	[_preparedImage unlockFocus];
/*	
	// first, we prepare the rotated image
	if (_rotation != 0.0) {
		
	}
	
	// then if there is DPI constraint
	if (_dpi > 0.0) {
		// get the image's real DPI
		NSImageRep *imageRep = [_preparedImage bestRepresentationForDevice:nil];
		float imagelongSideestSide = 
		return (float)[imageRep pixelsWide] / ([image size].width / 72.0);
		
		//
		

		NSSize size = [image size];
		NSRect cropRect = NSMakeRect(size.width * _cropX, size.height * (1 - (_cropY + _cropH)), size.width * _cropW, size.height * _cropH);
		PEDrawImageInRect(image, _boundingRect, _bleed, YES, cropRect);
	}
*/	
	return YES;
}
@end

void PEDrawImageInRect(NSImage *image, NSRect frame, BOOL bleed, BOOL useCropRect, NSRect cropRect, BOOL wantJPEGCompression)
{
	NSRect imageRect, drawRect = frame;
	if (useCropRect) {
		imageRect = cropRect;
	}
	else {
		imageRect.origin = NSMakePoint(0.0, 0.0);
		imageRect.size = [image size];
	}
	
	float imageWHRatio = imageRect.size.width / imageRect.size.height;
	float frameWHRatio = frame.size.width / frame.size.height;
	float imageFrameWRatio = imageRect.size.width / frame.size.width;
	float imageFrameHRatio = imageRect.size.height / frame.size.height;
	float adjusted;
	
	if (bleed) {
		if (imageWHRatio > frameWHRatio) {
			// image's W is wider than frame's, blow up H and crop W
			adjusted = frame.size.width * imageFrameHRatio;
			imageRect.origin.x += (imageRect.size.width - adjusted) / 2;
			imageRect.size.width = adjusted;
		}
		else {
			// image's H is taller than frame's, blow up W and crop H
			adjusted = frame.size.height * imageFrameWRatio;
			imageRect.origin.y += (imageRect.size.height - adjusted) / 2;
			imageRect.size.height = adjusted;
		}
	}
	else {
		if (imageWHRatio > frameWHRatio) {
			// image's W is wider than frame's, shrink frame's W
			adjusted = imageRect.size.height / imageFrameWRatio;
			drawRect.origin.y += (drawRect.size.height - adjusted) / 2;
			drawRect.size.height = adjusted;
		}
		else {
			// image's H is taller than frame's, shrink frame's H
			adjusted = imageRect.size.width / imageFrameHRatio;
			drawRect.origin.x += (drawRect.size.width - adjusted) / 2;
			drawRect.size.width = adjusted;
		}
	}

    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];	

    // yllan's addition code to crop the image and compress to jpeg
    if (wantJPEGCompression) {
        NSImage *croppedImage;
        int width = [[[image representations] objectAtIndex: 0] pixelsWide];
        int height = [[[image representations] objectAtIndex: 0] pixelsHigh];
        float scaleX = (float)width / [image size].width;
        float scaleY = (float)height / [image size].height;
        NSSize croppedSize = NSMakeSize(imageRect.size.width * scaleX, imageRect.size.height * scaleY);
        NSRect croppedImageRect;
        croppedImageRect.origin = NSZeroPoint;
        croppedImageRect.size = croppedSize;
        croppedImage = [[[NSImage alloc] initWithSize: croppedSize] autorelease];
        [croppedImage lockFocus];
        [image drawInRect: croppedImageRect fromRect: imageRect operation: NSCompositeCopy fraction: 1.0];        
        [croppedImage unlockFocus];

        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData: [croppedImage TIFFRepresentation]];
        NSData *jpegImageData = [imageRep representationUsingType: NSJPEGFileType properties: [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat: 0.9] forKey: NSImageCompressionFactor]];
        
        CGContextRef cgContext = [context graphicsPort];
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef) jpegImageData);
        CGImageRef cgImage = CGImageCreateWithJPEGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
        
        CGContextSaveGState(cgContext);
        CGContextDrawImage(cgContext, *(CGRect*)&drawRect, cgImage);
        CGContextRestoreGState(cgContext);
        
        CGImageRelease(cgImage);
        CGDataProviderRelease(provider);
    } else {
        [image drawInRect:drawRect fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
    }
	[context restoreGraphicsState];	
}
