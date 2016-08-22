/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <sstream>
#include "FWSoundMixer.h"
#include "FWSound.h"

#include "ANEWrapper.h"
#include "FW_exception.h"

#include "AVFoundation/AVFoundation.h"

// Mixer class instance

FWSoundMixer *mixerInstance = NULL;

// are we natively recording microphone?
uint32_t recordMicrophone = 1;
AVAudioRecorder *recorder;
NSError *error = nil;
AVAudioSession *session = nil;

// this logs error to device and also throws error into AIR
// logs description and failure reason
void throwError(NSString *text, NSError *error) {
    NSString *finalText;
    if (error != NULL) {
        finalText = [NSString stringWithFormat:@"%@: %@ (%@)", text, [error localizedDescription], [error localizedFailureReason]];
    } else {
        finalText = [NSString stringWithFormat:@"%@:", text];
    }
    NSLog(@"[FlashyWrappers error] %@", finalText);
    throw MyException(std::string([finalText UTF8String]));
}

void FWSMANEContextInitializer(void *extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions) {
    NSLog(@"Entering ContextInitializer()");
    *numFunctions = 11;
    FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction)*(*numFunctions));  
    
    func[0].name = (const uint8_t*)"FWSoundMixer_add";  
    func[0].functionData = NULL;  
    func[0].function = &FWSoundMixer_add;  
    
    func[1].name = (const uint8_t*)"FWSoundMixer_init";  
    func[1].functionData = NULL;  
    func[1].function = &FWSoundMixer_init;  
    
    func[2].name = (const uint8_t*)"FWSoundMixer_audioStep";  
    func[2].functionData = NULL;  
    func[2].function = &FWSoundMixer_audioStep;  
    
    func[3].name = (const uint8_t*)"FWSoundMixer_recordMic";  
    func[3].functionData = NULL;  
    func[3].function = &FWSoundMixer_recordMic;  
    
    func[4].name = (const uint8_t*)"FWSoundMixer_dispose";
    func[4].functionData = NULL;  
    func[4].function = &FWSoundMixer_dispose;  
    
    func[5].name = (const uint8_t*)"FWSoundMixer_soundExists";  
    func[5].functionData = NULL;  
    func[5].function = &FWSoundMixer_soundExists;  
    
    func[6].name = (const uint8_t*)"FWSoundMixer_stopAll";  
    func[6].functionData = NULL;  
    func[6].function = &FWSoundMixer_stopAll;  
    
    func[7].name = (const uint8_t*)"FWSoundMixer_initMicrophone";  
    func[7].functionData = NULL;  
    func[7].function = &FWSoundMixer_initMicrophone;
    
    func[8].name = (const uint8_t*)"FWSoundMixer_recordMicrophoneStart";  
    func[8].functionData = NULL;  
    func[8].function = &FWSoundMixer_recordMicrophoneStart;
    
    func[9].name = (const uint8_t*)"FWSoundMixer_recordMicrophoneStop";  
    func[9].functionData = NULL;  
    func[9].function = &FWSoundMixer_recordMicrophoneStop; 
    
    func[10].name = (const uint8_t*)"FWSoundMixer_recordMicrophonePause";
    func[10].functionData = NULL;
    func[10].function = &FWSoundMixer_recordMicrophonePause;
    
    *functions = func;  
    
    NSLog(@"FWSoundMixer 1.0 ANE build 3");
    NSLog(@"Exiting ContextInitializer()");
}

