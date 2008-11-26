#import <Cocoa/Cocoa.h>

@protocol DTStatusReporter <NSObject>
- (void)log:(NSString*)msg;
- (void)setStatusMessage:(NSString*)msg;
- (void)setProgress:(float)progress;
@end

