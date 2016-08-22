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

	import flash.events.SampleDataEvent;	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;	
	import flash.media.Sound;	
	import flash.utils.Endian;	
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.utils.getTimer;
	import flash.media.SoundMixer;

	import com.rainbowcreatures.FWSoundMixer.*;
	import com.rainbowcreatures.FWSoundMixer.CModule;
	import com.rainbowcreatures.FWSound;

	public class FWSoundMixer extends MovieClip {

		public var WAV:ByteArray = new ByteArray();
		public var recordWAV:Boolean = false;

		private var audioLength:Number = 0;

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
		public var playSounds:Boolean = false;
		private var micData:ByteArray = new ByteArray();
		private var FWEncoder:* = null;  			

		private var oldEnd:Number = 0;
		
		public var benchmarkDelta:Vector.<Number> = new Vector.<Number>();
		public var benchmarkStartDiff:Vector.<Number> = new Vector.<Number>();

		public function FWSoundMixer():void {	
			audioBuffer = CModule.getPublicSymbol("_ZN12FWSoundMixer11audioBufferE");
		}

		public static function getInstance():FWSoundMixer {
			if (instance == null) {
				// no instance
				instance = new FWSoundMixer();
			} 
			return instance;			
		}

		/* Init function, supply the external function which should handle recording samples from FWSoundMixer */
		public function init(_sndData:Function = null, _FWEncoder:* = null):void {

			FWEncoder = _FWEncoder;

			// try to set user capture handlers or set the default ones
			if (_sndData != null) {
				sndData = _sndData;
			} else sndData = this.dummyHandler;
/*			if (_sndDataMic != null) {
				sndDataMic = _sndDataMic;
			} else sndDataMic = this.dummyHandler;*/

			audioBuffer = CModule.getPublicSymbol("_ZN12FWSoundMixer11audioBufferE");
			FWSoundMixer_init();

			// capture game / app audio
		        snd = new Sound();
			samplesMic.endian = Endian.LITTLE_ENDIAN;			

			WAV.endian = Endian.LITTLE_ENDIAN;			

			rawData.endian = Endian.LITTLE_ENDIAN;			
			rawData.position = 0;

			// capture mic
			microphone = Microphone.getMicrophone();
			microphone.codec = SoundCodec.NELLYMOSER;
			microphone.rate = 44;
			microphone.encodeQuality = 10;
			microphone.setSilenceLevel(0);
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
				microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, sndDataMicHandler);									
			}
			isCapturing = true;
		}

		public function stopCapture():void {
		        snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, sndDataHandler);
			if (recordMicState) {
				microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, sndDataMicHandler);									
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
			if (FWEncoder != null) FWEncoder.addAudioFrame(rawData);
			if (recordWAV) addWAVFrame(rawData);
		}

		private function sndDataMicHandler(e:SampleDataEvent):void {
			recordMic(e);
		}

		/* Record sound coming from the FlasCC FWSoundMixer into ByteArray so we can return them */
		public function recordSamples(e:SampleDataEvent, play:Boolean = false):void {
//			trace("AudioStep----");

			var start:Number = getTimer();
	
			if (oldEnd != 0) {
				var diff:Number = start - oldEnd;
				benchmarkStartDiff.push(diff);
			}

			FWSoundMixer_audioStep();
			recordedMic = false;
			e.data.endian = Endian.LITTLE_ENDIAN;
	    		e.data.length = 0;
			var ap:int = CModule.read32(audioBuffer);	      
			var b:int = 0;

			// important...
			rawData.position = 0;

			// quick copy of the samples from domain memory into our exposed rawData ByteArray
			CModule.ram.position = ap;
			CModule.readBytes(ap, 16384, rawData);

			// play the buffer if set, divide by 8 because float is 4 bytes and we read 2 floats each cycle (4 * 2)
			for (var i:int=0; i < 16384 / 8; i++) {
				if (play) {
					e.data.writeFloat(CModule.ram.readFloat());
					e.data.writeFloat(CModule.ram.readFloat()); 
				} else {
					e.data.writeFloat(0);
					e.data.writeFloat(0);
				}
			}

			rawData.position = 0;
			var end:Number = getTimer();
			benchmarkDelta.push(end - start);
			oldEnd = end;
		}		

		// stops all playing FWSounds, and also calls the native "stopAll" method of Flash SoundMixer
		// however, this causes the "snd" responsible for capturing the sound to stop playing. This
		// is bad, it has the same effect like calling "stopCapture". Therefore, immediately after stopping
		// all native sounds, we will call snd.play() to start playing the sound again.
		
		public function stopAll():void {
			FWSoundMixer_stopAll();

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

		/* Record microphone into FlasCC SoundMixer */
		public function recordMic(event:SampleDataEvent):void {
			if (event.data.bytesAvailable > 0)
			{
				while(event.data.bytesAvailable > 0)
				{
					samplesMic.writeFloat(event.data.readFloat());
				}
			}
//			trace("(" + getTimer() +") Recording " + samplesMic.length + " bytes of mic data...");
			samplesMic.position = 0;
			FWSoundMixer_recordMic(samplesMic);
			samplesMic.length = 0;
			recordedMic = true;
		}

		/* Record microphone into FlasCC SoundMixer */
		public function recordDynamic(stereoPCMFloatingSamples:ByteArray):void {
			stereoPCMFloatingSamples.position = 0;
			FWSoundMixer_recordDynamic(stereoPCMFloatingSamples);
		}

		// add sound to sound mixer library
		public function add(s:Sound, name:String, play:Boolean = false, start:int = 0, loops:int = 0):void {
			FWSoundMixer_add(s, name, play, start, loops);			
		}
	}
}