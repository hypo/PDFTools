// PEFont.m

#import "PEFont.h"
#import "NSExtensions.h"

@implementation PEFont : PEObject
+ (id)fontWithDictionary:(NSDictionary*)dictionary
{
    return [[[PEFont alloc] initWithDictionary:dictionary] autorelease];
}
- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [super init]) {
        NSDictionary *d = dictionary ? dictionary : [NSDictionary dictionary];

        // by default, PEFont uses Helvetica for Latin characters and
        // STHeiti for CJK characters
		NSString *fontFamily = [d objectForKey:@"family" defaultValue:@"GillSans"];
		NSString *fontFamilyLatin = [d objectForKey:@"family-latin" defaultValue:fontFamily];        
		NSString *fontFamilyCJK = [d objectForKey:@"family-cjk" defaultValue:@"STHeiti"];
//		NSString *fontFamilyCJK = [d objectForKey:@"family-cjk" defaultValue:@"LiHeiPro"];

		_size = [[d objectForKey:@"size" defaultValue:[NSNumber numberWithFloat:10.0]] floatValue];
		_CJKSize = [[d objectForKey:@"cjk-size" defaultValue:[NSNumber numberWithFloat:_size]] floatValue];

		_fontLatin = [[NSFont fontWithName:fontFamilyLatin size:_size] retain];
		_fontCJK = [[NSFont fontWithName:fontFamilyCJK size:_CJKSize] retain];
    
    }
    return self;
}
- (void)dealloc
{
    [_fontLatin release];
    [_fontCJK release];
    [super dealloc];
}
- (float)size 
{
	return _size;
}
- (float)CJKSize
{
	return _CJKSize;
}
- (NSFont*)font
{
    return _fontLatin;
}
- (NSFont*)fontLatin
{
    return _fontLatin;
}
- (NSFont*)fontCJK
{
    return _fontCJK;
}
- (float)defaultLineHeight
{
	NSLayoutManager *layout = [NSLayoutManager new];
	float fontLatinHeight = [layout defaultLineHeightForFont:_fontLatin];
	float fontCJKHeight = [layout defaultLineHeightForFont:_fontCJK];
	[layout release];
	
	return (fontLatinHeight > fontCJKHeight) ? fontLatinHeight : fontCJKHeight;
}

- (NSDictionary*)internalDictionaryRepresentation
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
        @"font", @"type",
        [_fontLatin fontName], @"family",
        [_fontLatin fontName], @"family-latin",
        [_fontCJK fontName], @"family-cjk",
        [NSNumber numberWithFloat:_size], @"size",
		[NSNumber numberWithFloat:_CJKSize], @"cjk-size", 
        nil];
    return [[super internalDictionaryRepresentation] dictionaryByMergingDictionary:result];
}

@end
