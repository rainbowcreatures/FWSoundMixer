CALL config.bat
CALL %FLEX_PATH%compc -swf-version=31 -target-player=20 -static-link-runtime-shared-libraries -library-path=%FLEX_PATH% -include-sources FlasCC/com/rainbowcreatures/ -source-path=FlasCC/ -library-path=./FlasCC/FWSoundMixer.swc -output ./FlasCC/FWSoundMixer.swc
CALL buildSWFBridge.bat