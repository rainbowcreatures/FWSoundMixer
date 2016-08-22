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

Source code taken from the example:

```
package  {	
	// comment these 3 out for Flash Player compilation. AIR freaks out when these are put into 
	// compiler constants, thinking there's no ActionScript code at all (bug?)
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.display.Graphics;

	import com.rainbowcreatures.swf.*;
	import com.rainbowcreatures.*;
	
	import flash.net.FileReference;
	import flash.events.StatusEvent;
	import flash.media.SoundChannel;
	
	public class Document extends MovieClip {
		
		// our FW SoundMixer sound classes
		var beep:FWSound;
		var track:FWSound;		
		
		// the FW SoundMixer
		var mySoundMixer:FWSoundMixer;

		// which frame are we at?
		var frameIndex:Number = 0;
		
		// sound channel
		var myChannel:SoundChannel = new SoundChannel();

		public function Document() {
			// init the FW SoundMixer
			addChild(new FPSCounter());
			mySoundMixer = FWSoundMixer.getInstance();
			mySoundMixer.addEventListener(StatusEvent.STATUS, onStatus);
			mySoundMixer.load("../../lib/FlashPlayer/");
		}
		
		function onStatus(e:StatusEvent):void {
			if (e.code == 'ready') {
				// init the sound mixer, with internal WAV recording switched on and sounds playing from buffer for preview
				// - that means we will also hear the microphone
				mySoundMixer.recordWAV = true;			
				mySoundMixer.playSounds = true;			
				mySoundMixer.init();
				
				startButton.enabled = true;
				soundButton.addEventListener(MouseEvent.CLICK, onSoundButtonClick);
				saveButton.addEventListener(MouseEvent.CLICK, onSaveButtonClick);
				startButton.addEventListener(MouseEvent.CLICK, onStartButtonClick);				

				// init the sounds, notice the third parameter is the Flash Sound which our class encapsulates				
				beep = new FWSound(null, null, new beepSound(), mySoundMixer, true);		
				track = new FWSound(null, null, null, mySoundMixer, true);
				track.addEventListener(Event.COMPLETE, onComplete);							
				track.load(new URLRequest("piano.mp3"));				
			}
		}

		function onComplete(e:Event):void {			
			startButton.enabled = true;
		}		

		function onStartButtonClick(e:MouseEvent):void {						
			myChannel = track.play(0, 100);
			
			saveButton.enabled = true;
			soundButton.enabled = true;
			startButton.enabled = false;
			
			// don't forget to call startCapture when everything is setup
		       	mySoundMixer.startCapture(false);			
		}

		function onSaveButtonClick(e:MouseEvent):void {

			// stop capturing
			mySoundMixer.stopCapture();
			myChannel.stop();
			removeEventListener(Event.ENTER_FRAME, onFrame);									
			
			// set buttons and save the captured audio to wav file
			saveButton.enabled = false;
			soundButton.enabled = false;
			startButton.enabled = true;
			
			if (CONFIG::AIR) {
				trace("Saving WAV file...");
				var file:File;
				// save to apps folder on mobile
 				file = File.userDirectory.resolvePath("audio.wav");						
 				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				trace("Saving " + mySoundMixer.WAV.length + " bytes ...");
   				fileStream.writeBytes(mySoundMixer.WAV, 0, mySoundMixer.WAV.length);
   				fileStream.close();
				trace("Done, file was saved to " + file.nativePath);
			}
			
			if (CONFIG::FLASH) {
				var f:FileReference = new FileReference();
				f.save(mySoundMixer.WAV, "audio.wav");			
			}
			
			// we must delete the WAV data manually for now after saving, or it will accumulate in memory!			
			mySoundMixer.WAV.length = 0;
		}
		
		function onSoundButtonClick(e:MouseEvent):void {
			beep.play();
		}
	}
}
```