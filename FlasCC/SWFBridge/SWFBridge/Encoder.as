// FlashyWrappers 2.5 (C) 2014 Pavel Langweil
// SWF Bridge to encoder SWC compiled into this bridge for fixing Adobe IDE's issues and ffmpeg legal issues by providing the ffmpeg library separately
// from the app file.

package {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import com.rainbowcreatures.FWSoundMixer;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.system.Worker;
	import flash.system.Security;

	import com.rainbowcreatures.FWSound;

	public class Encoder extends MovieClip
	{
		// encoder instance
		private var mySoundMixer:FWSoundMixer;

		public function Encoder()
		{
			// constructor code
			try {Security.allowDomain("*");}catch (e) { };
		}

		// get instance of the encoder
		public function getInstance()
		{			
//			root.addChild(this);
			mySoundMixer = FWSoundMixer.getInstance();
			return mySoundMixer;
		}				
	}
}