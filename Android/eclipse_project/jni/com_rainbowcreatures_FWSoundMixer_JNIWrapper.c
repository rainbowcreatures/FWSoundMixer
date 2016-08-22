#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <sstream>

#include "com_rainbowcreatures_FWSoundMixer_JNIWrapper.h"
#include "FWSoundMixer.h"
#include "FWSound.h"
#include "FW_exception.h"

#include <android/log.h>

#define  LOG_TAG    "LOG_TAG"

#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

using namespace std;

FWSoundMixer *mixerInstance = NULL;

// are we natively recording microphone?
uint32_t recordMicrophone = 0;


void ThrowExceptionByClassName(JNIEnv *env, const char *name, const char *message)
{
	jclass myclass = env->FindClass(name);
	if (myclass != NULL)
	{
		env->ThrowNew(myclass, message);
	}
	env->DeleteLocalRef(myclass);
}

JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1add
  (JNIEnv *env, jobject obj, jbyteArray ba, jstring name, jint play, jint start, jint loops) {

	try {

	uint32_t len = 0;
	uint32_t sca_play = 0;
	int32_t sca_start = 0;
	int32_t sca_loops = 0;
    
#ifdef DEBUG
	LOGD("Setting sound name");
#endif

	// get the sound name
	const char *sca_name = env->GetStringUTFChars(name, 0);
    
#ifdef DEBUG
	LOGD("Getting rest of params");
#endif
	sca_play = play;
	sca_start = start;
	sca_loops = loops;
    
	if (mixerInstance == NULL) {
		throw MyException("SoundMixer wasn't initialized, do that before adding sounds!");    
	}

	sca_loops--;

	if (sca_start < 0) sca_start = 0;
	if (sca_loops < 0) sca_loops = 0;
    
	std::stringstream sstream_name;
	sstream_name << sca_name;
	std::string string_name = sstream_name.str();

#ifdef DEBUG
	LOGD("Does sound exist?");
#endif

	FWSound *sound = mixerInstance->getSound(string_name);
    
	if (sound == NULL) {
		LOGD("No, adding");
		LOGD("Reading sound ByteArray");

		// get the sound bytes (sound was extracted earlier in the extension AS3 wrapper)
		jbyte *bb = env->GetByteArrayElements(ba, 0);
		jsize length = env->GetArrayLength(ba);
		unsigned char *data = (unsigned char*) malloc(length);
		memcpy(data, bb, length);

		FWSound *sound = new FWSound(string_name, data, length);
		mixerInstance->addSound(sound);

		env->ReleaseByteArrayElements(ba, bb, JNI_ABORT);
		if (sca_play) sound->play(sca_start, sca_loops);
	} else {
#ifdef DEBUG
		LOGD("Yes, just play if needed");
#endif
		if (sca_play) sound->play(sca_start, sca_loops);
	}

	env->ReleaseStringUTFChars(name, sca_name);

	}
	catch (MyException& e) {
		ThrowExceptionByClassName(env, "java/lang/Exception", e.what());
	}

}

JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1init
  (JNIEnv *env, jobject obj) {
	try {
		mixerInstance = new FWSoundMixer();
	} catch (MyException& e) {
		ThrowExceptionByClassName(env, "java/lang/Exception", e.what());
	}

}

JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1audioStep
  (JNIEnv *env, jobject obj, jbyteArray ba) {

	try {

	// do a bit of mixing...
	mixerInstance->audioStep();

	jboolean isCopy;
	jbyte *bb = env->GetByteArrayElements(ba, &isCopy);
	jsize size = env->GetArrayLength(ba);

		// check that the target ByteArray is large enough
		if (size > FWSoundMixer::audioBufferLength) {
			throw MyException("The return audio buffer ByteArray is not large enough!");
		}
		// check if the target ByteArray is not large enough
		if (size < FWSoundMixer::audioBufferLength) {
			throw MyException("The return audio buffer ByteArray is too small!");
		}
		memcpy((char*) bb, FWSoundMixer::audioBuffer, FWSoundMixer::audioBufferLength);

	env->ReleaseByteArrayElements(ba, bb, 0);

	} catch (MyException& e) {
		ThrowExceptionByClassName(env, "java/lang/Exception", e.what());
	}

}


JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1getShorts
  (JNIEnv *env, jobject obj, jbyteArray ba) {

	try {

	jboolean isCopy;
	jbyte *bb = env->GetByteArrayElements(ba, &isCopy);
	jsize size = env->GetArrayLength(ba);

	mixerInstance->convertToShorts();

		// check that the target ByteArray is large enough
		if (size > FWSoundMixer::audioBufferShortsLength) {
			throw MyException("The return audio buffer ByteArray is not large enough!");
		}
		// check if the target ByteArray is not large enough
		if (size < FWSoundMixer::audioBufferShortsLength) {
			throw MyException("The return audio buffer ByteArray is too small!");
		}
		memcpy((char*) bb, FWSoundMixer::audioBufferShorts, FWSoundMixer::audioBufferShortsLength);

	env->ReleaseByteArrayElements(ba, bb, 0);

	} catch (MyException& e) {
		ThrowExceptionByClassName(env, "java/lang/Exception", e.what());
	}

}


JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1recordMic
  (JNIEnv *env, jobject obj, jbyteArray ba) {
	try {
		jboolean isCopy;
		jbyte *bb = env->GetByteArrayElements(ba, &isCopy);
		jsize size = env->GetArrayLength(ba);
		unsigned char *data = (unsigned char*) malloc(size);
		memcpy(data, bb, size);
		mixerInstance->recordDynamic(size, data, "_mic_");		
	} catch (MyException& e) {
		ThrowExceptionByClassName(env, "java/lang/Exception", e.what());
	}
}

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_recordDynamic
 * Signature: ([B)V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1recordDynamic
  (JNIEnv *env, jobject obj, jbyteArray ba) {
	try {
		jboolean isCopy;
		jbyte *bb = env->GetByteArrayElements(ba, &isCopy);
		jsize size = env->GetArrayLength(ba);
		unsigned char *data = (unsigned char*) malloc(size);
		memcpy(data, bb, size);
		mixerInstance->recordDynamic(size, data, "_dynamic_");		
	} catch (MyException& e) {
		ThrowExceptionByClassName(env, "java/lang/Exception", e.what());
	}
}

JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1dispose
  (JNIEnv *env, jobject obj) {
	if (mixerInstance != NULL) delete(mixerInstance);
	mixerInstance = NULL;
}

JNIEXPORT jboolean JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1soundExists
  (JNIEnv *env, jobject obj, jstring name) {

	try {

	uint32_t len = 0;
    
	// get the sound name
	const char *sca_name = env->GetStringUTFChars(name, 0);

	std::stringstream sstream_name;
	sstream_name << sca_name;
	std::string string_name = sstream_name.str();
    
	FWSound *sound = mixerInstance->getSound(string_name);

	env->ReleaseStringUTFChars(name, sca_name);
    
	if (sound == NULL) {
		return false;
	} else {
		return true;
	}

	} catch (MyException& e) {
		ThrowExceptionByClassName(env, "java/lang/Exception", e.what());
	}

}

JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1stopAll
  (JNIEnv *env, jobject obj) {
	mixerInstance->stopAll();
}
