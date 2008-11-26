// NSDictionaryExtension.m

#import "NSDictionaryExtension.h"

@implementation NSDictionary (NSDictionaryExtension) 
- (id)objectForKey:(NSString*)key defaultValue:(id)defaultValue
{
	if (!key) return defaultValue;
	id v=[self objectForKey:key];
    return v ? v : defaultValue;
}
- (id)valueForKeyPath:(NSString*)keyPath defaultValue:(id)defaultValue
{
    if (!keyPath) return defaultValue;
    id v=[self valueForKeyPath:keyPath];
    return v ? v : defaultValue;
}
- (NSDictionary*)dictionaryByMergingDictionary:(NSDictionary*)otherDict
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:self];
    if (otherDict) [result addEntriesFromDictionary:otherDict];
    return [NSDictionary dictionaryWithDictionary:result];
}
- (BOOL)isKeyTrue:(id)aKey
{
	id v = [self objectForKey:aKey];
	if (!v) return NO;
	
	if ([v isKindOfClass:[NSString class]]) {
		if ([[v lowercaseString] isEqualToString:@"yes"]) return YES;
		if ([[v lowercaseString] isEqualToString:@"true"]) return YES;
        if ([v intValue] !=0) return YES;
	}
	
	if ([v isKindOfClass:[NSNumber class]]) {
		if ([v intValue] > 0) return YES;
	}
	
	return NO;
}
@end
