package com.rainbowcreatures;

import java.nio.ByteBuffer;

public class FWSoundMixer_JNIWrapper
{
	public native void FWSoundMixer_add(byte[] sound, String name, int play, int start, int loops); 
	public native void FWSoundMixer_init();    
	// do audio step, then copy the internal audio buffer to the supplied ByteArray
	public native void FWSoundMixer_audioStep(byte[] result);
	public native void FWSoundMixer_recordMic(byte[] sound); 
	public native void FWSoundMixer_dispose();    
	public native void FWSoundMixer_soundExists(String name);   
	public native void FWSoundMixer_stopAll(); 
}
