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
	
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;	
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;


	public class FWSound extends EventDispatcher {

		private static var counter:Number = 0;
		private var name:String = "";
		private var flashSound:Sound;
		public var playNative:Boolean = true;
		private var mySoundMixer:Object = null;

		public function FWSound(stream:URLRequest = null, context:SoundLoaderContext = null, _flashSound:Sound = null, _mySoundMixer:Object = null, _playNative:Boolean = true) {
			playNative = _playNative;
			mySoundMixer = _mySoundMixer;
			name = "sound_" + counter;
			if (_flashSound == null) {
				flashSound = new Sound(stream, context);
			} else {
				flashSound = _flashSound;
				// preload(extract) the sound into the mixer when constructing
				mySoundMixer.add(flashSound, name, false, 0, 0);			
			}
			flashSound.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		        flashSound.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		        flashSound.addEventListener(Event.COMPLETE, completeHandler);			
			counter++;
	     	}

		private function errorHandler(e:IOErrorEvent):void {
			dispatchEvent(e);
		}

		private function progressHandler(e:ProgressEvent):void {
			dispatchEvent(e);
		}

		private function completeHandler(e:Event):void {
			dispatchEvent(e);			
		}
		
		public function play(startTime:Number = 0, loops:Number = 0, sndTransform:SoundTransform = null):SoundChannel {
			mySoundMixer.add(flashSound, name, true, startTime, loops);			
			if (playNative) {
				return flashSound.play(startTime, loops, sndTransform);
			} else {
				return null;
			}
		}
		
		public function load(stream:URLRequest, context:SoundLoaderContext = null):void {
			flashSound.load(stream, context);
		}

		public function close():void {
			flashSound.close();
		}

		public function extract(target:ByteArray, length:Number, startPosition:Number = -1):Number {
			return flashSound.extract(target, length, startPosition);
		}
	}	
}
