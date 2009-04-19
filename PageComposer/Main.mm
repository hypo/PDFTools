// [AUTO_HEADER]

#import <Cocoa/Cocoa.h>
#import <LFSimpleGraphics/LFSimpleGraphics.h>
#import <PageElements/PageElements.h>

#include <vector>
#include <string>
#include <fstream>
#include <iostream>

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
	[self setObject:@"GillSans" forKey:@"Typeface"];
	[self setObject:@"STHeiti" forKey:@"TypefaceCJK"];
	[self setObject:@"left" forKey:@"TextAlign"];
	[self setObject:@"top" forKey:@"TextVerticalAlign"];
	[self setObject:@"0.0" forKey:@"Rotation"];
	[self setObject:@"0.0" forKey:@"Kerning"];
	[self setObject:@"0.0" forKey:@"KerningCJK"];
    [self setObject:@"black" forKey:@"Color"];
    [self removeObjectForKey: @"LineHeight"];
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
            nil];
}
@end



CGImageRef CreateImageFromJPEGDataWithCompression(CFDataRef data, CGFloat ratio) {
    NSBitmapImageRep *originImage = [NSBitmapImageRep imageRepWithData: (NSData *)data];
    if (!originImage)
        return NULL;
    
    NSBitmapImageRep *canvasRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: NULL pixelsWide: [originImage pixelsWide] pixelsHigh: [originImage pixelsHigh] bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar: NO colorSpaceName: NSCalibratedRGBColorSpace bytesPerRow: 0 bitsPerPixel: 0];

    NSGraphicsContext *context = [NSGraphicsContext currentContext];    
    [NSGraphicsContext saveGraphicsState]; 
    [NSGraphicsContext setCurrentContext: [NSGraphicsContext graphicsContextWithBitmapImageRep: canvasRep]];
    [originImage drawInRect: NSMakeRect(0, 0, [originImage pixelsWide], [originImage pixelsHigh])];
    [NSGraphicsContext restoreGraphicsState];
    
    NSData *jpegImageData = [canvasRep representationUsingType: NSJPEGFileType properties: [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat: ratio] forKey: NSImageCompressionFactor]];
    [canvasRep release];
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef) jpegImageData);
    CGImageRef cgImage = CGImageCreateWithJPEGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);

    return cgImage;
}

bool CheckArgs(const string& cmd, const vector<string>& args, size_t count, size_t line)
{
	if (!args.size())
		return false;
	
	if (args[0] != cmd)
		return false;

	if (args.size() < count + 1) {
		NSLog(@"line %d: command '%s' expects %d arguments", line, cmd.c_str(), count);
		return false;
	}

	return true;
}

