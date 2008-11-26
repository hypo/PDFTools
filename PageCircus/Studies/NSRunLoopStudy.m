// NSRunLoopStudies.h

#import <Cocoa/Cocoa.h>
#import "LFHTTPRequest.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
typedef unsigned int NSUInteger;
typedef int NSInteger;
#define NSUIntegerMax UINT_MAX
#endif

@interface RLStudyDelegate : NSObject
{
    BOOL _canEnd;
    size_t _lastReceived;
}
- (BOOL)canEnd;

- (void)httpRequestDidComplete:(LFHTTPRequest *)request;
- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error;
- (void)httpRequest:(LFHTTPRequest *)request receivedBytes:(NSUInteger)bytesReceived expectedTotal:(NSUInteger)total;
@end

@implementation RLStudyDelegate
- (id)init
{
    if (self = [super init]) {
        _canEnd = NO;
        _lastReceived = 0;
    }
    return self;
}
- (BOOL)canEnd
{
    return _canEnd;
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
    NSLog(@"did fetch data, length=%d bytes, written to /tmp/NSRunLoopStudy.output", [[request receivedData] length]);
    [[request receivedData] writeToFile:@"/tmp/NSRunLoopStudy.output" atomically:YES];
    _canEnd = YES;
}

- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
    if (error == LFHTTPRequestTimeoutError) {
        NSLog(@"time out!");
    } else {
        NSLog(@"Error! %@", error);
    }
    _canEnd = YES;        
}
- (void)httpRequest:(LFHTTPRequest *)request receivedBytes:(NSUInteger)bytesReceived expectedTotal:(NSUInteger)total
{
    double rB = (double)bytesReceived, lR = (double)_lastReceived;

    if ((int)total <=0 || (rB-lR)/(double)total > 0.1) {
        NSLog(@"Request in progress, received %u bytes, expected total %u bytes", bytesReceived, total);
        _lastReceived = bytesReceived;
    }
}
@end


int main() {
    NSApplicationLoad();
    id arp = [NSAutoreleasePool new];
    
    id testDlg = [[RLStudyDelegate alloc] init];
    LFHTTPRequest *req = [[LFHTTPRequest alloc] init];
    [req setDelegate: testDlg];
    [req setTimeoutInterval: 5.0];
    [req performMethod: LFHTTPRequestGETMethod onURL: [NSURL URLWithString: @"http://lukhnos.org/tmp/testcase.random"] withData: nil];
//    [req GET:@"http://lukhnos.org/tmp/testcase.random" userInfo:nil];
    
    double resolution = 1.0;
    BOOL endRunLoop = NO;
    BOOL isRunning;

    do {
        NSDate* next = [NSDate dateWithTimeIntervalSinceNow:resolution]; 
        isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:next];

    } while (isRunning && ![testDlg canEnd]);

    
    [arp release];
    return 0;
}
