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

import java.util.HashMap;
import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

public class FWSoundMixerContext extends FREContext {

	public FWSoundMixer_JNIWrapper jniWrapper;

	@Override
	public void dispose() {
		// TODO Auto-generated method stub

	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		// TODO Auto-generated method stub
		jniWrapper = new FWSoundMixer_JNIWrapper();
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("FWSoundMixer_add", new FWSoundMixer_add());
		functionMap.put("FWSoundMixer_audioStep", new FWSoundMixer_audioStep());
		functionMap.put("FWSoundMixer_convertToShorts", new FWSoundMixer_convertToShorts());
		functionMap.put("FWSoundMixer_dispose", new FWSoundMixer_dispose());
		functionMap.put("FWSoundMixer_init", new FWSoundMixer_init());
		functionMap.put("FWSoundMixer_recordMic", new FWSoundMixer_recordMic());
		functionMap.put("FWSoundMixer_recordDynamic", new FWSoundMixer_recordDynamic());
		functionMap.put("FWSoundMixer_soundExists", new FWSoundMixer_soundExists());
		functionMap.put("FWSoundMixer_stopAll", new FWSoundMixer_stopAll());
		functionMap.put("FWSoundMixer_recordMicrophoneStart", new FWSoundMixer_recordMicrophoneStart());
		functionMap.put("FWSoundMixer_recordMicrophonePause", new FWSoundMixer_recordMicrophonePause());
		functionMap.put("FWSoundMixer_recordMicrophoneStop", new FWSoundMixer_recordMicrophoneStop());
		functionMap.put("FWSoundMixer_initMicrophone", new FWSoundMixer_initMicrophone());
		return functionMap;
	}

}
