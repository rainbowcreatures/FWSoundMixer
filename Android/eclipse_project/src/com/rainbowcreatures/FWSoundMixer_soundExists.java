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
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class FWSoundMixer_soundExists implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		boolean found = false;
		try {
			found = ((FWSoundMixerContext) arg0).jniWrapper.FWSoundMixer_soundExists(arg1[0].getAsString());
			return FREObject.newObject(found);
		} catch (Exception e) {
			arg0.dispatchStatusEventAsync("error", e.getMessage());
		}			
		return null;
	}
}
