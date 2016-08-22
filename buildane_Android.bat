CALL config.bat
CALL acompc -define=CONFIG::AIR,true -source-path="./iOS" -include-classes com.rainbowcreatures.FWSoundMixer com.rainbowcreatures.swf.Dummy  com.rainbowcreatures.FWSound -swf-version=31 -target-player=20 -define+=CONFIG::AIR,true -define+=CONFIG::FLASCC,false -output com.rainbowcreatures.FWSoundMixer.swc
rmdir Android-ARM /S /Q
mkdir Android-ARM

unzip -o -q com.rainbowcreatures.FWSoundMixer.swc -d tmp

copy tmp\library.swf Android-ARM
copy Android\FWSoundMixer.jar Android-ARM
mkdir Android-ARM\res
mkdir Android-ARM\libs
mkdir Android-ARM\libs\armeabi
copy Android\java\libs\armeabi\libcom_rainbowcreatures_FWSoundMixer_JNIWrapper.so Android-ARM\libs\armeabi
mkdir Android-ARM\libs\armeabi-v7a
copy Android\java\libs\armeabi-v7a\libcom_rainbowcreatures_FWSoundMixer_JNIWrapper.so Android-ARM\libs\armeabi-v7a


CALL %AIR_PATH%adt.bat -package -target ane Android/ane/FWSoundMixerANE.ane Android/extension.xml -swc com.rainbowcreatures.FWSoundMixer.swc -platform Android-ARM -C .\Android-ARM\ .

copy Android\ane\FWSoundMixerANE.ane ..\releases\%VERSION%\lib\AIR\Android

del tmp\*.* /Q
del tmp /Q
del *.swc