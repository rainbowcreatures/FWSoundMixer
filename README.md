# FlashyWrappers SDK: FWSoundMixer

*WORK IN PROGRESS - Flash version built only, iOS and Android needs to be tested yet.*

This library is part of FlashyWrappers but can be used as standalone. Originally created to make recording Flash Sounds possible, it is a simple multiplatform sound mixer with accessible PCM data which can be further worked with (saved, sent to FlashyWrappers etc.).
Only mobile ANE's are available, for desktop it is assumed you'll use the Flash FlasCC / Crossbridge build which should be fast enough. Windows and OS X ANE"s should be easy to add though.

Building
--------

*Android / Flash*
The .bat files are used to build FW on Windows.

*iOS*

Those platforms use identical source code file, luckily AVFoundation is almost identical on OS X and iOS. These are currently not ready for release yet but they are included in case you can't wait.