bool CheckArgsAndContext(const string& cmd, const vector<string>& args, size_t count, size_t line, CGContextRef context)
{
	if (!context) {
		NSLog(@"line %d: command '%s' requires graphics context", line, cmd.c_str());
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

void RunFile(istream& ist)
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
				NSLog(@"line %d: pdf context already begun", line);
			}
			else {
				pdf = new SinglePagePDF;
				CGRect bound = CGRectMake(0., 0., stof(args[1]), stof(args[2]));
				pdf->open(&bound);
				context = pdf->context();
				NSLog(@"line %d: pdf context begin with size %f x %f", line, stof(args[1]), stof(args[2]));
                needRedBorder = NO;
			}
		}
	    else if (CheckArgs("endpdf", args, 1, line)) {
			if (!context || !pdf) {
				NSLog(@"line %d: no pdf context", line);						
			}
			else {
				pdf->close();
				NSURL *url = [NSURL URLWithString:NSU8(args[1])];
				NSData *data = (NSData*)pdf->data();
				[data writeToURL:url atomically:YES];
				context = 0;
				delete pdf;
				pdf = 0;						
			}
		} else if (CheckArgs("endpng", args, 3, line)) {
            // endpng dpi scale url
         	if (!context || !pdf) {
				NSLog(@"line %d: no pdf context", line);
                continue;
			}
            CGFloat dpi = stof(args[1]);
            CGFloat scale = stof(args[2]);
            NSURL *url = [NSURL URLWithString: NSU8(args[3])];
            pdf->close();
            
            CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(pdf->data());
            CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithProvider(dataProvider);
            CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, 1);
            CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            NSUInteger pixelsWide = rect.size.width * (dpi / 72.0) * scale, pixelsHigh = rect.size.height * (dpi / 72.0) * scale;
            CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            CGContextRef canvas = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 4 * pixelsWide, rgb, kCGImageAlphaPremultipliedFirst);
            CGColorSpaceRelease(rgb);
            
            // Deprecated method. Use transform with CGContextDrawPDFPage(canvas, page);
            CGContextDrawPDFDocument(canvas, CGRectMake(0, 0, pixelsWide, pixelsHigh), pdfDocument, 1);            

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
        }
		else if (CheckArgsAndContext("simpleimage", args, 5, line, context)) {
			NSLog(@"begin to fetch: %s", args[1].c_str());
			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:NSU8(args[1])]];
			CGImageRef image = 0;
			if (data) {
				if (OVWildcard::Match(args[1], "*.png*"))
					image = ImageHelper::CreateImageFromPNGData((CFDataRef)data);
				else if (OVWildcard::Match(args[1], "*.jpg*") || OVWildcard::Match(args[1], "*.jpeg*"))
					image = ImageHelper::CreateImageFromJPEGData((CFDataRef)data);
				
				if (image) {
					ContextGraphics cg(context);
					cg.drawImage(image, CGRectMake(stof(args[2]), stof(args[3]), stof(args[4]), stof(args[5])));
					CFRelease(image);
				} else if (OVWildcard::Match(args[1], "*.pdf*")) {
                    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
                    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithProvider(dataProvider);

                    CGContextDrawPDFDocument(context, CGRectMake(stof(args[2]), stof(args[3]), stof(args[4]), stof(args[5])), pdfDocument, 1);
                    CGPDFDocumentRelease(pdfDocument);
                    CGDataProviderRelease(dataProvider);
                }
				else {
					NSLog(@"line %d: no image created from URL %s", line, args[1].c_str());
				}
			}
			else {
				NSLog(@"line %d: incorrect image URL: %s", line, args[1].c_str());
			}
		} 
        else if (CheckArgsAndContext("simpleimage_compress", args, 6, line, context)) {
            // url ratio x y w h
            NSLog(@"begin to fetch: %s", args[1].c_str());
			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:NSU8(args[1])]];

            if (!data) {
                NSLog(@"line %d: incorrect image URL: %s", line, args[1].c_str());
                continue;
            }
			CGImageRef image = NULL;
            if ((image = CreateImageFromJPEGDataWithCompression((CFDataRef)data, stof(args[2]))) == NULL) {
                NSLog(@"line %d: no image created from URL %s", line, args[1].c_str());
                continue;
            }
            ContextGraphics cg(context);
            cg.drawImage(image, CGRectMake(stof(args[3]), stof(args[4]), stof(args[5]), stof(args[6])));
            CFRelease(image);

        }
		else if (CheckArgsAndContext("set", args, 2, line, context)) {
			[settings setObject:NSU8(args[2]) forKey:NSU8(args[1])];
		}
		else if (CheckArgsAndContext("text", args, 5, line, context) || CheckArgsAndContext("text_checksize", args, 5, line, context)) {
			// args: text origX origY width height string
			
			NSDictionary *textDictionary = [settings textDictionaryWithText: NSU8(args[5])];
			
			PETextBlock *textBlock = [PETextBlock textBlockWithDictionary:textDictionary boundingRect:
				NSMakeRect(stof(args[1]), stof(args[2]), stof(args[3]), stof(args[4]))];

            NSRect actualBox = NSZeroRect;
            if (CheckArgsAndContext("text_checksize", args, 5, line, context)) {
                NSAttributedString *attrString = [textBlock attributedString];
                actualBox = [attrString boundingRectWithSize: NSMakeSize(stof(args[3]), stof(args[4])) options: NSStringDrawingUsesLineFragmentOrigin];

                if (actualBox.size.width > stof(args[3]) || actualBox.size.height > stof(args[4]))
                    needRedBorder = YES;
            }
			
			NSGraphicsContext *cocoagc = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
			[NSGraphicsContext saveGraphicsState];
			[NSGraphicsContext setCurrentContext:cocoagc];        
			[textBlock drawWithOutputControl:nil];
			[NSGraphicsContext restoreGraphicsState];
			
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
		else {
			NSLog(@"line %d: unknown command '%s'", line, args[0].c_str());
		}
	}
				
	if (pdf) {
		delete pdf;
	}
}

int main(int argc, char* argv[])
{
	id pool = [NSAutoreleasePool new];
//    NSApplicationLoad();
	if (argc < 2) {
		//ifstream fin("/tmp/test.pcd");
		//RunFile(fin);
		NSLog(@"using stdin");
		RunFile(cin);
	}
	else {		
		ifstream ifs;
		ifs.open(argv[1]);
		RunFile(ifs);
	}
	
	[pool drain];
}