// initialize native recording of microphone
void initMicrophone() {
        NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"Mic.m4a", nil];
        NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        session = [AVAudioSession sharedInstance];
        
        if (error) {
            throwError(@"Microphone recording session failed to initialize at setCategory", error);
        }
        AudioChannelLayout channelLayout;
        memset(&channelLayout, 0, sizeof(AudioChannelLayout));
        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
        
        // recorder settings
        NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                        [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                        [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                        
                                        //  [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                        // [NSNumber numberWithInt:128000], AVEncoderBitRateKey,
                                        nil];
        
        
        // init recorder
        recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSettings error:&error];
        if (error) {
            throwError(@"Microphone recording session failed to initialize at init", error);
        }
        /*[session setActive:NO error:&error];
        if (error) {
            throwError(@"Microphone recording session failed to initialize at init", error);
        }*/
        [recorder prepareToRecord];
        
        BOOL audioHWAvailable = session.inputIsAvailable;
        if (!audioHWAvailable) {
            throwError(@"Audio input not available", NULL);
        }
        
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        /*[session setActive:YES error:&error];
        if (error) {
            throwError(@"Microphone recording session failed to initialize at init", error);
        }*/
        [recorder retain];
}

// start native microphone recording
void recordMicrophoneStart() {
        BOOL temp = [recorder record];
        if (temp) {
            NSLog(@"Record TRUE");           
        } else {
            NSLog(@"Record FALSE");
        }
}

// pause microphone recordin
void recordMicrophonePause() {
    [recorder pause];
}

// finish native microphone recording
void recordMicrophoneStop() {
    [recorder stop];
    [recorder release];
}

void FWSMANEContextFinalizer(FREContext ctx) {
    NSLog(@"Entering ContextFinalizer()");
    NSLog(@"Exiting ContextFinalizer()");
    return;
}

void FWSMANEInitializer(void **extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
    NSLog(@"Entering ExtInitializer()");
    *extDataToSet = NULL;
    *ctxInitializerToSet = &FWSMANEContextInitializer;
    *ctxFinalizerToSet = &FWSMANEContextFinalizer;    
    NSLog(@"Exiting ExtInitializer()");
}

void FWSMANEFinalizer(void *extData) {
    NSLog(@"Entering ExtFinalizer()");
    NSLog(@"Exiting ExtFinalizer()");
    return;
}



// upload sound to sound mixer
FREObject FWSoundMixer_add(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {

    const uint8_t *name = NULL;
    uint32_t len = 0;
    uint32_t sca_play = 0;
    int32_t sca_start = 0;
    int32_t sca_loops = 0;
    
#ifdef DEBUG
    NSLog(@"Setting sound name");
#endif
    // get the sound name
    // TOOD: This and similar methods in FW easily lead to buffer overflow when string of 500+ chars is passed
    FREGetObjectAsUTF8(argv[1], &len, &name);
    char sca_name[500];
    memcpy(sca_name, name, len);
    sca_name[len] = 0;
    
#ifdef DEBUG
    NSLog(@"Getting rest of params");
#endif
    FREGetObjectAsUint32(argv[2], &sca_play);
    FREGetObjectAsInt32(argv[3], &sca_start);
    FREGetObjectAsInt32(argv[4], &sca_loops);
    
	if (mixerInstance == NULL) {
        throw MyException("SoundMixer wasn't initialized, do that before adding sounds!");    
		return NULL;
	}

    // TODO, throw the stuff below into common .cpp code (FWSoundMixer.cpp)
    // TODO, define LOG (NSLog on platform, fprintf for FlasCC)

	sca_loops--;

	if (sca_start < 0) sca_start = 0;
	if (sca_loops < 0) sca_loops = 0;
    
	std::stringstream sstream_name;
    sstream_name << sca_name;
	std::string string_name = sstream_name.str();
#ifdef DEBUG
    NSLog(@"Does sound exist?");
#endif
	FWSound *sound = mixerInstance->getSound(string_name);
    
	if (sound == NULL) {
        NSLog(@"No, adding");
        NSLog(@"Reading sound ByteArray");
        // get the sound bytes (sound was extracted earlier in the extension AS3 wrapper)
        FREByteArray bytes;
        FREAcquireByteArray(argv[0], &bytes);
        unsigned char *data = (unsigned char*)malloc(bytes.length * sizeof(unsigned char));
        uint32_t length = bytes.length;
        memcpy(data, bytes.bytes, bytes.length);
        FREReleaseByteArray(argv[0]);
		FWSound *sound = new FWSound(string_name, data, length);
		mixerInstance->addSound(sound);
		if (sca_play) sound->play(sca_start, sca_loops);
	} else {
#ifdef DEBUG
        NSLog(@"Yes, just play if needed");
#endif
		if (sca_play) sound->play(sca_start, sca_loops);
	}
    return NULL;
}

// return if sound exists, so we dont have to extract it repeatedly in AS3
FREObject FWSoundMixer_soundExists(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    const uint8_t *name = NULL;
    uint32_t len = 0;
    
    // TOOD: This and similar methods in FW easily lead to buffer overflow when string of 500+ chars is passed
    FREGetObjectAsUTF8(argv[0], &len, &name);
    char sca_name[500];
    memcpy(sca_name, name, len);
    sca_name[len] = 0;

    std::stringstream sstream_name;
    sstream_name << sca_name;
	std::string string_name = sstream_name.str();
    
    FWSound *sound = mixerInstance->getSound(string_name);
    
    FREObject asResult;
	if (sound == NULL) {
        FRENewObjectFromUint32(0, &asResult);
    } else {
        FRENewObjectFromUint32(1, &asResult);
    }
    return asResult;
}

FREObject FWSoundMixer_initMicrophone(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    initMicrophone();
    return NULL;
}

FREObject FWSoundMixer_recordMicrophoneStart(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    recordMicrophoneStart();
    return NULL;
}

FREObject FWSoundMixer_recordMicrophoneStop(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    recordMicrophoneStop();
    return NULL;
}


FREObject FWSoundMixer_recordMicrophonePause(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    recordMicrophonePause();
    return NULL;
}

// stop all sounds
FREObject FWSoundMixer_stopAll(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    mixerInstance->stopAll();
    return NULL;
}

// init the soundMixer
FREObject FWSoundMixer_init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	mixerInstance = new FWSoundMixer();
    return NULL;
}

