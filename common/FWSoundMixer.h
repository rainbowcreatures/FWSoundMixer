/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#ifndef FW_SOUNDMIXER_H
#define FW_SOUNDMIXER_H

#include "FWSound.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <math.h>
#include <vector>

using namespace std;

class FWSoundMixer {

private:

	vector<FWSound*> sounds;

	/* Special sound for mixing in microphone from Flash */
	FWSound *micSound;

	/* Special sound channel for mixing dynamic microphone-like sound, for example from NetStream etc. */
	FWSound *dynamicSound;

	/* Wait for microphone until we can mix the rest? */
	bool waitForMic;

public:

	static const int audioBufferLength = 16384;

	static const int audioBufferShortsLength = 8192;
	static unsigned char *audioBuffer;
	static short *audioBufferShorts;
	
	float volume;

	/* Constructor */
	FWSoundMixer();

	/* The audio step mixes chunks of playing sounds */
	void audioStep();

	/* Convert to shorts */
	void convertToShorts();

	/* Destructor */
	~FWSoundMixer();

	/* Start playing a given sound */
	void playSound(string name);

	/* Stop playing a given sound */
	void stopSound(string name);

	/* Find sound by name */
	FWSound *getSound(string name);

	/* Get audio buffer, but in shorts (optimization for Android to avoid doing this in Java) */		
    
	/* Stop all playing sounds */
	void stopAll();

	/* Add raw sound from Flash if needed */
	void addSound(FWSound *sound);

	/* Mix part of a sound into the output buffer */
	bool mix (FWSound *sound, unsigned long nToRead, unsigned long nOutputIndex);

	/* Save dynamic samples from microphone or another source */
	void recordDynamic(size_t size, unsigned char* buffer, string name = "_mic_");
    
	void doMix(float *d, float s);


};

#endif
