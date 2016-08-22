/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#include "FWSound.h"

FWSound::FWSound(string name, unsigned char *soundData, size_t length, uint8_t _channels) {
	this->soundData = soundData;
	this->soundDataIndex = 0;
	this->name = name;
	this->playing = false;
	this->soundDataSize = length;
	this->loops = 0;
	this->channels = _channels;
	this->mixed = false;
}

FWSound::~FWSound() {
	if (this->soundData != NULL) free(this->soundData);
	this->soundData = NULL;
}

void FWSound::play(long _start_ms, size_t _loops) {
	this->start_ms = _start_ms;
	this->loops = _loops;
	this->soundDataIndex = (size_t) (((float)_start_ms / (float)1000) * 44100 * 4 * 2);
	if (this->soundDataIndex >= this->soundDataSize) this->soundDataIndex = this->soundDataSize - 1;
 	this->playing = true;
#ifdef DEBUG
	fprintf(stderr, "Playing sound %s from %lu ms, bytes %lu, size %lu", this->name.c_str(), _start_ms, this->soundDataIndex, this->soundDataSize);
#endif
}

void FWSound::stop() {
 	this->playing = false;
//	if (name != "_mic_") {
		this->soundDataIndex = 0;
//	}
}