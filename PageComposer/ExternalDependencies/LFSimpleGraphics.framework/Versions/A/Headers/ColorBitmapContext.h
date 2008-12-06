// LFSimpleGraphics
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#ifndef ColorBitmapContext_h
#define ColorBitmapContext_h

#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>

namespace LFSimpleGraphics {
    using namespace std;

	class ColorBitmapContext {
	public:
		ColorBitmapContext(size_t width, size_t height);
		~ColorBitmapContext();
		CGContextRef context();
		CFDataRef createPNGData();
		CFDataRef createJPEGData(CGFloat compressionRatio);
		CGImageRef createImage();

	protected:
		CFDataRef createData(CFStringRef type, CFDictionaryRef imageProperties);

		CGContextRef m_imageContext;
		unsigned char* m_data;
	};
};

#endif