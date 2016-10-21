// [AUTO_HEADER]

#import <Cocoa/Cocoa.h>
#import "LFSimpleGraphics.h"
#import "ZRCGUtilities.h"
#import "YLCTUtilities.h"
#import "NSBezierPath+Utility.h"
#import "YLLayoutManager.h"

#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <unistd.h>

#include "OVStringHelper.h"
#include "OVWildcard.h"

using namespace OpenVanilla;
using namespace LFSimpleGraphics;
using namespace std;

@interface NSMutableDictionary (PageComposerSettings)
- (void) setDefaultSettings;
- (NSDictionary *) textDictionaryWithText: (NSString *)text;
- (NSDictionary *) textDictionaryWithText: (NSString *)text fontDictionary: (NSDictionary *)fontDictionary;
@end

@implementation  NSMutableDictionary (PageComposerSettings)
- (void) setDefaultSettings
{
    [self setObject:@"16.0" forKey:@"FontSize"];
    [self setObject:@"16.0" forKey:@"FontSizeCJK"];
    [self setObject:@"Helvetica" forKey:@"Typeface"];
    [self setObject:@"HiraginoSansGB-W3" forKey:@"TypefaceCJK"];
    [self setObject:@"left" forKey:@"TextAlign"];
    [self setObject:@"top" forKey:@"TextVerticalAlign"];
    [self setObject:@"0.0" forKey:@"Rotation"];
    [self setObject:@"0.0" forKey:@"Kerning"];
    [self setObject:@"0.0" forKey:@"KerningCJK"];
    [self setObject:@"black" forKey:@"Color"];
    [self setObject:@"0.0" forKey:@"LineSpacing"];
    [self removeObjectForKey: @"LineHeight"];
    [self removeObjectForKey: @"Ligature"];
    [self removeObjectForKey: @"SymbolSubstitution"];
    [self removeObjectForKey: @"TypefaceSubstitution"];
    [self removeObjectForKey: @"FontSizeSubstitution"];
    [self removeObjectForKey: @"ContentRotation"];
    [self removeObjectForKey: @"BaselineOffset"];
    [self removeObjectForKey: @"BaselineOffsetCJK"];
}

- (NSDictionary *) textDictionaryWithText: (NSString *)text
{
    NSDictionary *fontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self objectForKey:@"FontSize"], @"size",
                                    [self objectForKey:@"FontSizeCJK"], @"cjk-size",
                                    [self objectForKey:@"Typeface"], @"family",
                                    [self objectForKey:@"TypefaceCJK"], @"family-cjk",
                                    nil];
    return [self textDictionaryWithText: text fontDictionary: fontDictionary];
}

- (NSDictionary *) textDictionaryWithText: (NSString *)text fontDictionary: (NSDictionary *)fontDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            text, @"text",
            fontDictionary, @"font",
            [self objectForKey:@"TextAlign"], @"align",
            [self objectForKey:@"TextVerticalAlign"], @"vertical-align",
            [self objectForKey:@"Rotation"], @"rotate",
            [self objectForKey:@"Kerning"], @"kerning",
            [self objectForKey:@"KerningCJK"], @"kerning-cjk",
            [self objectForKey:@"LineSpacing"], @"line-spacing",
            [self objectForKey:@"Color"], @"color",
            [self objectForKey:@"LineHeight"], @"force-lineheight",
			[self objectForKey:@"Ligature"], @"ligature",
            nil];
}
@end

bool CheckArgs(const string& cmd, const vector<string>& args, size_t count, size_t line)
{
    if (!args.size())
        return false;
    
    if (args[0] != cmd)
        return false;

    if (args.size() < count + 1) {
        NSLog(@"line %lu: command '%s' expects %lu arguments", line, cmd.c_str(), count);
        return false;
    }

    return true;
}

bool CheckArgsAndContext(const string& cmd, const vector<string>& args, size_t count, size_t line, CGContextRef context)
{
    if (!context) {
        NSLog(@"line %lu: command '%s' requires graphics context", line, cmd.c_str());
    }
    
    return CheckArgs(cmd, args, count, line);
}

float stof(const string& str)
{
    return atof(str.c_str());
}

NSString* NSU8(const string& str)
{
    return [NSString stringWithUTF8String:str.c_str()];
}

