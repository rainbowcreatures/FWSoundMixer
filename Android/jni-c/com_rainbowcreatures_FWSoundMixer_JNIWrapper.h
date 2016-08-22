/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_rainbowcreatures_FWSoundMixer_JNIWrapper */

#ifndef _Included_com_rainbowcreatures_FWSoundMixer_JNIWrapper
#define _Included_com_rainbowcreatures_FWSoundMixer_JNIWrapper
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_add
 * Signature: ([BLjava/lang/String;III)V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1add
  (JNIEnv *, jobject, jbyteArray, jstring, jint, jint, jint);

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_init
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1init
  (JNIEnv *, jobject);

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_audioStep
 * Signature: ([B)V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1audioStep
  (JNIEnv *, jobject, jbyteArray);

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_getShorts
 * Signature: ([B)V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1getShorts
  (JNIEnv *, jobject, jbyteArray);

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_recordMic
 * Signature: ([B)V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1recordMic
  (JNIEnv *, jobject, jbyteArray);

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_recordDynamic
 * Signature: ([B)V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1recordDynamic
  (JNIEnv *, jobject, jbyteArray);

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_dispose
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1dispose
  (JNIEnv *, jobject);

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_soundExists
 * Signature: (Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1soundExists
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_rainbowcreatures_FWSoundMixer_JNIWrapper
 * Method:    FWSoundMixer_stopAll
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_rainbowcreatures_FWSoundMixer_1JNIWrapper_FWSoundMixer_1stopAll
  (JNIEnv *, jobject);

#ifdef __cplusplus
}
#endif
#endif