// LFSimpleGraphics
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#include "LFSimpleGraphics.h"

using namespace LFSimpleGraphics;

CGImageRef ImageHelper::CreateImageFromJPEGData(CFDataRef data)
{
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
	if (provider) {
		CGImageRef image = CGImageCreateWithJPEGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
		CFRelease(provider);
		return image;
	}
	return NULL;
}

CGImageRef ImageHelper::CreateImageFromPNGData(CFDataRef data)
{
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
	if (provider) {
		CGImageRef image = CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
		CFRelease(provider);
		return image;
	}
    return NULL;
}

CGImageRef ImageHelper::CreateImageByScaleTo(CGImageRef sourceImage, size_t width, size_t height)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, rgb, kCGImageAlphaPremultipliedLast);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), sourceImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    CGColorSpaceRelease(rgb);
    return scaledImage;
}

CGImageRef ImageHelper::CreateImageFromJPEGDataWithCompression(CFDataRef data, CGFloat compressionRatio)
{
    CGImageSourceRef imageSource = CGImageSourceCreateWithData(data, NULL);
    if (!imageSource) return NULL;
        
    CFMutableDataRef compressedJPEGData = CFDataCreateMutable(kCFAllocatorDefault, 0);

    CFNumberRef ratio = CFNumberCreate(kCFAllocatorDefault, kCFNumberCGFloatType, &compressionRatio);
    CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&kCGImageDestinationLossyCompressionQuality, (const void **)&ratio, (CFIndex)1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData(compressedJPEGData, kUTTypeJPEG, 1, NULL);
    
    CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, options);

    bool success = CGImageDestinationFinalize(imageDestination);
    
    CFRelease(ratio);
    CFRelease(options);
    CFRelease(imageSource);
    CFRelease(imageDestination);
    
    CGImageRef cgImage = NULL;
    if (success) {
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(compressedJPEGData);
        cgImage = CGImageCreateWithJPEGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease(provider);
    }
    CFRelease(compressedJPEGData);    
    return cgImage;
}

CGImageRef ImageHelper::CreateImageFromImageWithRotation(CGImageRef sourceImage, CGFloat degree)
{
    if (!(degree == 90 || degree == 180 || degree == 270)) 
        return NULL;
    
    size_t width = (degree == 180) ? CGImageGetWidth(sourceImage) : CGImageGetHeight(sourceImage);
    size_t height = (degree == 180) ? CGImageGetHeight(sourceImage) : CGImageGetWidth(sourceImage); 
    
    CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, rgb, kCGImageAlphaPremultipliedLast);
    
    if (degree == 90) {
        CGContextRotateCTM(ctx, M_PI_2);
        CGContextTranslateCTM(ctx, 0, -((CGFloat)CGImageGetHeight(sourceImage)));
    } else if (degree == 180) {
        CGContextRotateCTM(ctx, M_PI);
        CGContextTranslateCTM(ctx, -((CGFloat)CGImageGetWidth(sourceImage)), -((CGFloat)CGImageGetHeight(sourceImage)));
    } else if (degree == 270) {
        CGContextRotateCTM(ctx, M_PI_2 * 3);
        CGContextTranslateCTM(ctx, -((CGFloat)CGImageGetWidth(sourceImage)), 0);
    }
    CGContextDrawImage(ctx, CGRectMake(0, 0, (CGFloat)CGImageGetWidth(sourceImage), (CGFloat)CGImageGetHeight(sourceImage)), sourceImage);
    
    CGImageRef rotatedImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    CGColorSpaceRelease(rgb);
    return rotatedImage;
}

CGImageRef ImageHelper::CreateImageFromImageWithCompression(CGImageRef sourceImage, CGFloat compressionRatio)
{
    CFMutableDataRef compressedJPEGData = CFDataCreateMutable(kCFAllocatorDefault, 0);
    
    CFNumberRef ratio = CFNumberCreate(kCFAllocatorDefault, kCFNumberCGFloatType, &compressionRatio);
    CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&kCGImageDestinationLossyCompressionQuality, (const void **)&ratio, (CFIndex)1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData(compressedJPEGData, kUTTypeJPEG, 1, NULL);
    
    CGImageDestinationAddImage(imageDestination, sourceImage, options);
    
    bool success = CGImageDestinationFinalize(imageDestination);
    
    if (!success) {
        /* convert to RGB. try again. */
        sourceImage = CreateImageByScaleTo(sourceImage, CGImageGetWidth(sourceImage), CGImageGetHeight(sourceImage)); 
        CGImageDestinationAddImage(imageDestination, sourceImage, options);
        success = CGImageDestinationFinalize(imageDestination);
        CGImageRelease(sourceImage);
    }
    
    CFRelease(ratio);
    CFRelease(options);
    CFRelease(imageDestination);

    CGImageRef cgImage = NULL;
    if (success) {
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(compressedJPEGData);
        cgImage = CGImageCreateWithJPEGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease(provider);
    }
    CFRelease(compressedJPEGData);    
    return cgImage;
}
