// PagePreviewer.h

#import <Cocoa/Cocoa.h>
#import "BookMaker.h"
#import "DrawingTools.h"
#import "PageElements.h"
#import "NSDictionary+BSJSONAdditions.h"
#import "NSExtensions.h"

@interface PagePreviewer : NSObject <PEImageProvider>
{
	NSMutableString *_currentURLString;
	size_t _lastReceived;
    BOOL _reqEnded;
	NSImage *_image;
	NSData *_imageData;
    BMHypoPhotoBook12cmx12cm *_preparedBook;
    
	NSConditionLock *_lock;
	NSDictionary *_sourceContent;
	NSString *_pageLabel;
    float _resolution;
	NSString *_outputFile;	
	BOOL _isRunning;
	int _errorCode;
	
	NSData *_matchReplaceImageData;
	NSData *_replacementImageData;
}
- (id)initWithSourceFile:(NSString*)source pageLabel:(NSString*)label resolution:(NSString*)resolution outputFile:(NSString*)output;
- (void)run;
- (int)errorCode;

- (void)setMatchReplaceImageData:(NSData*)data;
- (void)setReplacementImageData:(NSData*)data;
@end
