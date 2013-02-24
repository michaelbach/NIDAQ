/*
NIDAQX.h


History
=======

2012-08-06	installed the new 3.6 NI-DAQmx base, still doesn't do 64 bit.
2012-03-14	clarified the origin of the "Dev1" string.
2010-03-03	added the "voltageAtChannels0to:" method (mb)
2009-09-21	created by bach

NI-DAQmx-Installation:
generisch: http://search.ni.com/nisearch/app/main/p/bot/no/ap/tech/lang/de/pg/1/sn/catnav:du,n19:MacOS
3.6: http://joule.ni.com/nidu/cds/view/p/id/3431/lang/en
3.5. http://joule.ni.com/nidu/cds/view/p/id/2892/lang/de
3.4.5: http://joule.ni.com/nidu/cds/view/p/id/2650/lang/en
 
Meine Prozessinterfacekarten:
NI-USB 6008 (USB) die ist zu langsam für EP2013 (wg. USB)
NI PCIe-6251 (PCI-Express-Bus) http://sine.ni.com/nips/cds/view/p/lang/de/nid/201813  die geht gut, kostet 1150€
 
wenn mal die X-Serie mit DAQmxBase unterstützt wird, dann ist die PCIe-6320 mit 500€ preisgünstiger und sollte auch schnell genug sein
*/

#import <Cocoa/Cocoa.h>
#import "NIDAQmxBase.h"


@interface NIDAQX : NSObject {
	BOOL isHardwareOk;
	CGFloat minVoltage, maxVoltage;
	NSUInteger maxChannels;
}


- (CGFloat) voltageAtChannel: (NSUInteger) channel;
- (NSArray *) voltageAtChannels0to: (NSUInteger) endChannel;

//- (void) startSweepWithSamplingInterval: (int)milliseconds forNumChannels: (int)numChannels forSamplesPerChannel: (int)samplesPerChannel;
//- (NSArray *) getSweepOfChannel: (int) theChannel;
	//- (void) setAnalogOutAt: (int) channel toVoltage: (SInt32) outValue0to255;

- (void) invalidate;	// probably no longer necessary after I added the device reset 2010-01-21

@property (readonly) BOOL isHardwareOk;
@property (readonly) CGFloat minVoltage, maxVoltage;
@property (readonly) NSUInteger maxChannels;


@end
