// PagePreviewerMain.m

#import "PagePreviewer.h"

int main(int argc, char *argv[]) {
	int rsp;
	
	if (argc < 5) {
		fprintf(stderr, "usage: PagePreviewer json-source page-label resolution output-filename [replacement-cond replacement-data]\n");
		return 0;
	}
	
	NSApplicationLoad();
	id arp = [NSAutoreleasePool new];
    
    fprintf (stderr, "running: %s %s %s %s\n", argv[1], argv[2], argv[3], argv[4]);

	id ppreview = [[PagePreviewer alloc] initWithSourceFile:[NSString stringWithUTF8String:argv[1]]
		pageLabel:[NSString stringWithUTF8String:argv[2]]
		resolution:[NSString stringWithUTF8String:argv[3]]
		outputFile:[NSString stringWithUTF8String:argv[4]]];
	
	if (argc >= 7) {
		NSData *mrid = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithUTF8String:argv[5]]]];
		NSData *rid = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithUTF8String:argv[6]]]];

		if (mrid && rid) {
			NSLog(@"Using replacement condition: %s and replacement data: %s", argv[5], argv[6]);
			[ppreview setMatchReplaceImageData:mrid];
			[ppreview setReplacementImageData:rid];
		}
		else {
			NSLog(@"Something wrong with either replacement condition: %s or replacement data: %s", argv[5], argv[6]);
		}
	}
	
	[NSThread detachNewThreadSelector:@selector(run) toTarget:ppreview withObject:nil];

	double resolution = 0.1;
	BOOL isRunning;
	do {
		NSDate* next = [NSDate dateWithTimeIntervalSinceNow:resolution]; 
		isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
					beforeDate:next];
	} while (isRunning && [ppreview isRunning]);
	
	rsp = [ppreview errorCode];
	[ppreview release];
	[arp release];
	
	return rsp;
}
