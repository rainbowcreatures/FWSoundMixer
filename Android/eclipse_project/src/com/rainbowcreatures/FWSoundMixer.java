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

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class FWSoundMixer implements FREExtension {

	@Override
	public FREContext createContext(String arg0) {
		// TODO Auto-generated method stub
		System.loadLibrary("com_rainbowcreatures_FWSoundMixer_JNIWrapper");
		return new FWSoundMixerContext();
	}

	@Override
	public void dispose() {
		// TODO Auto-generated method stub

	}

	@Override
	public void initialize() {
		
		// TODO Auto-generated method stub

	}

}
