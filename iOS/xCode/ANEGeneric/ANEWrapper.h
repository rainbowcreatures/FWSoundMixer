/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#ifndef encoder_iOS_ANE_ANEWrapper_h
#define encoder_iOS_ANE_ANEWrapper_h

#import "FlashRuntimeExtensions.h"

extern "C" {
    
    __attribute__((visibility("default"))) void ExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);  
    
    __attribute__((visibility("default"))) void ExtFinalizer(void* extData);
    
    void FWSMANEContextFinalizer(FREContext ctx);
    
    void FWSMANEInitializer(void **extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
    
    void FWSMANEFinalizer(void *extData);
  
    FREObject FWSoundMixer_add(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]); 
    FREObject FWSoundMixer_init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);    
    FREObject FWSoundMixer_audioStep(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);    
    FREObject FWSoundMixer_recordMic(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]); 
    FREObject FWSoundMixer_recordDynamic(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]); 
    FREObject FWSoundMixer_dispose(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);    
    FREObject FWSoundMixer_soundExists(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);   
    FREObject FWSoundMixer_stopAll(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);   
    FREObject FWSoundMixer_initMicrophone(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);   
    FREObject FWSoundMixer_recordMicrophoneStart(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);   
    FREObject FWSoundMixer_recordMicrophoneStop(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
    FREObject FWSoundMixer_recordMicrophonePause(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
}
#endif
