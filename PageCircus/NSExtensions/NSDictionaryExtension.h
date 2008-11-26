// NSDictionaryExtension.h

#import <Cocoa/Cocoa.h>

@interface NSDictionary(NSDictionaryExtension) 
- (id)objectForKey:(NSString*)key defaultValue:(id)defaultValue;
- (id)valueForKeyPath:(NSString*)keyPath defaultValue:(id)defaultValue;
- (NSDictionary*)dictionaryByMergingDictionary:(NSDictionary*)otherDict;
- (BOOL)isKeyTrue:(id)aKey;
@end
