//
//  NIDAQX.m
//  NI-DAQ
//
//  Created by bach on 21.09.09.
//  Copyright 2009 Universitäts-Augenklinik. All rights reserved.
//


#import "NIDAQX.h"


@implementation NIDAQX

/* From the NI-DAQmx Base ReadMe.rtf
            ========================

 Any time a new device is added or removed, you should run the following:
 /Applications/National Instruments/NI-DAQmx Base/lsdaq.app
 
 Make note of the device name (Dev1 for example) as this is the name 
 you need to specify when creating channels in your program. 
 A device name may change each time a device is added or removed.
*/
#define deviceName "Dev1\0"
#define physicalChannel "Dev1/ai0:4"

#define kMaxChannels 5
static float64 sampleArray[kMaxChannels+1];
static TaskHandle  taskHandle;


/*- (void)getSystemVersionMajor:(NSUInteger *)major minor:(NSUInteger *)minor bugFix:(NSUInteger *)bugFix; {
	// http://www.cocoadev.com/index.pl?DeterminingOSVersion
	OSErr err;
    SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
    if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) goto fail;
    if (systemVersion < 0x1040)     {
        if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 + ((systemVersion & 0x0F00) >> 8);
        if (minor) *minor = (systemVersion & 0x00F0) >> 4;
        if (bugFix) *bugFix = (systemVersion & 0x000F);
    } else {
        if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
        if (major) *major = versionMajor;
        if (minor) *minor = versionMinor;
        if (bugFix) *bugFix = versionBugFix;
    }    
    //		NSLog(@"major: %d, minor: %d", major, minor);
    //		NSLog(@"sizeof int: %ul", sizeof(int));
    return;
fail:
    NSLog(@"Unable to obtain system version: %ld", (long)err);
    if (major) *major = 10;
    if (minor) *minor = 0;
    if (bugFix) *bugFix = 0;
} */

	
- (void) killTask; {
	if (taskHandle == 0) return;
	DAQmxBaseStopTask(taskHandle);  DAQmxBaseClearTask(taskHandle);  taskHandle = 0;
}


- (NSString *) createErrorMessageAtStep: (NSInteger) step {
	char errBuff[2048]={'\0'};  
	DAQmxBaseGetExtendedErrorInfo(errBuff, 2048);
	return [NSString stringWithFormat: @"NIDAQX>init>error step %d, cause: %@", step, [NSString stringWithCString: errBuff encoding: NSASCIIStringEncoding]];
}


- (id) init {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if ((self = [super init])) {
 		isHardwareOk = NO;
		taskHandle = 0;  minVoltage = -10.0;  maxVoltage = 10.0;  maxChannels = kMaxChannels;		
//		NSUInteger major, minor, bugFix;	// we're doing 10.8+ only, so we don't need this any more
//		[self getSystemVersionMajor:&major minor: &minor bugFix: &bugFix];
//		if ((major != 10) || (minor >= 7)) return self;	// this had been necessary for 10.7, no longer
		int32 error = DAQmxBaseCreateTask("", &taskHandle);
		if (error) {
			[self killTask];  NSLog(@"%@",[self createErrorMessageAtStep: 1]);
		} else {
			error = DAQmxBaseResetDevice(deviceName);// not sure when I need to do this
			if (error) {
				NSLog(@"%@",[self createErrorMessageAtStep: 0]);  
			} else {
				error = DAQmxBaseCreateAIVoltageChan(taskHandle, physicalChannel, NULL, DAQmx_Val_RSE, minVoltage, maxVoltage, DAQmx_Val_Volts, NULL);
				if (error) { 
					[self killTask];  NSLog(@"%@",[self createErrorMessageAtStep: 2]);
				} else {
					error = DAQmxBaseStartTask(taskHandle);
					if (error) {
						[self killTask];  NSLog(@"%@",[self createErrorMessageAtStep: 3]);
					} else {
						isHardwareOk = YES;	
					}
				}
			}
		}
	//	isHardwareOk = NO;
	}
	//NSLog(@"%s, exit.", __PRETTY_FUNCTION__);
	return self;
}


/*  Unclear how to get this from the board, help doesn't help here
- (void) getVersion {
	uint32 major, minor;
	DAQmxBaseGetSysNIDAQMajorVersion(&major);
	DAQmxBaseGetSysNIDAQMinorVersion(&major);
	NSLog(@"Version: %ui.%ui.", major, minor);
}
*/


- (void) invalidate {	// NSLog(@"%s", __PRETTY_FUNCTION__);
	[self killTask];
}

- (void) dealloc {	// NSLog(@"%s", __PRETTY_FUNCTION__);
	[self invalidate];
#if !__has_feature(objc_arc)
	[super dealloc];
#endif

}


- (CGFloat) voltageSimulated: (NSInteger) channel {
#pragma unused (channel)
	static NSUInteger localCounter = 0;
	if (localCounter++ > 300) localCounter=0;
	CGFloat returnValue = (((CGFloat)random()) / ((CGFloat)RAND_MAX) - 0.5) * 2.0;	// random number in range (-1.0 … +1.0)
	returnValue *= 0.2;
	returnValue += (localCounter > 15) ? 1 : -1;
//	if (channel == 2) returnValue = (localCounter > 15) ? 1 : -1;;
	return returnValue * 0.5;
}


- (CGFloat) voltageAtChannel: (NSUInteger) channel {
	if (channel > maxChannels) return 0;
	if (isHardwareOk) {
		if (channel == 0) {
			int32 pointsRead;
			DAQmxBaseReadAnalogF64(taskHandle, /*numSampsPerChan*/1, /*timeout=*/1.0, DAQmx_Val_GroupByScanNumber, sampleArray, /*arraySizeInSamps*/kMaxChannels, &pointsRead, NULL);
			if (pointsRead < 1) NSLog(@"pointsRead %ld", pointsRead);
		}
		return sampleArray[channel];
	} else {
		return [self voltageSimulated: channel];
	}
}


- (NSArray *) voltageAtChannels0to: (NSUInteger) endChannel {
	NSMutableArray* channelArray = [NSMutableArray arrayWithCapacity: endChannel+1];
	[channelArray addObject: [NSNumber numberWithFloat: [self voltageAtChannel: 0]]];
	for (NSUInteger i=1; i<=endChannel; ++i) [channelArray addObject: [NSNumber numberWithFloat: sampleArray[i]]];
	return channelArray;
}

@synthesize isHardwareOk;
@synthesize minVoltage, maxVoltage;
@synthesize maxChannels;


@end
