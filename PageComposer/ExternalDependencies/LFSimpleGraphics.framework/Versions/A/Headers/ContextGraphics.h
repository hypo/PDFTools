// LFSimpleGraphics
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#ifndef ContextGraphics_h
#define ContextGraphics_h

#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include "ImageHelper.h"

namespace LFSimpleGraphics {
    class ContextGraphics {
    public:
		ContextGraphics(CGContextRef context);
		ContextGraphics(const ContextGraphics& cg);
		~ContextGraphics();
		
		ContextGraphics& operator=(const ContextGraphics& cg);
		
		void saveState();
		void restoreState();
		void drawImage(CGImageRef image, CGRect bound);
		void drawJPEGData(CFDataRef data, CGRect bound);
		void drawPNGData(CFDataRef data, CGRect bound);
		void fillRect(CGColorRef color, CGRect rect);
		void strokeLine(CGColorRef color, CGPoint from, CGPoint to, CGFloat lineWidth = 1.0);
		void offsetCurrentOrigin(CGFloat x, CGFloat y);
		void overlayPDFDataPageOneAtCurrentOrigin(CFDataRef data);
        
    protected:
        CGContextRef m_context;
    };    
};

#endif