// LFSimpleGraphics
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#ifndef SinglePagePDF_h
#define SinglePagePDF_h

#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>

namespace LFSimpleGraphics {
    class SinglePagePDF {
    public:
		SinglePagePDF();
		~SinglePagePDF();
		bool open(CGRect *mediaBox = 0, CFDictionaryRef auxInfo = 0);
		void close();
		CFDataRef data();
		CGContextRef context();
        
    protected:
        bool m_closed;
        
        CGRect m_mediaBox;
        CGContextRef m_PDFContext;
        CGDataConsumerRef m_dataConsumer;
        CFMutableDataRef m_data;        
    };        
};

#endif
