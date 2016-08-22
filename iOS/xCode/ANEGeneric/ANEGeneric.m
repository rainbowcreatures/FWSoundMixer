/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#import "FlashRuntimeExtensions.h"

FREObject helloWorld(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSLog(@"Entering helloWorld()");
    NSString *helloString = @"Hello World!";
    const char *str = [helloString UTF8String];
    FREObject retStr;
    FRENewObjectFromUTF8(strlen(str) + 1, (const uint8_t*)str, &retStr);
    return retStr;
}

void LNGenericANEContextInitializer(void *extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
    NSLog(@"Entering ContextInitializer()");
    *numFunctionsToSet = 1;
    FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction) * 1);
    
    func[0].name = (const uint8_t*)"helloWorld";
    func[0].functionData = NULL;
    func[0].function = &helloWorld;
    
    *functionsToSet = func;
    
    NSLog(@"Exiting ContextInitializer()");
}

void LNGenericANEContextFinalizer(FREContext ctx) {
    NSLog(@"Entering ContextFinalizer()");
    NSLog(@"Exiting ContextFinalizer()");
    return;
}

void LNGenericANEInitializer(void **extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
    NSLog(@"Entering ExtInitializer()");
    *extDataToSet = NULL;
    *ctxInitializerToSet = &LNGenericANEContextInitializer;
    *ctxFinalizerToSet = &LNGenericANEContextFinalizer;    
    NSLog(@"Exiting ExtInitializer()");
}

void LNGenericANEFinalizer(void *extData) {
    NSLog(@"Entering ExtFinalizer()");
    NSLog(@"Exiting ExtFinalizer()");
    return;
}