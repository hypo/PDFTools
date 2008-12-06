// NSExtensions
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#import <Cocoa/Cocoa.h>

@interface NSDictionary(NSDictionaryExtension) 
- (id)objectForKey:(NSString*)key defaultValue:(id)defaultValue;
- (id)valueForKeyPath:(NSString*)keyPath defaultValue:(id)defaultValue;
- (NSDictionary*)dictionaryByMergingDictionary:(NSDictionary*)otherDict;
- (BOOL)isKeyTrue:(id)aKey;
@end
