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

public class FWSoundMixer_recordMic implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub		
		try {
			byte[] bytes = null;
			FREByteArray ba = null;
			if (arg1[0] != null) {
				ba = (FREByteArray) arg1[0];
				ba.acquire();
				ByteBuffer bb = ba.getBytes().order(ByteOrder.LITTLE_ENDIAN);
				bytes = new byte[(int) ba.getLength()];
				bb.get(bytes);
			} 			
			((FWSoundMixerContext) arg0).jniWrapper.FWSoundMixer_recordMic(bytes);
			if (ba != null) {
				ba.release();
			}
		}
		catch (Exception e) {
			System.out.println("Something went wrong: " + e.getMessage());
			arg0.dispatchStatusEventAsync("error", e.getMessage());
		}
		
//		System.out.println("FWSoundMixer_add() end, it took: " + (System.currentTimeMillis() - time) + " ms");

		return null;
	}

}
