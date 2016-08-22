/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

package com.rainbowcreatures;

public class FWSoundMixer_JNIWrapper
{
	public native void FWSoundMixer_add(byte[] sound, String name, int play, int start, int loops); 
	public native void FWSoundMixer_init();    
	// do audio step, then copy the internal audio buffer to the supplied ByteArray
	public native void FWSoundMixer_audioStep(byte[] result);
	// convert the latest audio buffer to shorts and get it
	public native void FWSoundMixer_getShorts(byte[] result);
	public native void FWSoundMixer_recordMic(byte[] sound); 
	public native void FWSoundMixer_recordDynamic(byte[] sound);
	public native void FWSoundMixer_dispose();    
	public native boolean FWSoundMixer_soundExists(String name);   
	public native void FWSoundMixer_stopAll(); 
}