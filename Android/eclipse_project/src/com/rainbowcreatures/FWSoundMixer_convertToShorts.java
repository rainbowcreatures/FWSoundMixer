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

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class FWSoundMixer_convertToShorts implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		
		try {
			FREByteArray ba = (FREByteArray) arg1[0];
			ba.acquire();
			ByteBuffer bb = ba.getBytes().order(ByteOrder.LITTLE_ENDIAN);
			byte[] bytes = new byte[(int) ba.getLength()];
			((FWSoundMixerContext) arg0).jniWrapper.FWSoundMixer_getShorts(bytes);
			bb.put(bytes);
			ba.release();
		}
		catch (Exception e) {
			arg0.dispatchStatusEventAsync("error", e.getMessage());
		}

		return null;
	}

}
