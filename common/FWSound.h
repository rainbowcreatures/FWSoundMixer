/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#ifndef FW_SOUND_H
#define FW_SOUND_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <math.h>
#include <vector>

using namespace std;

class FWSound {

private:

	public:

	size_t soundDataSize;
	unsigned char *soundData;
	size_t soundDataIndex;
	string name;
	bool mixed;
	bool playing;
	size_t loops;
	long start_ms;
	uint8_t channels;

	/* Constructor */
	FWSound(string name, unsigned char *soundData, size_t length, uint8_t _channels = 2);

	void play(long _start_ms = 0, size_t _loops = 0);

	void stop();

	/* Destructor */
	~FWSound();

};

#endif