BOOL RunFile(istream& ist, NSString *overrideOutputPath)
{
    SinglePagePDF *pdf = 0;
    CGContextRef context = 0;
    BOOL needRedBorder = NO;

    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    
    [settings setDefaultSettings];    
    
    size_t line = 0;
    while (!ist.eof()) {
        string lineStr;
        getline(ist, lineStr);
        line++;

        if (!lineStr.length()) {
            continue;
        }
        
        vector<string> args = OVStringHelper::SplitBySpacesOrTabsWithDoubleQuoteSupport(lineStr);
        
        if (!args.size())
            continue;
            
        // ignore comments
        if (OVWildcard::Match(args[0], "#*"))
            continue;
        
        if (0) {
        }
        else if (CheckArgs("beginpdf", args, 2, line)) {
            if (context || pdf) {
                NSLog(@"line %lu: pdf context already begun", line);
            }
            else {
                pdf = new SinglePagePDF;
                CGRect bound = CGRectMake(0., 0., stof(args[1]), stof(args[2]));
                pdf->open(&bound);
                context = pdf->context();
                NSLog(@"line %lu: pdf context begin with size %f x %f", line, stof(args[1]), stof(args[2]));
                needRedBorder = NO;
            }
        }
        else if (CheckArgs("endpdf", args, 1, line)) {
            if (!context || !pdf) {
                NSLog(@"line %lu: no pdf context", line);                        
            }
            else {
                pdf->close();
                NSURL *url = overrideOutputPath ? [NSURL fileURLWithPath: overrideOutputPath]: [NSURL URLWithString:NSU8(args[1])];
                
                if ([url isFileURL]) {
                    NSURL *parentURL = [url URLByDeletingLastPathComponent];
                    NSFileManager *manager = [[NSFileManager alloc] init];
                    if ([manager respondsToSelector: @selector(createDirectoryAtURL:withIntermediateDirectories:attributes:error:)]) {
                        [manager createDirectoryAtURL: parentURL withIntermediateDirectories: YES attributes: nil error: NULL];
                    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        [manager createDirectoryAtPath: [parentURL path] withIntermediateDirectories: YES attributes: nil error: NULL];
#pragma clang diagnostic pop
                    }
                    [manager release];
                }
                NSData *data = (NSData*)pdf->data();
                [data writeToURL:url atomically:YES];
                NSLog(@"line %lu: write to file %@", line, overrideOutputPath);
                context = 0;
                delete pdf;
                pdf = 0;                        
            }
        } else if (CheckArgs("endpng", args, 3, line)) {
            // endpng dpi scale url
            if (!context || !pdf) {
                NSLog(@"line %lu: no pdf context", line);
                continue;
            }
            pdf->close();

            NSURL *url = overrideOutputPath ? [NSURL fileURLWithPath: overrideOutputPath] : [NSURL URLWithString: NSU8(args[3])];
            if ([url isFileURL]) {
                NSURL *parentURL = [url URLByDeletingLastPathComponent];
                NSFileManager *manager = [[NSFileManager alloc] init];
                if ([manager respondsToSelector: @selector(createDirectoryAtURL:withIntermediateDirectories:attributes:error:)]) {
                    [manager createDirectoryAtURL: parentURL withIntermediateDirectories: YES attributes: nil error: NULL];
                } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [manager createDirectoryAtPath: [parentURL path] withIntermediateDirectories: YES attributes: nil error: NULL];
#pragma clang diagnostic pop
                }
                [manager release];
            }

            
            NSUInteger pixelsWide = 0, pixelsHigh = 0;
            
            CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(pdf->data());
            CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithProvider(dataProvider);
            CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, 1);
            CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);

            if (args[1].rfind("px") != string::npos && args[2].rfind("px") != string::npos) {
                pixelsWide = stof(args[1].substr(0, args[1].length() - 2));
                pixelsHigh = stof(args[2].substr(0, args[2].length() - 2));
            } else {
                CGFloat dpi = stof(args[1]);
                CGFloat scale = stof(args[2]);
                pixelsWide = rect.size.width * (dpi / 72.0) * scale;
                pixelsHigh = rect.size.height * (dpi / 72.0) * scale;
            }

            CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            CGContextRef canvas = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 4 * pixelsWide, rgb, kCGImageAlphaPremultipliedFirst);
            CGColorSpaceRelease(rgb);
            
            CGContextSaveGState(canvas);
            CGContextTranslateCTM(canvas, 0, 0);
            CGContextScaleCTM(canvas, ((CGFloat)pixelsWide) / rect.size.width, ((CGFloat)pixelsHigh) / rect.size.height);
            CGContextDrawPDFPage(canvas, page);
            CGContextRestoreGState(canvas);

            if (needRedBorder) {
                CGColorRef redColor = CGColorCreateGenericRGB(1.0, 0, 0, 1);
                CGContextSetStrokeColorWithColor(canvas, redColor);
                CGContextStrokeRectWithWidth(canvas, CGRectMake(0, 0, pixelsWide, pixelsHigh), 2);
                CGColorRelease(redColor);
            }
            
            CGImageRef image = CGBitmapContextCreateImage(canvas);            
            CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)url, kUTTypePNG, 1, NULL);
            CGImageDestinationAddImage(dest, image, (CFDictionaryRef)[NSDictionary dictionary]);
            CGImageDestinationFinalize(dest);
            
            CFRelease(dest);
            CGImageRelease(image);
            CGContextRelease(canvas);
            CGPDFDocumentRelease(pdfDocument);
            CGDataProviderRelease(dataProvider);
            
            context = NULL;
            delete pdf;
            pdf = NULL;
        } else if (CheckArgs("endjpg", args, 3, line) || CheckArgs("endjpg", args, 4, line)) {
            if (!context || !pdf) {
                NSLog(@"line %lu: no pdf context", line);
                continue;
            }
            pdf->close();
            
            NSString *urlString = CheckArgs("endjpg", args, 4, line) ? NSU8(args[4]) : NSU8(args[3]);
            NSURL *url = overrideOutputPath ? [NSURL fileURLWithPath: overrideOutputPath] : [NSURL URLWithString: urlString];
            if ([url isFileURL]) {
                NSURL *parentURL = [url URLByDeletingLastPathComponent];
                NSFileManager *manager = [[NSFileManager alloc] init];
                [manager createDirectoryAtURL: parentURL withIntermediateDirectories: YES attributes: nil error: NULL];
                [manager release];
            }
            
            NSUInteger pixelsWide = 0, pixelsHigh = 0;
            CGFloat compressRatio = 1.0;
            
            CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(pdf->data());
            CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithProvider(dataProvider);
            CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, 1);
            CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            
            if (CheckArgs("endjpg", args, 4, line)) {
                if (args[1].rfind("px") == string::npos || args[2].rfind("px") == string::npos) {
                    NSLog(@"line %lu: dimension format incorrect. Should end with 'px'. e.g. 640px 800px", line);
                } else {
                    pixelsWide = stof(args[1].substr(0, args[1].length() - 2));
                    pixelsHigh = stof(args[2].substr(0, args[2].length() - 2));
                }
                compressRatio = stof(args[3]);
            } else {
                CGFloat dpi = stof(args[1]);
                compressRatio = stof(args[2]);
                pixelsWide = rect.size.width * (dpi / 72.0);
                pixelsHigh = rect.size.height * (dpi / 72.0);
            }
            
            
            CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            CGContextRef canvas = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 4 * pixelsWide, rgb, kCGImageAlphaPremultipliedFirst);
            CGColorSpaceRelease(rgb);
            
            CGContextSaveGState(canvas);
            CGContextTranslateCTM(canvas, 0, 0);
            CGContextScaleCTM(canvas, ((CGFloat)pixelsWide) / rect.size.width, ((CGFloat)pixelsHigh) / rect.size.height);
            CGContextDrawPDFPage(canvas, page);
            CGContextRestoreGState(canvas);
            
            if (needRedBorder) {
                CGColorRef redColor = CGColorCreateGenericRGB(1.0, 0, 0, 1);
                CGContextSetStrokeColorWithColor(canvas, redColor);
                CGContextStrokeRectWithWidth(canvas, CGRectMake(0, 0, pixelsWide, pixelsHigh), 2);
                CGColorRelease(redColor);
            }
            
            CGImageRef image = CGBitmapContextCreateImage(canvas);
            CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)url, kUTTypeJPEG, 1, NULL);
            CGImageDestinationAddImage(dest, image, (CFDictionaryRef)[NSDictionary dictionaryWithObject:@(compressRatio) forKey: (NSString *)kCGImageDestinationLossyCompressionQuality]);
            CGImageDestinationFinalize(dest);
            
            CFRelease(dest);
            CGImageRelease(image);
            CGContextRelease(canvas);
            CGPDFDocumentRelease(pdfDocument);
            CGDataProviderRelease(dataProvider);
            
            context = NULL;
            delete pdf;
            pdf = NULL;
        } else if (CheckArgsAndContext("simpleimage", args, 5, line, context) || CheckArgsAndContext("image", args, 9, line, context) ||
                 CheckArgsAndContext("simpleimage_compress", args, 6, line, context) || CheckArgsAndContext("image_compress", args, 10, line, context)) {
            
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            NSLog(@"begin to fetch: %s", args[1].c_str());
			BOOL needClip = CheckArgsAndContext("image", args, 9, line, context) || CheckArgsAndContext("image_compress", args, 10, line, context);
            BOOL needCompress = CheckArgsAndContext("simpleimage_compress", args, 6, line, context) || CheckArgsAndContext("image_compress", args, 10, line, context);
            
            CGFloat rotateDegree = 0;
            if ([[settings objectForKey: @"ContentRotation"] isEqualToString: @"clockwise"])
                rotateDegree = 270;
            else if ([[settings objectForKey: @"ContentRotation"] isEqualToString: @"counter-clockwise"])
                rotateDegree = 90;
            else if ([[settings objectForKey: @"ContentRotation"] isEqualToString: @"half"])
                rotateDegree = 180;
            [settings removeObjectForKey: @"ContentRotation"];
            
            BOOL needRotate = rotateDegree != 0;
            
            CGFloat compressRatio = needCompress ? stof(args[2]) : 1.0;
            
			float radius = [settings objectForKey:@"radius"] ? [[settings objectForKey:@"radius"] floatValue] : 0;
			[settings removeObjectForKey:@"radius"];
			
            float maxDPI = [settings objectForKey:@"MaxDPI"] ? [[settings objectForKey:@"MaxDPI"] floatValue] : 0;
			[settings removeObjectForKey:@"MaxDPI"];
            
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:NSU8(args[1])]];
            CGImageRef image = 0;
            
            int shift = needCompress ? 1 : 0;
            CGRect targetRect = needClip ? CGRectMake(stof(args[6 + shift]), stof(args[7 + shift]), stof(args[8 + shift]), stof(args[9 + shift])) : CGRectMake(stof(args[2 + shift]), stof(args[3 + shift]), stof(args[4 + shift]), stof(args[5 + shift]));
            
            if (data) {
                image = ImageHelper::CreateImageFromJPEGData((CFDataRef)data) ?: ImageHelper::CreateImageFromPNGData((CFDataRef)data) ?: ImageHelper::CreateImageFromData((CFDataRef)data);
                
                if (image) {
                    [data release];
                    ContextGraphics cg(context);
                    
                    CGImageRef sourceImage = image;
                    
                    if (needRotate) {                        
                        sourceImage = ImageHelper::CreateImageFromImageWithRotation(image, rotateDegree);
                        if (sourceImage) {
                            CFRelease(image);
                        } else {
                            NSLog(@"Cannot rotate image %@. Stop.", NSU8(args[1]));
                        }
                    }
                    
                    if (needClip) {
                        CGFloat crop_x, crop_y, crop_w, crop_h;
#define NORMALIZED_PIXEL(x, l)  ((x)[0] == 'x' || (x)[0] == 'X' || (x)[0] == '*') ? atof(x.c_str() + 1) * l : stof(x)
                        crop_x = NORMALIZED_PIXEL(args[2 + shift], CGImageGetWidth(sourceImage));
                        crop_y = NORMALIZED_PIXEL(args[3 + shift], CGImageGetHeight(sourceImage));
                        crop_w = NORMALIZED_PIXEL(args[4 + shift], CGImageGetWidth(sourceImage));
                        crop_h = NORMALIZED_PIXEL(args[5 + shift], CGImageGetHeight(sourceImage));
#undef NORMALIZED_PIXEL 
                        CGImageRef croppedImage = CGImageCreateWithImageInRect(sourceImage, CGRectMake(crop_x, crop_y, crop_w, crop_h));
                        CFRelease(sourceImage);
                        sourceImage = croppedImage;
                    }
                    if (maxDPI > 0) {
                        CGFloat suggestWidth = targetRect.size.width * maxDPI / 72.0;
                        CGFloat suggestHeight = targetRect.size.height * maxDPI / 72.0;
                        if (suggestWidth < CGImageGetWidth(sourceImage) || suggestHeight < CGImageGetHeight(sourceImage)) {
                            CGImageRef scaledDownImage = ImageHelper::CreateImageByScaleTo(sourceImage, MIN(suggestWidth, CGImageGetWidth(sourceImage)), MIN(suggestHeight, CGImageGetHeight(sourceImage)));
                            CFRelease(sourceImage);
                            sourceImage = scaledDownImage;
                        }
                    }
                    if (needCompress) {
                        CGImageRef compressedImage = ImageHelper::CreateImageFromImageWithCompression(sourceImage, compressRatio);
                        CFRelease(sourceImage);
                        sourceImage = compressedImage;
                    }
					
                    CGContextSaveGState(context);
                    CGFloat centerRotationDegree = 0;
                    if ([settings objectForKey: @"CenterRotation"]) {
                        centerRotationDegree = [[settings objectForKey: @"CenterRotation"] floatValue];
                    }
                    CGPoint center = CGPointMake(CGRectGetMidX(targetRect), CGRectGetMidY(targetRect));
                    CGContextTranslateCTM(context, center.x, center.y);
                    CGContextRotateCTM(context, centerRotationDegree * M_PI / 180.0);
                    CGContextTranslateCTM(context, -CGRectGetWidth(targetRect)/2.0, -CGRectGetHeight(targetRect)/2.0);
                    targetRect.origin = CGPointZero;
                    
					if (radius > 0) AddBorderRadiusPath(context, targetRect, radius);
                    
                    cg.drawImage(sourceImage, targetRect);
					CGContextRestoreGState(context);
                    CFRelease(sourceImage);
                } else if (OVWildcard::Match(args[1], "*.pdf*")) {
                    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
                    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithProvider(dataProvider);
                    CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, 1);
                    CGRect pdfSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
                    [data release];
                    
                    CGContextSaveGState(context);
                    
                    CGFloat x = stof(args[2]), y = stof(args[3]), w = stof(args[4]), h = stof(args[5]);
                    CGContextTranslateCTM(context, x, y);                    
                    CGContextScaleCTM(context, w / pdfSize.size.width, h / pdfSize.size.height);
                    
                    CGContextDrawPDFPage(context, page);
                    
                    CGContextRestoreGState(context);
                    CGPDFDocumentRelease(pdfDocument);
                    CGDataProviderRelease(dataProvider);
                }
                else {
                    NSLog(@"line %lu: no image created from URL %s", line, args[1].c_str());
                    NSGraphicsContext *cocoagc = [NSGraphicsContext graphicsContextWithGraphicsPort: context flipped: NO];
                    [NSGraphicsContext saveGraphicsState];
                    [NSGraphicsContext setCurrentContext: cocoagc];
                    [[NSColor redColor] set];
                    [NSBezierPath fillRect: NSRectFromCGRect(targetRect)];
                    [@"Image Format Error." drawInRect: NSRectFromCGRect(targetRect) withAttributes: nil];
                    [NSGraphicsContext restoreGraphicsState];
                }
            }
            else {
                NSLog(@"line %lu: incorrect image URL: %s", line, args[1].c_str());
                NSGraphicsContext *cocoagc = [NSGraphicsContext graphicsContextWithGraphicsPort: context flipped: NO];
                [NSGraphicsContext saveGraphicsState];
                [NSGraphicsContext setCurrentContext: cocoagc];
                
                [[NSColor redColor] set];
                [NSBezierPath fillRect: NSRectFromCGRect(targetRect)];

                [@"Fetch Image Error." drawInRect: NSRectFromCGRect(targetRect) withAttributes: nil];
                
                [NSGraphicsContext restoreGraphicsState];

            }
            [pool drain];
        } 
        else if (CheckArgsAndContext("set", args, 2, line, context)) {
            [settings setObject:NSU8(args[2]) forKey:NSU8(args[1])];
        }
        else if (CheckArgsAndContext("barcode", args, 5, line, context)) {
            // args: barcode x y w h string
            
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//            [dict setObject:NSU8(args[5]) forKey:@"text"];
//            NSRect rect = NSMakeRect(stof(args[1]), stof(args[2]), stof(args[3]), stof(args[4]));
//            NSLog(@"rect(x=%f, y=%f, w=%f, h=%f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
//            PEBarcodeCode39 *barcode = [PEBarcodeCode39 barcodeWithDictionary:dict boundingRect:rect];
//
//            NSGraphicsContext *cocoagc = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
//            [NSGraphicsContext saveGraphicsState];
//            [NSGraphicsContext setCurrentContext:cocoagc];        
//            [barcode drawWithOutputControl:nil];
//            [NSGraphicsContext restoreGraphicsState];
//            
//            [dict release];
        }
        else if (CheckArgsAndContext("text", args, 5, line, context) || CheckArgsAndContext("text_checksize", args, 5, line, context) || CheckArgsAndContext("vtext", args, 5, line, context) || CheckArgsAndContext("vtext_checksize", args, 5, line, context)) {
            [NSBezierPath setDefaultLineJoinStyle: NSRoundLineJoinStyle];
            [NSBezierPath setDefaultLineCapStyle: NSRoundLineCapStyle];
            
            NSAttributedString *attributedText = attributedStringWithOptions(NSU8(args[5]), settings);
            CGRect targetRect = CGRectMake(stof(args[1]), stof(args[2]), stof(args[3]), stof(args[4]));
            
            BOOL vertical = CheckArgsAndContext("vtext", args, 5, line, context) || CheckArgsAndContext("vtext_checksize", args, 5, line, context);
            BOOL checkSize = CheckArgsAndContext("text_checksize", args, 5, line, context) || CheckArgsAndContext("vtext_checksize", args, 5, line, context);
            
            BOOL clockwiseRotation = [[settings objectForKey: @"ContentRotation"] isEqualToString: @"clockwise"];
            [settings removeObjectForKey: @"ContentRotation"];

            NSSize boundingSize = (clockwiseRotation || vertical) ? NSMakeSize(stof(args[4]), stof(args[3])) : NSMakeSize(stof(args[3]), stof(args[4]));

            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString: attributedText];
            YLLayoutManager *layoutManager = [[YLLayoutManager alloc] init];
            YLTextContainer *textContainer = [[YLTextContainer alloc] initWithContainerSize: NSMakeSize(boundingSize.width, CGFLOAT_MAX)];
            textContainer.verticalText = vertical;
            textContainer.lineFragmentPadding = 0.0;

            layoutManager.usesScreenFonts = NO;
            layoutManager.usesFontLeading = NO;
            [layoutManager addTextContainer: textContainer];
            [textContainer release];
            [textStorage addLayoutManager:layoutManager];
            [layoutManager release];
            [textStorage autorelease];
            
            CGContextSaveGState(context);
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            NSGraphicsContext *cocoagc = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped: YES];
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:cocoagc];
            NSAffineTransform *xfrm = [NSAffineTransform transform];
            [xfrm scaleXBy: 1 yBy: -1];
            [xfrm translateXBy: CGRectGetMidX(targetRect) yBy: -CGRectGetMidY(targetRect)];
            CGFloat centerRotationDegree = 0;
            if ([settings objectForKey: @"CenterRotation"]) {
                centerRotationDegree = [[settings objectForKey: @"CenterRotation"] floatValue];
            }
            [xfrm rotateByDegrees: -centerRotationDegree];
            [xfrm translateXBy: -CGRectGetWidth(targetRect) / 2.0 yBy: -CGRectGetHeight(targetRect) / 2.0];
            
            if (clockwiseRotation || vertical) {
                [xfrm rotateByDegrees: 90];
                [xfrm translateXBy: 0 yBy: -boundingSize.height];
            }
            
            [xfrm concat];
            
            NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];

            NSRect actualRect = [layoutManager boundingRectForGlyphRange: glyphRange inTextContainer: textContainer];
            if (vertical && [attributedText length] > 0) {
                NSAttributedString *measure = [attributedText attributedSubstringFromRange: NSMakeRange(0, 1)];
                NSRect measureSize = [measure boundingRectWithSize: boundingSize options: NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingDisableScreenFontSubstitution];
                CGFloat lineHeight = [layoutManager boundingRectForGlyphRange: NSMakeRange(0, 1) inTextContainer: textContainer].size.height;
                
                if (isCJK([[measure string] characterAtIndex: 0])) {
                    actualRect.size.height -= MAX(0, (lineHeight - measureSize.size.width));
                } else {
                    actualRect.size.height -= MAX(0, (lineHeight - measureSize.size.height));
                }
            }
            
            NSRange lastLineRange = NSMakeRange(0, [attributedText length]);
            if (glyphRange.length > 0) {
                [layoutManager lineFragmentRectForGlyphAtIndex: (glyphRange.length - 1) effectiveRange: &lastLineRange];
                NSUInteger firstCharacterIndexOfLastLine = [layoutManager characterIndexForGlyphAtIndex: lastLineRange.location];
                lastLineRange.location = firstCharacterIndexOfLastLine;
                lastLineRange.length = [attributedText length] - firstCharacterIndexOfLastLine;
            }
            
            __block CGFloat minDescender = 0; // It's negative value
            [[attributedText attributedSubstringFromRange: lastLineRange] enumerateAttributesInRange: NSMakeRange(0, lastLineRange.length) options: 0UL usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
                NSFont *font = [attributes objectForKey: NSFontAttributeName];
                CGFloat baselineOffset = [[attributes objectForKey: NSBaselineOffsetAttributeName] doubleValue];
                CGFloat baselineShift = [font descender] - baselineOffset;
                if (baselineShift < minDescender) minDescender = baselineShift;
                NSLog(@"%lf", baselineShift);
            }];
            NSLog(@"%@ %lf", [attributedText string], minDescender);

            NSString *verticalAlignment = [settings objectForKey: @"TextVerticalAlign"] ?: @"top";
            CGFloat deltaY = 0;
            if  ([verticalAlignment isEqualToString: @"center"] || [verticalAlignment isEqualToString: @"middle"]) {
                deltaY = (boundingSize.height - actualRect.size.height) / 2;
            } else if ([verticalAlignment isEqualToString: @"bottom"]) {
                deltaY = (boundingSize.height - actualRect.size.height);
            } else if ([verticalAlignment hasPrefix: @"bottom-baseline:"] ) {
                CGFloat baselinePoint = [[verticalAlignment substringFromIndex: [@"bottom-baseline:" length]] doubleValue];
                deltaY = boundingSize.height - baselinePoint - actualRect.size.height - minDescender;
            }
            
            NSColor *fillColor = [attributedText attribute: NSForegroundColorAttributeName atIndex: 0 longestEffectiveRange: NULL inRange: NSMakeRange(0, attributedText.length)];
            NSColor *strokeColor = [NSColor colorByName: [settings objectForKey: @"StrokeColor"]];
            CGFloat bgStrokeWidth = [([settings objectForKey: @"BackgroundStrokeWidth"] ?: @0) doubleValue];
            CGFloat fgStrokeWidth = [([settings objectForKey: @"StrokeWidth"] ?: @0) doubleValue];
            
            if ([settings objectForKey: @"TextPath"]) {
                NSAffineTransform *xfrm = [NSAffineTransform transform];
                [xfrm scaleXBy: 1 yBy: -1];
                [xfrm translateXBy: -CGRectGetMinX(targetRect) yBy: -CGRectGetMaxY(targetRect)];
                [xfrm concat];
                NSBezierPath *path = [NSBezierPath bezierPathFromString: [settings objectForKey: @"TextPath"]];
                NSBezierPath *textPath = [path bezierPathWithTextOnPath: attributedText yOffset: 0];
                
                if ([settings objectForKey: @"BackgroundStrokeWidth"]) {
                    [textPath setLineWidth: bgStrokeWidth];
                    [strokeColor setStroke];
                    [textPath stroke];
                }
                [fillColor setFill];
                [textPath fill];
                
                if ([settings objectForKey: @"BackgroundStrokeWidth"]) {
                    [textPath setLineWidth: fgStrokeWidth];
                    [strokeColor setStroke];
                    [textPath stroke];
                }
            } else {
                [layoutManager drawGlyphsForGlyphRange: glyphRange atPoint: NSMakePoint(0, deltaY)];
                
                // handle stroke
                if ([settings objectForKey: @"BackgroundStrokeWidth"] ||
                    [settings objectForKey: @"StrokeWidth"])
                {
                    [strokeColor setStroke];
                    
                    if (bgStrokeWidth != 0 && strokeColor) {
                        for (NSBezierPath *p in layoutManager.textPath) {
                            for (CGFloat thickness = bgStrokeWidth; thickness >= 0.0; thickness -= 0.5) {
                                [p setLineWidth: thickness];
                                [p stroke];
                            }
                        }
                    }
                    [fillColor setFill];
                    for (NSBezierPath *p in layoutManager.textPath) [p fill];
                    
                    if (fgStrokeWidth != 0 && strokeColor) {
                        for (NSBezierPath *p in layoutManager.textPath) {
                            for (CGFloat thickness = fgStrokeWidth; thickness >= 0.0; thickness -= 0.5) {
                                [p setLineWidth: thickness];
                                [p stroke];
                            }
                        }
                    }
                }
            }
            
            if (checkSize) {
                CGFloat w = actualRect.size.width;
                if (-5 <= actualRect.origin.x && actualRect.origin.x < 0) w += actualRect.origin.x;
                if (w > boundingSize.width || actualRect.size.height > boundingSize.height)
				{
					NSLog(@"oversize detected, actualBox=%@", NSStringFromRect(actualRect));
                    needRedBorder = YES;
				}
            }
            
            [NSGraphicsContext restoreGraphicsState];
            CGContextRestoreGState(context);
            // Reset settings
            [settings setDefaultSettings];
        } 
        else if (CheckArgsAndContext("simpletext", args, 3, line, context)) {
            NSGraphicsContext *cocoagc = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:cocoagc];
            
            NSString *text = NSU8(args[3]);
            [text drawAtPoint:NSMakePoint(stof(args[1]), stof(args[2])) withAttributes:nil];
            
            [NSGraphicsContext restoreGraphicsState];        
        }
        else if (CheckArgsAndContext("simplecolor", args, 5, line, context)) {
            CGContextSaveGState(context);
            NSGraphicsContext *cocoagc = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
            CGRect targetRect = CGRectMake(stof(args[2]), stof(args[3]), stof(args[4]), stof(args[5]));
            
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:cocoagc];

            NSAffineTransform *xfrm = [NSAffineTransform transform];
            [xfrm translateXBy: CGRectGetMidX(targetRect) yBy: CGRectGetMidY(targetRect)];
            CGFloat centerRotationDegree = 0;
            if ([settings objectForKey: @"CenterRotation"]) {
                centerRotationDegree = [[settings objectForKey: @"CenterRotation"] floatValue];
                [settings removeObjectForKey: @"CenterRotation"];
            }
            [xfrm rotateByDegrees: centerRotationDegree];
            [xfrm translateXBy: -CGRectGetWidth(targetRect) / 2.0 yBy: -CGRectGetHeight(targetRect) / 2.0];
            [xfrm concat];
            
            targetRect.origin = CGPointZero;
            
            NSColor *color = [NSColor colorByName: NSU8(args[1])];
            [color set];
            [NSBezierPath fillRect: NSMakeRect(targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height)];
            
            [NSGraphicsContext restoreGraphicsState];
            CGContextRestoreGState(context);
        }
        else {
            NSLog(@"line %lu: unknown command '%s'", line, args[0].c_str());
        }
    }
                
    if (pdf) {
        delete pdf;
    }
	return needRedBorder;
}

int main(int argc, char* argv[])
{
    id pool = [NSAutoreleasePool new];
	BOOL textOversized = NO;
    
    NSString *overrideFilePath = nil;

    int ch;
    while ((ch = getopt(argc, argv, "o:")) != -1) {
        switch (ch) {
        case 'o':
            overrideFilePath = [NSString stringWithUTF8String: optarg];
            break;
        default:
            break;
        }
    }
    if (optind >= argc) {
        NSLog(@"using stdin");
        textOversized = RunFile(cin, overrideFilePath);
    }
    else {        
        ifstream ifs;
        ifs.open(argv[optind]);
        if (ifs.good()) {
            textOversized = RunFile(ifs, overrideFilePath);
        } else {
            NSLog(@"Cannot open file: %s", argv[optind]);
        }
    }
    
    [pool drain];
	return textOversized ? 1 : 0;
}
