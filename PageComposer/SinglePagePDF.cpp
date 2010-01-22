// LFSimpleGraphics
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#include "LFSimpleGraphics.h"

using namespace LFSimpleGraphics;

SinglePagePDF::SinglePagePDF()
    : m_closed(false)
    , m_PDFContext(0)
    , m_dataConsumer(0)
{
    m_data = CFDataCreateMutable(NULL, 0);
    bzero(&m_mediaBox, sizeof(m_mediaBox));
}

SinglePagePDF::~SinglePagePDF()
{
    CFRelease(m_data);
}

bool SinglePagePDF::open(CGRect *mediaBox, CFDictionaryRef auxInfo)
{
    if (m_closed)
        return false;
        
    if (m_PDFContext)
        return false;
        
    m_dataConsumer = CGDataConsumerCreateWithCFData(m_data);            
    if (!m_dataConsumer)
        return false;
    
    m_PDFContext = CGPDFContextCreate(m_dataConsumer, mediaBox, auxInfo);
    if (!m_PDFContext) {
        CFRelease(m_dataConsumer);
        m_dataConsumer = 0;
        return false;
    }
    
    if (!mediaBox)
        m_mediaBox = CGRectMake(0., 0., 595., 841.);    // 210 x 297 mm (A4)
    else                
        m_mediaBox = *mediaBox;
        
    CGPDFContextBeginPage(m_PDFContext, 0);
    
    return true;
}

void SinglePagePDF::close()
{
    if (m_closed)
        return;
    
    m_closed = true;

    if (!m_PDFContext)
        return;
    
    CGPDFContextEndPage(m_PDFContext);
    CGPDFContextClose(m_PDFContext);
    CFRelease(m_PDFContext);
    CFRelease(m_dataConsumer);
    m_dataConsumer = 0;
    m_PDFContext = 0;
}

CFDataRef SinglePagePDF::data()
{
    return m_data;
}

CGContextRef SinglePagePDF::context()
{
    return m_PDFContext;
}
