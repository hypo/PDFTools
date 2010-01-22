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
}

CGImageRef ImageHelper::CreateImageFromPNGData(CFDataRef data)
{
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
	if (provider) {
		CGImageRef image = CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
		CFRelease(provider);
		return image;
	}			
}
