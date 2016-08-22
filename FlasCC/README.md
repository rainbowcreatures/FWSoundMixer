The Flash version is very specific: 

1) First, you need to build the C++ files into SWC by now abandoned Crossbridge(former FlasCC) crosscompiler.

make all FLASCC=/c/path/to/Crossbridge/sdk/

2) This should produce FWSoundMixer.swc

3) Then, you need to wrap the SWC into SWF and build a "SWF Bridge" with its own SWC, which acts as interface into the wrapped SWF encoder. The reason for the SWF file historically was multithreading - when workers are spawned in separete
SWF, then only that separate SWF is cloned, not your whole SWF. Another reason for SWFBridge was problems with building apps when including FlashyWrappers SWC directly - it was very slow and sometimes created weird build errors.

To create a wrapper and SWF bridge for the example above, launch "buildflascc_wrapper.bat" in the projects root folder.