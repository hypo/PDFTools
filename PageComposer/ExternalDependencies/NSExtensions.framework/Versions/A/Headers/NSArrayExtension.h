// NSExtensions
//
// Copyright (c) 2006-2008 Lukhnos D. Liu
// Copyright (c) 2007-2008 Lithoglyph Inc.
// ALL RIGHTS RESERVED.
//

#import <Cocoa/Cocoa.h>

@interface NSArray(NSArrayExtension)
- (id)useDefaultValue:(id)defaultValue unlessContains:(id)anObject;
// redudant!
// - (NSArray*)arrayByMergingArray:(NSArray*)otherArray;
@end
