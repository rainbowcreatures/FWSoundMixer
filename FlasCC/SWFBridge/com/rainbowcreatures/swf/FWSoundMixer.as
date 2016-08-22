// FlashyWrappers 2.5 (C) 2014 Pavel Langweil
// SWF Bridge to encoder SWC compiled into this bridge for fixing Adobe IDE's issues and ffmpeg legal issues by providing the ffmpeg library separately
// from the app file.
// This gets compiled into the library SWC, it pretends to be the usual SWC but is loading the main library SWF underneath

package com.rainbowcreatures.swf {

	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;		
	import flash.events.StatusEvent;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;

	import com.rainbowcreatures.FWSound;	

	public class FWSoundMixer extends EventDispatcher {

		private var dummySound:FWSound = null;
		private static var instance:FWSoundMixer = null;
		private var mySoundMixer:Object = null;
		public var platform:String = "FLASH";
		public var encoderMc:MovieClip;
		// in the constructor we'll load the SWFBridge
		public function FWSoundMixer():void {			
		}

		// needed for the SWF Bridge
		public function load(pathToBridge:String = ""):void {
			var request:URLRequest = new URLRequest(pathToBridge + "FWSoundMixer_SWFBridge.swf");
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onEncoderLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void {
				throw new Error("[FlashyWrappers error] FWSoundMixer_SWFBridge.swf couldn't be loaded! Please make sure it's in the same path as your main SWF or specify the path in the 'load' method like this: mySoundMixer.load('path/to/FWSoundMixer_SWFBridge/')");  
			});			
			loader.load(request);				
		}

		// after the encoder is loaded, dispatch the ready event
		private function onEncoderLoaded(e:Event):void {
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			encoderMc = loaderInfo.content as MovieClip;			

			if (encoderMc) {
				trace("[FlashyWrappers] Got FWSoundMixer class from FWSoundMixer_SWFBridge");
			} else {
				throw new Error("[FlashyWrappers error] Couldn't find the encoder class in FW_SWFBridge_ffmpeg!");
			}

			// assign mySoundMixer from the loaded SWF into the mySoundMixer object, so we can call its methods
			mySoundMixer = encoderMc["getInstance"]();			
			mySoundMixer.addEventListener(StatusEvent.STATUS, onStatus);
			dispatchEvent( new StatusEvent( StatusEvent.STATUS, false, false, "ready", ""));
		}

		// hand over status event from the encoder
		private function onStatus(e:StatusEvent):void {
			dispatchEvent(e);
		}

		public static function getInstance():FWSoundMixer {
			if (instance == null) {
				// no instance
				instance = new FWSoundMixer();
			} 
			return instance;
		}

		public function init(_sndData:Function = null, _FWEncoder:* = null):void {
			mySoundMixer.init(_sndData, _FWEncoder);
		}

		public function set recordWAV(b:Boolean):void {
			mySoundMixer.recordWAV = b;
		}

		public function get recordWAV():Boolean {
			return mySoundMixer.recordWAV;
		}

		public function set playSounds(b:Boolean):void {
			mySoundMixer.playSounds = b;
		}

		public function get playSounds():Boolean {
			return mySoundMixer.playSounds;
		}

		public function get rawData():ByteArray {
			return mySoundMixer.rawData;
		}

		public function get WAV():ByteArray {
			return mySoundMixer.WAV;
		}

		public function askMicPermission():void {
			mySoundMixer.askMicPermission();
		}

		public function startCapture(mic:Boolean = false):void {
			mySoundMixer.startCapture(mic);
		}

		public function stopCapture():void {
			mySoundMixer.stopCapture();
		}

		public function stopAll():void {
			mySoundMixer.stopAll();
		}

		public function startMicCapture():void {
			mySoundMixer.startMicCapture();
		}

		public function stopMicCapture():void {
			mySoundMixer.stopMicCapture();
		}

		public function recordSamples(e:SampleDataEvent, play:Boolean = false):void {
			mySoundMixer.recordSamples(e, play);
		}

		public function recordMic(event:SampleDataEvent):void {
			mySoundMixer.recordMic(event);
		}

		public function recordDynamic(stereoPCMFloatingSamples:ByteArray):void {
			mySoundMixer.recordDynamic(stereoPCMFloatingSamples);
		}

		public function add(s:Sound, name:String, play:Boolean = false, start:int = 0, loops:int = 0):void {
			mySoundMixer.add(s, name, play, start, loops);			
		}

	}	
}