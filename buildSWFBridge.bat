CALL config.bat
CALL %FLEX_PATH%amxmlc -swf-version=31 -debug=false -static-link-runtime-shared-libraries -library-path=./FlasCC/FWSoundMixer.swc -library-path=%FLEX_PATH% ./FlasCC/SWFBridge/SWFBridge/Encoder.as -o ./FlasCC/SWFBridge/SWFBridge/FWSoundMixer_SWFBridge.swf
CALL %FLEX_PATH%@compc -swf-version=31 -target-player=20 -static-link-runtime-shared-libraries -library-path=%FLEX_PATH% -include-sources FlasCC/SWFBridge/com/rainbowcreatures/swf/FWSoundMixer.as FlasCC/com/rainbowcreatures/FWSound.as -output ./FlasCC/SWFBridge/FWSoundMixer_swf.swc
