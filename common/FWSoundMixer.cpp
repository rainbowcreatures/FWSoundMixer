/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#include "FWSoundMixer.h"

#define MAX_MIC_BUFFER_SIZE 1048576
#define MIX(d, s) {                           \
        float n = (float) (d) + (float) (s);        \
        if      (n >  1) (d) =  1;    \
        else if (n < -1) (d) = -1;    \
        else                 (d) = (float) n; \
}

/**
 * Mix part of this sound into the output audio buffer for FlasCC
 *
 * \param nToRead how many bytes do we want to mix
 * \param nOutputIndex the index in the output buffer - it will be usually 0 except when we are near the end of the sound and the sound is looping
 *
 * \return true for success, false for failure
 */ 

void FWSoundMixer::doMix(float *d, float s) {
                  
    float n = (float) *d + (float) s;        
    if      (n >  1) *d =  1;    
    else if (n < -1) *d = -1;    
    else                 *d = (float) n;

}

bool FWSoundMixer::mix (FWSound *sound, unsigned long nToRead, unsigned long nOutputIndex) {

	float *obuf = (float *) FWSoundMixer::audioBuffer;
	unsigned long i = 0;

	if (sound->soundDataIndex + nToRead > sound->soundDataSize) {
#ifdef DEBUG
			fprintf(stderr, "FWSoundMixer: Attemp to read more bytes (index:%d + size %d) for mixing than the length of the sound buffer (%d)", sound->soundDataIndex, nToRead, sound->soundDataSize);
#endif		
		return false;
	}

	unsigned long c = 0;
	unsigned long read = 0;

	if (sound->channels == 1) {

		for (i = 0; i < nToRead / 4; i++) {
			// mix in the volume of sound 
			float M = (float) ( this->volume * (float) (((float*)sound->soundData)[(sound->soundDataIndex / 4) + i] ));

			read += 4;

			// output it to output buffer with offset nOuputIndex
		        MIX(obuf[c + (nOutputIndex / 4)], M);
//			fprintf(stderr, "Mixing byte: %lu into %lu, output buffer index %lu, c is %lu, outputIndex is %lu", M, obuf[c + nOutputIndex], c + nOutputIndex, c, nOutputIndex);
//			fprintf(stderr, "c is %lu, outputIndex is %lu", c, nOutputIndex);

			c++;
		        MIX(obuf[c + (nOutputIndex / 4)], M);
//			fprintf(stderr, "Mixing byte: %lu into %lu, output buffer index %lu, c is %lu, outputIndex is %lu", M, obuf[c + nOutputIndex], c + nOutputIndex, c, nOutputIndex);
//			fprintf(stderr, "c is %lu, outputIndex is %lu", c, nOutputIndex);
			c++;                      
			
		}
	}           

	if (sound->channels == 2) {

		/* stereo (2-channel) sound, that's what we always get from Flash extract() method */
		for (i = 0; i < nToRead / 4; i += 2) {
			/* mix in the volume of sound */
			float L = (float) ( this->volume * (float) (((float*)sound->soundData)[(sound->soundDataIndex / 4) + i] ));
			float R = (float) ( this->volume * (float) (((float*)sound->soundData)[(sound->soundDataIndex / 4) + i + 1] ));

			read += 8;	

			/* output it to output buffer with offset nOuputIndex */
		        MIX(obuf[c + (nOutputIndex / 4)], L);
//			fprintf(stderr, "Mixing byte: %d into %d, output buffer index %lu", L, obuf[c + nOutputIndex], c + nOutputIndex);
			c++;	
		        //obuf[c + (nOutputIndex / 4)] = R;	
		        MIX(obuf[c + (nOutputIndex / 4)], R);
//			fprintf(stderr, "Mixing byte: %d into %d, output buffer index %lu", R, obuf[c + nOutputIndex], c + nOutputIndex);
			c++;                       
		}
	}
	
	/* TODO */

//	sound->soundDataIndex += nToRead;  // SUPER BUG <--- we're assuming nToRead, but never assume anything right. When we're reading mono 16k bytes and writing them into stereo output audio buffer, we can write only HALF(8k), because for each 1 byte from the mono  array we need to write 2 bytes into the stereo. So for 16k input we need to write 32k bytes. Into 16k stereo output we can fit only 8k. So in this case we assumed we wrote 16k bytes while we only wrote 8k. DOh.
	sound->soundDataIndex += read; // Instead, we need to look at the REAL bytes read and increase the soundDataIndex based on that.

	return true;
}

