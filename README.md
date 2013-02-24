©2013 Michael Bach, michael.bach@uni-freiburg.de, michaelbach.de


NIDAQ
=====

A simplified interface to the NI-DAQmx driver suite for National Instruments process periphery.
 
So far we only need n-channel analog acquisition, but w/o delay!




Some details
------------
* last NI-DAQ version: 3.6
<http://joule.ni.com/nidu/cds/view/p/id/3431/lang/en>

* Problem: While this works in 10.8, only in 32 bit mode!
* Tested with
	* NI-USB 6008 (USB) die ist zu langsam für EP2013 (wg. USB)
	* NI PCIe-6251 (PCI-Express-Bus) http://sine.ni.com/nips/cds/view/p/lang/de/nid/201813  die geht gut, kostet 1150€

