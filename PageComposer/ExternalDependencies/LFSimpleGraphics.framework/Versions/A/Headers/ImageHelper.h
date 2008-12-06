// LFSimpleGraphics
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#ifndef ImageHelper_h
#define ImageHelper_h

#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>

namespace LFSimpleGraphics {
    using namespace std;

    class ImageHelper {
	public:
		static CGImageRef CreateImageFromJPEGData(CFDataRef data);
		static CGImageRef CreateImageFromPNGData(CFDataRef data);
	};
};

#endif
