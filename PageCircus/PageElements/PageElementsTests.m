// PageElementsTests.h

#import <Cocoa/Cocoa.h>
#import "PageElementsTests.h"
#import "PageElements.h"

@implementation PageElementsTests : SenTestCase
- (void)testPEObject
{
    PEObject *peo = [[PEObject alloc] init];
    NSDictionary *dict = [peo dictionaryRepresentation];
    STAssertEqualObjects([dict objectForKey:@"type"], @"page-element", @"when testing the type of a PEObject instance");
    [peo release];
}
- (void)testPEFont
{
    PEFont *pef = [[PEFont alloc] initWithDictionary:nil];
    NSLog([pef description]);
    [pef release];
}
- (void)testNSColorExtension
{
    NSColor *black = [NSColor colorByName:@"black"];
    
    STAssertEquals([black cyanComponent], (float)0.0, @"when testing NSColorExtension");
    STAssertEquals([black magentaComponent], (float)0.0, @"when testing NSColorExtension");
    STAssertEquals([black yellowComponent], (float)0.0, @"when testing NSColorExtension");
    STAssertEquals([black blackComponent], (float)1.0, @"when testing NSColorExtension");
}
- (void)testNSDictionaryRectExtension
{
    NSRect r = NSMakeRect(1.1, 2.2, 3.3, 4.4);
    NSDictionary *dict = [NSDictionary dictionaryWithNSRect:r];
    STAssertEqualObjects([dict objectForKey:@"x"], [NSNumber numberWithFloat:1.1], @"when testing NSDictionaryRectExtension");
    STAssertEqualObjects([dict objectForKey:@"y"], [NSNumber numberWithFloat:2.2], @"when testing NSDictionaryRectExtension");
    STAssertEqualObjects([dict objectForKey:@"w"], [NSNumber numberWithFloat:3.3], @"when testing NSDictionaryRectExtension");
    STAssertEqualObjects([dict objectForKey:@"h"], [NSNumber numberWithFloat:4.4], @"when testing NSDictionaryRectExtension");
    
    NSRect dr = [dict NSRect];
    STAssertEquals(dr.origin.x, (float)1.1, @"when testing NSDictionaryRectExtension");
    STAssertEquals(dr.origin.y, (float)2.2, @"when testing NSDictionaryRectExtension");
    STAssertEquals(dr.size.width, (float)3.3, @"when testing NSDictionaryRectExtension");
    STAssertEquals(dr.size.height, (float)4.4, @"when testing NSDictionaryRectExtension");
    
    NSDictionary *zeros = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithFloat:5.5], @"x",
        @"not a number", @"y",
        [NSNull null], @"w",
        nil];
    NSRect zr = [zeros NSRect];
    STAssertEquals(zr.origin.x, (float)5.5, @"when testing NSDictionaryRectExtension");
    STAssertEquals(zr.origin.y, (float)0.0, @"when testing NSDictionaryRectExtension");
    STAssertEquals(zr.size.width, (float)0.0, @"when testing NSDictionaryRectExtension");
    STAssertEquals(zr.size.height, (float)0.0, @"when testing NSDictionaryRectExtension");    
}
- (void)testPEDrawableElement
{
    NSRect r=NSMakeRect(5.5, 6.6, 7.7, 8.8);
    PEDrawableElement *pede = [[PEDrawableElement alloc] initWithBoundingRect:r];
    STAssertEquals([pede boundingRect], r, @"when testing PEDrawableElement");    
    [pede release];
}
- (void)testPETextBlock
{
    NSRect r=NSMakeRect(10.0, 20.0, 300.0, 40.0);
    PETextBlock *petb = [[PETextBlock alloc] initWithDictionary:nil boundingRect:r];
    NSLog([petb description]);
    [petb release];
}
- (void)testPEImageBox
{
    NSRect r=NSMakeRect(30.0, 40.0, 500.0, 600.0);

    PEImageBox *peib = [[PEImageBox alloc] initWithDictionary:nil boundingRect:r];
    NSLog([peib description]);
    [peib release];
}
- (void)testPERectangle
{
    NSRect r=NSMakeRect(50.0, 60.0, 700.0, 800.0);
    PERectangle *per = [[PERectangle alloc] initWithDictionary:nil boundingRect:r];
    NSLog([per description]);
    [per release];
}
@end