FWSoundMixer::FWSoundMixer() {
	this->volume = 1;
	this->micSound = new FWSound("_mic_", NULL, 0, 1);
	this->dynamicSound = new FWSound("_dynamic_", NULL, 0, 2);
	this->addSound(this->micSound);
	this->addSound(this->dynamicSound);
}

void FWSoundMixer::audioStep() {

   unsigned int length = FWSoundMixer::audioBufferLength;

   /* allocate audio output buffer if not done yet */
   if(FWSoundMixer::audioBuffer == NULL)
   {
       FWSoundMixer::audioBuffer = (unsigned char*)malloc(length);
   }

   /* zero it out */
   memset(FWSoundMixer::audioBuffer, 0, length);

   /* walk through all playing sounds */
   for (int a = 0; a < sounds.size(); a++) {
#ifdef DEBUG
       	fprintf(stderr, "FWSoundMixer: Getting sound at index %ld", a);
#endif
	FWSound *sound = sounds[a];
	if (sound->playing) {  
#ifdef DEBUG
		if (a == 0) fprintf(stderr,"FWSoundMixer: Mic is playing, index %d size %d...", sound->soundDataIndex, sound->soundDataSize);          	
#endif
		/* where we are in the output buffer for this sound */
		long outputIndex = 0;	

		/* did we reach the end of the buffer? */
                bool eof = false;
		long toRead = 0;

		if (sound->channels == 1) {
			/* how many bytes can we read in regards to audioBuffer yet */
			/* for mono, we only can read half of the audio buffer length...because for every byte read from mono channel we'll write 2 bytes into the output channel */
			/* so the maximum number of bytes to read from the mono is half the size of the stereo */
			toRead = length / 2;

			/* if we read that many bytes, do we go beyond end of sound buffer? if yes then shorten toRead and indicate eof */
			if ((sound->soundDataSize - sound->soundDataIndex) < toRead) {
				toRead = (sound->soundDataSize - sound->soundDataIndex);
				eof = true;
			}
		}
		if (sound->channels == 2) {                                                      
			/* how many bytes can we read in regards to audioBuffer yet */
			toRead = length;

			/* if we read that many bytes, do we go beyond end of sound buffer? if yes then shorten toRead and indicate eof */
			if ((sound->soundDataSize - sound->soundDataIndex) < toRead) {
				toRead = sound->soundDataSize - sound->soundDataIndex;
				eof = true;
			}
		}

//        	fprintf(stderr, "FWSoundMixer: Trying to mix sound(%s) %lu bytes, outputIndex is %ld, sound size is %ld, sound buffer index is %ld", sound->name.c_str(), toRead, outputIndex, sound->soundDataSize, sound->soundDataIndex);

		/* mix the sound into the output buffer, always start at 0 */				
		this->mix(sound, toRead, 0);

//        	fprintf(stderr, "FWSoundMixer: Done with mixing");

		/* update the input and output indexes */ 
                
		outputIndex += toRead;		

		/* if we are at the end, determine if to just loop the sound or stop playing entirely */
		if (eof) {
//			fprintf(stderr, "eof");
			/* rewind, do not rewind mic only */
			sound->soundDataIndex = 0;
		
			/* if it shouldn't loop, stop the playback */
			if (sound->loops <= 0) {
//				fprintf(stderr, "loops <= 0");
				/* the sound was fully mixed in */			
				sound->mixed = true;

//				fprintf(stderr, "Stopping sound!");
				sound->stop();
			} else {
//				fprintf(stderr, "loops--");
				/* start to play the beginning of the sound again if it loops and there is still space in the output buffer */
				sound->loops--;

				toRead = length - toRead;

				/* mix the start of the looping sound into the rest of output buffer */	
				this->mix(sound, toRead, outputIndex);
			}
		}				
	}
   }

}

