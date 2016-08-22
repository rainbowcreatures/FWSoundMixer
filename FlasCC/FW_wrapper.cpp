/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 * FlasCC / Crossbridge SWC wrapper.
 *
 */

#include <AS3/AS3.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <sstream>
#include "../common/FWSoundMixer.h"
#include "../common/FWSound.h"

FWSoundMixer* mixerInstance = NULL;

void FWSoundMixer_add() __attribute__((used,
          annotate("as3sig:public function FWSoundMixer_add(sound:Sound, name:String, play:Boolean, start:Number, loops:Number):void"),
          annotate("as3import:flash.media.Sound"),
          annotate("as3package:com.rainbowcreatures.FWSoundMixer")));
void FWSoundMixer_add() {
	inline_as3( 
		"var namePtr:int = CModule.mallocString(name);"
	);

	if (mixerInstance == NULL) {
		fprintf(stderr, "SoundMixer wasn't initialized yet!");
		return;
	}

	unsigned char* sca_name;
	bool sca_play = false;
	long sca_start = 0;
	long sca_loops = 0;

	AS3_GetScalarFromVar(sca_name, namePtr);	
	AS3_GetScalarFromVar(sca_play, play);
	AS3_GetScalarFromVar(sca_start, start);
	AS3_GetScalarFromVar(sca_loops, loops);

	sca_loops--;
	if (sca_start < 0) sca_start = 0;
	if (sca_loops < 0) sca_loops = 0;

	std::stringstream sstream_name;
        sstream_name << sca_name;
	std::string string_name = sstream_name.str();

	FWSound *sound = mixerInstance->getSound(string_name);

	if (sound == NULL) {
		// 4 = bytes per sample, 2 = two channels!
		inline_as3(
			"var length:Number = Math.round((sound.length / 1000) * 44100 * 4 * 2);\n"
	 		"var dataPtr:int = CModule.malloc(length);\n"
			"CModule.ram.position = dataPtr;\n"
			"sound.extract(CModule.ram, int.MAX_VALUE);\n"
		);
		unsigned char* sca_data = 0;
		size_t sca_data_size = 0;
		AS3_GetScalarFromVar(sca_data, dataPtr);
		AS3_GetScalarFromVar(sca_data_size, length);
		FWSound *sound = new FWSound(string_name, sca_data, sca_data_size);
		fprintf(stderr, "Sound of length %lu name %s extracted", sca_data_size, sca_name);
		mixerInstance->addSound(sound);
		if (sca_play) sound->play(sca_start, sca_loops);
	} else {
		if (sca_play) sound->play(sca_start, sca_loops);
	}
	free(sca_name);
}

void FWSoundMixer_init() __attribute__((used,
          annotate("as3sig:public function FWSoundMixer_init():void"),
          annotate("as3package:com.rainbowcreatures.FWSoundMixer")));
void FWSoundMixer_init() {
	mixerInstance = new FWSoundMixer();
}

void FWSoundMixer_audioStep() __attribute__((used,
          annotate("as3sig:public function FWSoundMixer_audioStep():void"),
          annotate("as3package:com.rainbowcreatures.FWSoundMixer")));
void FWSoundMixer_audioStep() {
	mixerInstance->audioStep();
}

void FWSoundMixer_stopAll() __attribute__((used,
          annotate("as3sig:public function FWSoundMixer_stopAll():void"),
          annotate("as3package:com.rainbowcreatures.FWSoundMixer")));
void FWSoundMixer_stopAll() {
	mixerInstance->stopAll();
}

void FWSoundMixer_recordMic() __attribute__((used,
          annotate("as3sig:public function FWSoundMixer_recordMic(data:ByteArray):void"),
          annotate("as3import:flash.utils.ByteArray"),
          annotate("as3package:com.rainbowcreatures.FWSoundMixer")));
void FWSoundMixer_recordMic() {
	size_t sca_size = 0;
	unsigned char *sca_buffer = NULL;
 	inline_as3(
 		"var dataPtr:int = CModule.malloc(data.length);\n"
 		"CModule.writeBytes(dataPtr, data.length, data);\n"
 		"var dataSize:int = data.length;\n"            
 		: :
 	);
	AS3_GetScalarFromVar(sca_size, dataSize);	
	AS3_GetScalarFromVar(sca_buffer, dataPtr);
	mixerInstance->recordDynamic(sca_size, sca_buffer, "_mic_");
}

void FWSoundMixer_recordDynamic() __attribute__((used,
          annotate("as3sig:public function FWSoundMixer_recordDynamic(data:ByteArray):void"),
          annotate("as3import:flash.utils.ByteArray"),
          annotate("as3package:com.rainbowcreatures.FWSoundMixer")));
void FWSoundMixer_recordDynamic() {
	size_t sca_size = 0;
	unsigned char *sca_buffer = NULL;
 	inline_as3(
 		"var dataPtr:int = CModule.malloc(data.length);\n"
 		"CModule.writeBytes(dataPtr, data.length, data);\n"
 		"var dataSize:int = data.length;\n"            
 		: :
 	);
	AS3_GetScalarFromVar(sca_size, dataSize);	
	AS3_GetScalarFromVar(sca_buffer, dataPtr);
	mixerInstance->recordDynamic(sca_size, sca_buffer, "_dynamic");
}

int main()
{
    AS3_GoAsync();
}
