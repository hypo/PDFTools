// LFSimpleGraphics
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#include "LFSimpleGraphics.h"

using namespace LFSimpleGraphics;

ContextGraphics::ContextGraphics(CGContextRef context)
    : m_context(context)
{
    CFRetain(m_context);
}

ContextGraphics::ContextGraphics(const ContextGraphics& cg)
    : m_context(cg.m_context)
{
    CFRetain(m_context);
}

ContextGraphics::~ContextGraphics()
{
    CFRelease(m_context);
}

ContextGraphics& ContextGraphics::operator=(const ContextGraphics& cg)
{
    CGContextRef tmp = m_context;
    m_context = cg.m_context;
    CFRetain(m_context);
    CFRelease(tmp);            
}

void ContextGraphics::saveState()
{
	CGContextSaveGState(m_context);
}

void ContextGraphics::restoreState()
{
	CGContextRestoreGState(m_context);
}

void ContextGraphics::drawImage(CGImageRef image, CGRect bound)
{
	CGContextDrawImage(m_context, bound, image);
}

void ContextGraphics::drawJPEGData(CFDataRef data, CGRect bound)
{
	CGImageRef image = ImageHelper::CreateImageFromJPEGData(data);
	if (image) {
		drawImage(image, bound);
		CFRelease(image);				
	}
}

void ContextGraphics::drawPNGData(CFDataRef data, CGRect bound)
{
	CGImageRef image = ImageHelper::CreateImageFromPNGData(data);
	if (image) {
		drawImage(image, bound);
		CFRelease(image);				
	}
}

void ContextGraphics::fillRect(CGColorRef color, CGRect rect)
{
    CGContextSetFillColorWithColor(m_context, color);
    CGContextFillRect(m_context, rect);
}

void ContextGraphics::strokeLine(CGColorRef color, CGPoint from, CGPoint to, CGFloat lineWidth)
{
    CGContextSetStrokeColorWithColor(m_context, color);
    CGContextSetLineWidth(m_context, lineWidth);
    CGPoint points[2];
    points[0] = from;
    points[1] = to;
    CGContextStrokeLineSegments(m_context, points, 2);
}

void ContextGraphics::offsetCurrentOrigin(CGFloat x, CGFloat y)
{
    CGAffineTransform transform;
    bzero(&transform, sizeof(transform));
    transform = CGAffineTransformTranslate(CGAffineTransformIdentity, x, y);            
    CGContextConcatCTM(m_context, transform);
}

void ContextGraphics::overlayPDFDataPageOneAtCurrentOrigin(CFDataRef data)
{
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    if (!provider)
        return;
    
    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(provider);
    if (!document) {
        CFRelease(provider);
        return;
    }
    
    if (!CGPDFDocumentGetNumberOfPages(document)) {
        CFRelease(document);
        CFRelease(provider);
        return;
    }
    
    CGPDFPageRef pageOne = CGPDFDocumentGetPage(document, 1);
    if (!pageOne) {
        CFRelease(document);
        CFRelease(provider);
        return;                
    }
    
    CGContextDrawPDFPage(m_context, pageOne);

    CFRelease(document);
    CFRelease(provider);
    return;            
}
