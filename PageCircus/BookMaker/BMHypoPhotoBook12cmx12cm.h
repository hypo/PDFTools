// BMHypoPhotoBook12cmx12cm.h

#import <Cocoa/Cocoa.h>

// NOTE: Page number starts at 1

@interface BMHypoPhotoBook12cmx12cm : NSObject
{
    NSDictionary *_instruction;
    NSDictionary *_outputControl;
    NSDictionary *_preparedPages;
    unsigned int _numberOfPages;
}
- (id)initWithInstruction:(NSDictionary*)instruction;
- (void)dealloc;
- (NSDictionary*)outputControl;
- (NSString*)description;
- (NSArray*)allPageLabels;
- (void)prepareElementsOnPageLabelled:(NSString*)label outputControl:(NSDictionary*)control;
- (void)drawElementsOnPageLabelled:(NSString*)label outputControl:(NSDictionary*)control;
- (NSRect)boundingRectOfPageLabelled:(NSString*)label;
- (NSString*)labelOfPageNumbered:(unsigned int)pageNumber;
// - (NSArray*)fetchPageWithLabel:(NSString*)label;
// - (NSArray*)fetchPageWithNumber:(unsigned int)pageNumber;
// - (NSArray*)fetchPagesFrom:(unsigned int)fromPage to:(unsigned int)toPage;
// - (NSRect)boundingRectOfPageWithLabel:(NSString*)label;
// - (NSRect)boundingRectOfPageWithNumber:(unsigned int)pageNumber;

// numberOfLightboxPreviewPages
// boundingRectOfLightboxPreviewPage
// drawElementsOnLightboxPreviewPageNumbered
@end

// print the book as PDF
// print the book as PDF -- preview mode
// print the book as PDF -- preview thumbnail mode (e.g. 10 thumbnails/page)
// print the book as JPEG -- single page previe wmode
// print the book as JPEG -- single 
