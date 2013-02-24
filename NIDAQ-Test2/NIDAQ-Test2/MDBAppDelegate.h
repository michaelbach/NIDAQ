//
//  MDBAppDelegate.h
//  NIDAQ-Test2
//
//  Created by Bach on 28.07.12.
//  Copyright (c) 2012 Bach. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NIDAQX.h"
#import "Oscilloscope3.h"

#define kSampleIntervalOscilloscopeInSeconds 0.01


//@interface MDBAppDelegate : NSObject <NSApplicationDelegate>
//@property (assign) IBOutlet NSWindow *window;
@interface MDBAppDelegate: NSObject <NSApplicationDelegate> {
	
	IBOutlet Oscilloscope3 *osci00;
	NIDAQX *nidaqx;
	NSTimer *timer100Hz;
	
}


@property (retain) NIDAQX *nidaqx;
@property (retain) NSTimer *timer100Hz;
@end