// delete the soundMixer
FREObject FWSoundMixer_dispose(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	if (mixerInstance != NULL) delete(mixerInstance);
    mixerInstance = NULL;
    return NULL;
}

// do audio step, then copy the internal audio buffer to the supplied ByteArray (lets hope this is fast enough...should be)
FREObject FWSoundMixer_audioStep(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    // do a bit of mixing...
	mixerInstance->audioStep();
    FREByteArray byteArray;
	FREAcquireByteArray(argv[0], &byteArray);
    // check that the target ByteArray is large enough
    if (byteArray.length > FWSoundMixer::audioBufferLength) {
        throw MyException("The return audio buffer ByteArray is not large enough!");
        return NULL;
    }
    // copy the content of the internal audiobuffer to ByteArray
    memcpy(byteArray.bytes, FWSoundMixer::audioBuffer, FWSoundMixer::audioBufferLength);
	FREReleaseByteArray(argv[0]);
    return NULL;
}

// record microphone data, this goes into the special mono _mic_ sound
FREObject FWSoundMixer_recordMic(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    FREByteArray bytes;
    FREAcquireByteArray(argv[0], &bytes);
    unsigned char *data = (unsigned char*)malloc(bytes.length * sizeof(unsigned char));
    uint32_t length = bytes.length;
    memcpy(data, bytes.bytes, bytes.length);
    FREReleaseByteArray(argv[0]);
    mixerInstance->recordDynamic(length, data, "_mic_");
    return NULL;
}

// record dynamic stereo sound, this goes into the special stereo _dynamic_ sound
FREObject FWSoundMixer_recordDynamic(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    FREByteArray bytes;
    FREAcquireByteArray(argv[0], &bytes);
    unsigned char *data = (unsigned char*)malloc(bytes.length * sizeof(unsigned char));
    uint32_t length = bytes.length;
    memcpy(data, bytes.bytes, bytes.length);
    FREReleaseByteArray(argv[0]);
    mixerInstance->recordDynamic(length, data, "_dynamic_");
    return NULL;
}
