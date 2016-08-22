/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

package com.rainbowcreatures {

	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	import flash.events.SampleDataEvent;	
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;	
	import flash.media.Sound;	
	import flash.utils.Endian;	
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.utils.getTimer;
	import flash.media.SoundMixer;

	import com.rainbowcreatures.FWSound;

	// Runtime check of the platform 
	import flash.system.Capabilities;

	public class FWSoundMixer extends EventDispatcher {

		private var _ctx:ExtensionContext;
	
		public var WAV:ByteArray = new ByteArray();
		public var recordWAV:Boolean = false;

		private var audioLength:Number = 0;
		public var nativeMicrophone:Boolean = false;

		/* C++ pointer to audioBuffer */
		private var audioBuffer:Number = 0;
		private var snd:Sound = null;	
		private var sndData:Function = null;
		private var sndDataMic:Function = null;
		private var samples:ByteArray = new ByteArray();			
		private var samplesMic:ByteArray = new ByteArray();
		private var recordMicState:Boolean = false;
		private var recordedMic:Boolean = false;
		private var isCapturing:Boolean = false;

		private static var instance:FWSoundMixer = null;
		public var microphone:Microphone = null;
		public var rawData:ByteArray = new ByteArray();
		private var rawDataShorts:ByteArray = new ByteArray();
		private var emptyBA:ByteArray = new ByteArray();
		public var playSounds:Boolean = false;
		private var micData:ByteArray = new ByteArray();
		private var FWEncoder:* = null;  			
		
		public var benchmarkDelta:Vector.<Number> = new Vector.<Number>();
		public var benchmarkStartDiff:Vector.<Number> = new Vector.<Number>();
		public var benchmarkMic:Vector.<Number> = new Vector.<Number>();
		private var oldEnd:Number = 0;

		// current platform (hopefully)
		public var platform:String = "FLASH";
		public var platform_type:String = "DESKTOP";

		public function FWSoundMixer():void {	
			// determine the platform 
			// we're in AIR
			if (Capabilities.playerType == 'Desktop') {
				if((Capabilities.os.indexOf("Windows") >= 0)) {
					platform = "WINDOWS";
					platform_type = "DESKTOP";
				}
				else if((Capabilities.os.indexOf("Mac") >= 0)) {
					platform = "MAC";
					platform_type = "DESKTOP";
				} 
				else if((Capabilities.os.indexOf("iPhone") >= 0)) {
					platform = "IOS";
					platform_type = "MOBILE";
				}
				else if((Capabilities.os.indexOf("Linux") >= 0)) {
					platform = "ANDROID";
					platform_type = "MOBILE";
				}
			} else {
				// we're in Flash Player, website or standalone
				platform = "FLASH";
				platform_type = "DESKTOP";
			}

			_ctx = ExtensionContext.createExtensionContext('com.rainbowcreatures.FWSoundMixerANE', '');

			if (!_ctx) {
				throw new Error("[FWSoundMixer error] Failed to initialize ANE context(is the native part missing?). Make sure the ANE configuration is right."); 
			} else {
				trace("Extension context initialized:" + _ctx);
			}

			// catch events from the ANE
			_ctx.addEventListener( StatusEvent.STATUS, onStatus );
		}
		
		// for compatibility with FlasCC version
		public function load(pathToBridge:String = ""):void {
			// encoder is ready instantly in the ANE version (unlike FlasCC where we must load SWFBridge first)
			instance.dispatchEvent( new StatusEvent( StatusEvent.STATUS, false, false, "ready", ""));
		}
		
		// status event handler
		private function onStatus( event:StatusEvent ):void {
			trace("Got event from extension, level:" + event.level + ", code: " + event.code);
			if (event.code != 'error') {
				dispatchEvent( new StatusEvent( StatusEvent.STATUS, false, false, event.code,  event.level));
			} else {
				throw new Error( "[FWSoundMixer error] " + event.level);
			}
		}

		public static function getInstance():FWSoundMixer {
			if (instance == null) {
				// no instance
				instance = new FWSoundMixer();
			} 
			return instance;			
		}
		
		public function dispose():void {

			_ctx.dispose();
		}

		/* Init function, supply the external function which should handle recording samples from FWSoundMixer */
		public function init(_sndData:Function = null, _FWEncoder:* = null):void {

			emptyBA.length = 16384;
			
			FWEncoder = _FWEncoder;

			// try to set user capture handlers or set the default ones
			if (_sndData != null) {
				sndData = _sndData;
			} else sndData = this.dummyHandler;
/*			if (_sndDataMic != null) {
				sndDataMic = _sndDataMic;
			} else sndDataMic = this.dummyHandler;*/
	
			_ctx.call('FWSoundMixer_init');

			// capture game / app audio
		    snd = new Sound();
			samplesMic.endian = Endian.LITTLE_ENDIAN;			
			samples.length = 16384;

			WAV.endian = Endian.LITTLE_ENDIAN;			

			rawData.endian = Endian.LITTLE_ENDIAN;			
			rawData.position = 0;
			rawData.length = 16384;

			rawDataShorts.endian = Endian.LITTLE_ENDIAN;			
			rawDataShorts.position = 0;
			rawDataShorts.length = rawData.length / 2;

			// capture mic
			microphone = Microphone.getMicrophone();
			microphone.codec = SoundCodec.NELLYMOSER;
			microphone.rate = 44;
			microphone.encodeQuality = 5;
			microphone.setSilenceLevel(0);
		}
		
		// free the sound mixer instance as well as all the uploaded sounds
		public function free():void {
			_ctx.call('FWSoundMixer_dispose');
		}

		private function dummyHandler():void {
		}

		public function askMicPermission():void {
			microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, sndDataMicHandler);									
			microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, sndDataMicHandler);									
		}


		// write WAV header
		private function writeWAVHeaders( channels:int=2, bits:int=16, rate:int=44100 ):void {  
			var channels:int = 2;
			var rate:int = 44100;
			var bits:int = 16;
			audioLength = 0;
			WAV.position = 0;
			WAV.writeUTFBytes( "RIFF" );   // 4
			WAV.writeInt( uint( 0 + 44 ) );  // 4
			WAV.writeUTFBytes( "WAVE" );  // 4
			WAV.writeUTFBytes( "fmt " );  // 4
			WAV.writeInt( uint( 16 ) );  // 4
			WAV.writeShort( uint( 1 ) );  // 2
			WAV.writeShort( channels );  // 2
			WAV.writeInt( rate );  // 4
			WAV.writeInt( uint( rate * channels * ( bits >> 3 ) ) );   // 4
			WAV.writeShort( uint( channels * ( bits >> 3 ) ) );  // 2
			WAV.writeShort( bits );   // 2
			WAV.writeUTFBytes( "data" );  // 4
			WAV.writeInt( 0 );  // 4
		}  

		// close the WAV and write the audio data size into the header
		private function finishWAV():void {			
			WAV.position = 4;
			WAV.writeInt(uint(audioLength + 44));
			WAV.position = 40;
			WAV.writeInt(audioLength);
			WAV.position = 0;
		}

		// add WAV audio frame, convert floats to short more or less in this one
		private function addWAVFrame(data:ByteArray):void {
			// on iOS, audio is being written to temp WAV track file
			var bytes:ByteArray = new ByteArray();
			bytes.length = data.length / 2;			
			bytes.endian = Endian.LITTLE_ENDIAN;			
			for (var a:int = 0; a < (data.length / 4); a++) {
				bytes.writeShort(data.readFloat() * 32767);
			}			
			WAV.writeBytes(bytes);
			audioLength += bytes.length;
		}

		public function startCapture(mic:Boolean = false):void {
			if (recordWAV) {
				writeWAVHeaders();
			}
			
			snd.addEventListener(SampleDataEvent.SAMPLE_DATA, sndDataHandler);
			snd.play();

			// microphone
			recordMicState = mic;
			if (recordMicState) {
				if (!nativeMicrophone) {
					microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, sndDataMicHandler);	
				} else {
					_ctx.call('FWSoundMixer_initMicrophone');
					_ctx.call('FWSoundMixer_recordMicrophoneStart');										
				}
			}
			isCapturing = true;
		}

		// This will go to a completely different class in the end
		// pause native mic
		public function pauseNativeMic():void {
			if (nativeMicrophone) {
				_ctx.call('FWSoundMixer_recordMicrophonePause');
			} else {
				trace("[FWSoundMixer] cannot call pause native mic, set nativeMicrophone to true to use recording microphone natively");
			}
		}

		// resume native mic
		public function resumeNativeMic():void {
			if (nativeMicrophone) {
				_ctx.call('FWSoundMixer_recordMicrophoneStart');
			} else {
				trace("[FWSoundMixer] cannot call resume native mic, set nativeMicrophone to true to use recording microphone natively");
			}
		}
		
		// stops all playing FWSounds, and also calls the native "stopAll" method of Flash SoundMixer
		// however, this causes the "snd" responsible for capturing the sound to stop playing. This
		// is bad, it has the same effect like calling "stopCapture". Therefore, imfmediately after stopping
		// all native sounds, we will call snd.play() to start playing the sound again.
		
		public function stopAll():void {
			_ctx.call('FWSoundMixer_stopAll');	

			// remove the even listener
			if (isCapturing) {
				snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, sndDataHandler);
			}
			SoundMixer.stopAll();

			if (isCapturing) {
				// recreate the sound, otherwise Invalid sound is thrown			
				snd = new Sound();
				samplesMic.endian = Endian.LITTLE_ENDIAN;			
				samples.length = 16384;
				snd.addEventListener(SampleDataEvent.SAMPLE_DATA, sndDataHandler);
				snd.play();
			}
		}

		public function stopCapture():void {
		    snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, sndDataHandler);
			if (recordMicState) {
				recordedMic = false;
				if (nativeMicrophone) {
					_ctx.call('FWSoundMixer_recordMicrophoneStop');	
				} else {
					microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, sndDataMicHandler);									
				}
			}
			if (recordWAV) {
				finishWAV();
			}
			isCapturing = false;
		}

		public function startMicCapture():void {
			microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, sndDataMicHandler);									
		}

		public function stopMicCapture():void {
			microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, sndDataMicHandler);									
		}

		private function sndDataHandler(e:SampleDataEvent):void {			
			recordSamples(e, playSounds);
			sndData();
			if (recordWAV) addWAVFrame(rawData);
		}

		private function sndDataMicHandler(e:SampleDataEvent):void {
			recordMic(e);
		}

		/* Record sound coming from the FlasCC FWSoundMixer into ByteArray so we can return them */
		public function recordSamples(e:SampleDataEvent, play:Boolean = false):void {
		
/*			var start:Number = getTimer();

			if (oldEnd != 0) {
				var diff:Number = start - oldEnd;
				benchmarkStartDiff.push(diff);
			}*/

			// wait for first mic capture so we're synced
		
			rawData.length = 16384;
			rawData.position = 0;

			rawDataShorts.length = 16384 / 2;
			rawDataShorts.position = 0;
			
			// mix a bit of audio and fill the rawData byteArray with it
			_ctx.call('FWSoundMixer_audioStep', rawData);
			// write the data right away to video if supplied
			
			if (FWEncoder != null) {
				if (platform == "ANDROID") {
					// for Android, convert to shorts natively because Android is stupid and doesn't accept floats, and we want to avoid conversions in Java later on
					_ctx.call('FWSoundMixer_convertToShorts', rawDataShorts);						
					FWEncoder.addAudioFrameShorts(rawDataShorts);
				} else {
					FWEncoder.addAudioFrame(rawData);					
				}
			}
			 
			e.data.endian = Endian.LITTLE_ENDIAN;
		    	e.data.length = 0;

			// important...
			rawData.position = 0;
			rawDataShorts.position = 0;

			// play the buffer if set
			if (play) {
				e.data.writeBytes(rawData, 0, 16384);
			} else {
				e.data.writeBytes(emptyBA, 0, 16384);
			}
			
			rawData.position = 0;
			rawDataShorts.position = 0;
/*			var end:Number = getTimer();
			benchmarkDelta.push(end - start);
			oldEnd = end;*/
		}		

		/* Record microphone into FlasCC SoundMixer */
		public function recordMic(event:SampleDataEvent):void {
//			var start:Number = getTimer();
			if (event.data.bytesAvailable > 0)
			{
				while(event.data.bytesAvailable > 0)
				{
					samplesMic.writeFloat(event.data.readFloat());
				}
			}
			
//			trace("(" + getTimer() +") Recording " + samplesMic.length + " bytes of mic data...");

			samplesMic.position = 0;
			_ctx.call('FWSoundMixer_recordMic', samplesMic);
			samplesMic.length = 0;
			recordedMic = true;
//			var end:Number = getTimer();
//			benchmarkMic.push(end - start);
		}

		/* Record microphone into FlasCC SoundMixer */
		public function recordDynamic(stereoPCMFloatingSamples:ByteArray):void {
			stereoPCMFloatingSamples.position = 0;
			_ctx.call('FWSoundMixer_recordDynamic', stereoPCMFloatingSamples);
		}

		// add sound to sound mixer library
		public function add(s:Sound, name:String, play:Boolean = false, start:int = 0, loops:int = 0):void {
		
			if (_ctx.call('FWSoundMixer_soundExists', name)) {
				trace("Sound " + name + " exists!");
				_ctx.call('FWSoundMixer_add', null, name, int(play), start, loops);	
			} else {
				trace("Sound " + name + " doesn't exist, extracting...");
		 		var b:ByteArray = new ByteArray();
		 		b.endian = Endian.LITTLE_ENDIAN;
		 		s.extract(b, int.MAX_VALUE);
				_ctx.call('FWSoundMixer_add', b, name, int(play), start, loops);			
			}
		}
	}
}