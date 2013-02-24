//
//  MDBAppDelegate.m
//  NIDAQ-Test2
//
//  Created by Bach on 28.07.12.
//  Copyright (c) 2012 Bach. All rights reserved.
//

#import "MDBAppDelegate.h"

@implementation MDBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification { // NSLog(@"%s", __PRETTY_FUNCTION__);
	nidaqx = [[NIDAQX alloc] init];
	if (nidaqx == nil) [NSApp terminate:nil];
	
	[osci00 setFullscale: [nidaqx maxVoltage]];
	[osci00 setColor: [NSColor blueColor] forTrace: 0];
	[osci00 setColor: [NSColor blackColor] forTrace: 1];
	
	//	NSLog(@" %d" , [nidaqx maxChannels]);
	timer100Hz = [[NSTimer scheduledTimerWithTimeInterval: kSampleIntervalOscilloscopeInSeconds target: self selector: @selector(handle100HzTimer:) userInfo: nil repeats: YES] retain];
}




- (void) handle100HzTimer: (NSTimer *) timer {	//NSLog(@"%s", __PRETTY_FUNCTION__);
#pragma unused (timer)
	[osci00 advanceWithSamples: [nidaqx voltageAtChannels0to: 3]];
}


- (void)windowWillClose:(NSNotification *)notification {	NSLog(@"%s", __PRETTY_FUNCTION__);
#pragma unused (notification)
}


- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
#pragma unused (theApplication)
	return YES;
}


- (void) dealloc {	// WHY IS THIS NOT ALWAYS CALLED? NSLog(@"myWindowController>dealloc entry\n");
	NSLog(@"myWindowController: dealloc exit\n");
	[super dealloc];
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app {	//NSLog(@"%s", __PRETTY_FUNCTION__);
#pragma unused (app)
	[timer100Hz invalidate];  [timer100Hz release];  timer100Hz = nil;
	[nidaqx invalidate];
	[nidaqx dealloc];
	//	NSLog(@"applicationShouldTerminate end");
	return NSTerminateNow;
}

@synthesize nidaqx;
@synthesize timer100Hz;

@end
