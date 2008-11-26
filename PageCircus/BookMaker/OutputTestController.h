/* OutputTestController */

#import <Cocoa/Cocoa.h>
#import "PageElements.h"

@interface OutputTestController : NSWindowController <PEImageProvider>
{
    IBOutlet id textView;
    id _preparedBook;
    
    NSConditionLock *_lock;
    NSImage *_image;
    size_t _lastReceived;
    BOOL _reqEnded;
}
- (IBAction)runAction:(id)sender;
@end
