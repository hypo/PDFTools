// NSExtensionsUnitTests.m

#import "NSExtensionsTests.h"
#import "NSExtensions.h"

@implementation NSExtensionsTests
- (void)setUp
{
}

- (void)tearDown
{
}

- (void)testNSArray_useDefaultValue_unlessContains
{
    NSArray *array = [NSArray arrayWithObjects:@"abc", @"def", nil];
    STAssertEqualObjects([array useDefaultValue:@"hij" unlessContains:@"abc"], @"abc", @"when testing -useDefaultValue:unlessContains:");
    STAssertEqualObjects([array useDefaultValue:@"hij" unlessContains:@"123"], @"hij", @"when testing -useDefaultValue:unlessContains:");
    STAssertEqualObjects([array useDefaultValue:@"hij" unlessContains:@"def"], @"def", @"when testing -useDefaultValue:unlessContains:");
    STAssertEqualObjects([array useDefaultValue:@"hij" unlessContains:nil], @"hij", @"when testing -useDefaultValue:unlessContains:");
}
- (void)testNSArray_arrayByAddingObjectsFromArray
{
    NSArray *array1 = [NSArray arrayWithObjects:@"object1", nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"object2", nil];
    NSArray *array3 = [NSArray arrayWithObjects:@"object1", @"object2", nil];
    NSArray *array4 = [NSArray array];
    
    NSArray *array5 = [array1 arrayByAddingObjectsFromArray:nil]; 
    NSArray *array6 = [array1 arrayByAddingObjectsFromArray:array4];
    NSArray *array7 = [array1 arrayByAddingObjectsFromArray:array2];
    
    STAssertTrue([array5 isEqualToArray:array1], @"when merging array with nil");
    STAssertTrue([array6 isEqualToArray:array1], @"when merging array with an empty array");
    STAssertTrue([array7 isEqualToArray:array3], @"when merging array with another array");

    NSArray *array8 = [array4 arrayByAddingObjectsFromArray:array1];
    NSArray *array9 = nil;
    NSArray *array10 = [array9 arrayByAddingObjectsFromArray:array1];
    
    STAssertTrue([array8 isEqualToArray:array1], @"when merging an empty array with another array");
    STAssertEquals(array10, array9, @"when calling nil with -arrayByAddingObjectsFromArray: results in nil");
}
- (void)testNSDictionaryExtension_objectForKey_defaultValue
{
	NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"key1", nil];
	STAssertEquals([dict1 objectForKey:@"key1" defaultValue:@"value2"], @"value1", @"when calling -objectForKey: with existing key");
	STAssertEquals([dict1 objectForKey:@"key2" defaultValue:@"value2"], @"value2", @"when calling -objectForKey: with non-existent key");
}
    
- (void)testNSDictionaryExtension_dictionaryByMergingDictionary
{
	NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"key1", nil];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"value2", @"key2", nil];
    NSDictionary *dict3 = [NSDictionary dictionary];
    NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"key1", @"value2", @"key2", nil];
    
    NSDictionary *dict5 = [dict1 dictionaryByMergingDictionary:nil];
    NSDictionary *dict6 = [dict1 dictionaryByMergingDictionary:dict3];
    NSDictionary *dict7 = [dict3 dictionaryByMergingDictionary:dict1];
    NSDictionary *dict8 = [dict1 dictionaryByMergingDictionary:dict2];
    
    NSDictionary *dict9 = nil;
    NSDictionary *dict10 = [dict9 dictionaryByMergingDictionary:dict1];
    
    STAssertTrue([dict5 isEqualToDictionary:dict1], @"when merging dictionary with nil");
    STAssertTrue([dict6 isEqualToDictionary:dict1], @"when merging dictionary with an empty dictionary");
    STAssertTrue([dict7 isEqualToDictionary:dict1], @"when merging an empty dictionary with another dictionary");
    STAssertTrue([dict8 isEqualToDictionary:dict4], @"when merging two dictionaries with entries inside");
    STAssertEquals(dict10, dict9, @"Calling nil with -dictionaryByMergingDictionary: results in nil");

    NSDictionary *dict11 = [NSDictionary dictionaryWithObjectsAndKeys:dict1, @"dict1", dict2, @"dict2", nil];
    STAssertEquals([dict11 valueForKeyPath:@"dict1.key1" defaultValue:@"value3"], @"value1", @"when calling -valueForKeyPath:defaultValue: with existing key");
    STAssertEquals([dict11 valueForKeyPath:@"dict2.key2" defaultValue:@"value3"], @"value2", @"when calling -valueForKeyPath:defaultValue: with existing key");
    STAssertEquals([dict11 valueForKeyPath:@"dict1.key3" defaultValue:@"value3"], @"value3", @"when calling -valueForKeyPath:defaultValue: with non-existent key");
    STAssertEquals([dict11 valueForKeyPath:@"dict2.key3" defaultValue:@"value3"], @"value3", @"when calling -valueForKeyPath:defaultValue: with non-existent key");
    STAssertEquals([dict11 valueForKeyPath:@"dict3.key3" defaultValue:@"value3"], @"value3", @"when calling -valueForKeyPath:defaultValue: with non-existent key");
    STAssertEquals([dict11 valueForKeyPath:@"dict3.key3.value3" defaultValue:@"value4"], @"value4", @"when calling -valueForKeyPath:defaultValue: with non-existent key");
}
- (void)testNSDictionaryExtension_isKeyTrue
{
    NSDictionary *tval = [NSDictionary dictionaryWithObjectsAndKeys:
        @"true", @"a",
        @"TRUE", @"b",
        @"TrUe", @"c",
        @"yes", @"d",
        @"YES", @"e",
        @"Yes", @"f",
        @"1", @"g",
        @"-1", @"h",
        @"100", @"i",
        [NSNull null], @"j",
        @"false", @"k",
        @"FALSE", @"l",
        @"False", @"m",
        @"no", @"n",
        @"NO", @"o",
        @"No", @"p",
        [NSNumber numberWithInt:0], @"q",
        @"0", @"r",
        nil];
    
    STAssertTrue([tval isKeyTrue:@"a"], @"when testing -isKeyTrue:");
    STAssertTrue([tval isKeyTrue:@"b"], @"when testing -isKeyTrue:");
    STAssertTrue([tval isKeyTrue:@"c"], @"when testing -isKeyTrue:");
    STAssertTrue([tval isKeyTrue:@"d"], @"when testing -isKeyTrue:");
    STAssertTrue([tval isKeyTrue:@"e"], @"when testing -isKeyTrue:");
    STAssertTrue([tval isKeyTrue:@"f"], @"when testing -isKeyTrue:");
    STAssertTrue([tval isKeyTrue:@"g"], @"when testing -isKeyTrue:");
    STAssertTrue([tval isKeyTrue:@"h"], @"when testing -isKeyTrue:");
    STAssertTrue([tval isKeyTrue:@"i"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"j"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"k"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"l"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"m"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"n"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"o"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"p"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"q"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"r"], @"when testing -isKeyTrue:");
    STAssertFalse([tval isKeyTrue:@"non-existent"], @"when testing -isKeyTrue:");
}


@end
