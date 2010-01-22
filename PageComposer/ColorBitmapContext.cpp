// LFSimpleGraphics
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#include "LFSimpleGraphics.h"

using namespace LFSimpleGraphics;

ColorBitmapContext::ColorBitmapContext(size_t width, size_t height)
	: m_imageContext(NULL)
{
	size_t dataSize = (width * 4) * height;

	CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	m_data = (unsigned char*)calloc(1, dataSize);
	if (m_data)
		m_imageContext = CGBitmapContextCreate (m_data, width, height, 8, width * 4, rgb, kCGImageAlphaPremultipliedLast);
	CFRelease(rgb);
}

ColorBitmapContext::~ColorBitmapContext()
{
	if (m_imageContext)
		CFRelease(m_imageContext);
	if (m_data)
		free(m_data);
}

CGContextRef ColorBitmapContext::context()
{
	return m_imageContext;
}

CFDataRef ColorBitmapContext::createPNGData()
{
	return createData(CFSTR("public.png"), NULL);
}

CFDataRef ColorBitmapContext::createJPEGData(CGFloat compressionRatio)
{
	CFNumberRef ratio = CFNumberCreate(NULL, kCFNumberCGFloatType, &compressionRatio);
	CFStringRef keys[1] = { kCGImageDestinationLossyCompressionQuality };
	CFNumberRef values[1] = { ratio };
	CFDictionaryRef dictRef = CFDictionaryCreate(NULL, (const void**)keys, (const void**)values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFRelease(ratio);
	CFDataRef dataRef = createData(CFSTR("public.jpeg"), dictRef);
	CFRelease(dictRef);
	return dataRef;
}

CGImageRef ColorBitmapContext::createImage()
{
	return CGBitmapContextCreateImage(m_imageContext);
}

CFDataRef ColorBitmapContext::createData(CFStringRef type, CFDictionaryRef imageProperties)
{
	if (!m_imageContext)
		return NULL;

	CGImageRef imageRef = CGBitmapContextCreateImage(m_imageContext);
	if (!imageRef)
		return NULL;

	CFMutableDataRef dataRef = CFDataCreateMutable(NULL, 0);
	if (!dataRef) {
		CFRelease(imageRef);
		return NULL;
	}

	CGImageDestinationRef destRef = CGImageDestinationCreateWithData(dataRef, type, 1, NULL);
	if (!destRef) {
		CFRelease(dataRef);
		CFRelease(imageRef);
		return NULL;
	}

	CGImageDestinationAddImage(destRef, imageRef, imageProperties);
	CGImageDestinationFinalize(destRef);
	CFRelease(destRef);
	CFRelease(imageRef);
	return dataRef;
}