void FWSoundMixer::playSound(string name) {
	FWSound *sound = this->getSound(name);
	if (sound != NULL) sound->play();
}

void FWSoundMixer::stopSound(string name) {
	FWSound *sound = this->getSound(name);
	if (sound != NULL) sound->stop();
}

FWSound *FWSoundMixer::getSound(string name) {
	for (int a = 0; a < sounds.size(); a++) {
		if (sounds[a]->name == name) {
			return sounds[a];
		}
	}
	return NULL;
}

void FWSoundMixer::stopAll() {
	for (int a = 0; a < sounds.size(); a++) {
        sounds[a]->stop();
	}    
}

FWSoundMixer::~FWSoundMixer() {
	if (FWSoundMixer::audioBuffer != NULL) {
		free(FWSoundMixer::audioBuffer);
	}
	// clear all sounds
	for (int a = 0; a < sounds.size(); a++) {
		free(sounds[a]);
	}
	sounds.clear();
}

void FWSoundMixer::recordDynamic(size_t size, unsigned char* buffer, string name) {
	FWSound *micSound = this->getSound(name);

	if (size > 0) {
		// if we mixed all of the last microphone samples, rewrite them with the new samples
		if (micSound->mixed) {
#ifdef DEBUG
			fprintf(stderr, "FWSoundMixer: Recording dynamic sound %s, adjusting buffer from %d to %d ", name.c_str(), micSound->soundDataSize, size);
#endif
			micSound->mixed = false;
			micSound->soundDataSize = size;
			micSound->soundData = (unsigned char*)realloc(micSound->soundData, size);
			memcpy(micSound->soundData, buffer, size);
		} else {
			// if we didn't manage to mix everything so far, add the new samples to the old samples so the mixer can finish with the old samples first
#ifdef DEBUG
			fprintf(stderr, "FWSoundMixer: Recording dynamic sound %s, enlarging buffer from %d to %d ", name.c_str(), micSound->soundDataSize, micSound->soundDataSize + size);
#endif
			micSound->soundData = (unsigned char*)realloc(micSound->soundData, micSound->soundDataSize + size);
			memcpy(micSound->soundData + micSound->soundDataSize, buffer, size);
			
			micSound->soundDataSize += size;

			// if the mic buffer is too large(default 1MB), cut the beginning. The mic buffer seem to grow unfortunately, because the mic is sending too much data and because silence is set to 0
			// we almost never get to finish playing the mic sound...so sometimes we have to free the already played sound

			if (micSound->soundDataSize > MAX_MIC_BUFFER_SIZE) {
				// salvage only the bit we didn't mix in yet
				unsigned int newSize = micSound->soundDataSize - micSound->soundDataIndex;
				unsigned char *temp = (unsigned char*)malloc(newSize);
				// copy that part into the newly created memory space
				memcpy(temp, micSound->soundData + micSound->soundDataIndex, newSize);
				// free the old(big) data
				free(micSound->soundData);
				// set the new sounddata from temp 
				micSound->soundData = temp;
				micSound->soundDataSize = newSize;
				micSound->soundDataIndex = 0;
			}			
		}
		// free the mic samples
		free(buffer);
		micSound->playing = true;	
	} else {
		micSound->playing = false;
	}
}

void FWSoundMixer::convertToShorts() {
	if (audioBufferShorts == NULL) {
		audioBufferShorts = (short*)malloc(audioBufferShortsLength);
	}
	float *data = (float*)audioBuffer;
	for (long a = 0; a < audioBufferLength / 4; a++) {
		audioBufferShorts[a] = (short)( data[a] * 32767 );
	}        
}

void FWSoundMixer::addSound(FWSound *sound) {
//	fprintf(stderr, "addSound");
	sounds.push_back(sound);
}

unsigned char *FWSoundMixer::audioBuffer = NULL;
short *FWSoundMixer::audioBufferShorts = NULL;
