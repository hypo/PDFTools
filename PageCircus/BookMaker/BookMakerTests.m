// PageElementsTests.h

#import <Cocoa/Cocoa.h>
#import "BookMakerTests.h"
#import "BookMaker.h"
#import "NSDictionary+BSJSONAdditions.h"

@implementation BookMakerTests : SenTestCase
- (void)setUp
{
}
- (void)tearDown
{
}
- (void)testBlah
{
	NSString *testfile = [[NSBundle bundleWithIdentifier:@"com.handlino.bookmaker.unittests"] pathForResource:@"BookMakerTests-TestCase01" ofType:@"js"];
    NSLog(testfile);
    // NSString *filename = [[[NSBundle bundleWithIdentifier:@"com.handlino.bookmaker.unittests"] resourcePath] stringByAppendingPathComponent:@"BookMakerTests-TestCase01.js"];
    // NSLog(filename);
    
    NSString *content = [NSString stringWithContentsOfFile:testfile encoding:NSUTF8StringEncoding error:nil];
    NSLog(content);
    
    NSDictionary *dict = [NSDictionary dictionaryWithJSONString:content];
    NSLog([dict description]);

    BMHypoPhotoBook12cmx12cm *hypo = [[BMHypoPhotoBook12cmx12cm alloc] initWithInstruction:dict];
    NSLog([hypo description]);
    
}
@end


