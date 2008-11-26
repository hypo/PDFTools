// DTImageBox.m

#import "DTImageBox.h"
#import "DTUtilities.h"
#import "NSDictionaryExtension.h"

@implementation DTImageBox
- (DTImageBox*)initWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect quality:(NSString*)quality imageProvider:(id<DTImageProvider>)provider
{
	if (self = [super init]) {
		_boundingRect = boundingRect;
		_quality = [[NSString alloc] initWithString:quality];
		_provider = [provider retain];
		
		NSMutableDictionary *d = [NSMutableDictionary dictionary];

		// alas, only if we had "map" function...		
		NSDictionary *source = [dict objectForKey:@"source" defaultValue:[NSDictionary dictionary]];
		NSArray *sourceKeys = [source allKeys];
		unsigned i, c = [sourceKeys count];
		for (i = 0; i < c; i++) {
			NSString *k = [sourceKeys objectAtIndex:i];
			[d setObject:DTStringToURL([source objectForKey:k]) forKey:k];
		}
		
		NSDictionary *crop = [dict objectForKey:@"crop" defaultValue:[NSDictionary dictionary]];
		
		#define FV(dd, kk, ff) [[dd objectForKey:kk defaultValue:[NSNumber numberWithFloat:ff]] floatValue]
		_cropX = FV(crop, @"x", 0.0);
		_cropY = FV(crop, @"y", 0.0);
		_cropW = FV(crop, @"w", 1.0);
		_cropH = FV(crop, @"h", 1.0);
		#undef FV
		
		_bleed = DTIsKeyTrue(dict, @"bleed");
		
		_source = [d retain];
	}
	return self;
}
+ (DTImageBox*)imageBoxWithDictionary:(NSDictionary*)dict boundingRect:(NSRect)boundingRect quality:(NSString*)quality imageProvider:(id<DTImageProvider>)provider
{
	return [[[DTImageBox alloc] initWithDictionary:dict boundingRect:boundingRect quality:quality imageProvider:provider] autorelease];
}
- (void)dealloc
{
	[_quality release];
	[_provider release];
	[_source release];
	[super dealloc];
}
+ (NSURL*)URLFromSource:(NSDictionary*)dict quality:(NSString*)quality
{
	// fba = fallback array
	NSArray *ofba = [NSArray arrayWithObjects:@"original", @"large", @"medium", @"small", @"thumbnail", nil];
	NSArray *lfba = [NSArray arrayWithObjects:@"large", @"medium", @"small", @"thumbnail", nil];
	NSArray *mfba = [NSArray arrayWithObjects:@"medium", @"small", @"thumbnail", nil];
	NSArray *sfba = [NSArray arrayWithObjects:@"small", @"thumbnail", nil];
	NSArray *tfba = [NSArray arrayWithObjects:@"thumbnail", nil];
	NSDictionary *fbd = [NSDictionary dictionaryWithObjectsAndKeys:
		ofba, @"original",
		lfba, @"large",
		mfba, @"medium",
		sfba, @"small",
		tfba, @"thumbnail", nil];
	
	NSLog(@"quality = %@, source dict  = @", quality, [dict description]);
	NSArray *fba = [fbd objectForKey:quality];
	if (!fba) return nil;
	
	unsigned int i, c = [fba count];
	for (i = 0; i < c; i++) {
		NSURL *url = [dict objectForKey:[fba objectAtIndex:i]];
		if (url) {
			NSLog(@"quality %@ picked up, URL = %@", [fba objectAtIndex:i], [url absoluteString]);
			return url;
		}
	}
	return nil;
}
- (void)draw
{
	NSURL *url = [DTImageBox URLFromSource:_source quality:_quality];
	if (!url) return;

	if ([_provider imageStatus:url] != DTImageReady) {
		NSLog(@"image not ready, start fetching from _provider");
		[_provider startFetchImage:url];
		
		NSLog(@"obtaining lock");
		[[_provider sharedLock] lock];
		
		NSLog(@"lock obtained, now unlock");
		[[_provider sharedLock] unlock];
	}
	
	// still no image?
	if ([_provider imageStatus:url] != DTImageReady) return;
	
	NSImage *img = [_provider useImage:url];
	
	NSSize size = [img size];
	
	// remember, Cocoa's coordination origin start from bottom
	// realY + H + Y = totalH
	// => realY = totalH - (Y + H)
	NSRect cropRect = NSMakeRect(size.width * _cropX, size.height * (1 - (_cropY + _cropH)), size.width * _cropW, size.height * _cropH);
	DTDrawImageInRect(img, _boundingRect, _bleed, YES, cropRect);
}
- (NSString*)description {
	return [[NSDictionary dictionaryWithObjectsAndKeys:
		_source, @"source",
		[NSNumber numberWithBool:_bleed], @"bleed",
		[NSValue valueWithRect:NSMakeRect(_cropX, _cropY, _cropW, _cropH)], @"crop",
		[NSValue valueWithRect:_boundingRect], @"bounding-rect",
		_quality, @"quality",
		_provider, @"image-provider",
		nil] description];
}
@end

void DTDrawImageBoxInRect(NSRect boundingRect, NSDictionary *dict, NSString *quality, id<DTImageProvider> _provider)
{
	DTImageBox *ib = [[DTImageBox alloc] initWithDictionary:dict boundingRect:boundingRect quality:quality imageProvider:_provider];
	[ib draw];
	[ib release];
}