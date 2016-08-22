FLASCC:=X
AS3COMPILER:=asc2.jar

$?UNAME=$(shell uname -s)
ifneq (,$(findstring CYGWIN,$(UNAME)))
	$?nativepath=$(shell cygpath -at mixed $(1))
	$?unixpath=$(shell cygpath -at unix $(1))
else
	$?nativepath=$(abspath $(1))
	$?unixpath=$(abspath $(1))
endif

$?AS3COMPILERARGS=java $(JVMARGS) -jar -Xmx1024M $(call nativepath,$(FLASCC)/usr/lib/$(AS3COMPILER)) -merge -md 

all:
	@if [ -d $(FLASCC)/usr/bin ] ; then true ; \
	else echo "Couldn't locate FLASCC sdk directory, please invoke make with \"make FLASCC=/path/to/FLASCC/sdk ...\"" ; exit 1 ; \
	fi
	"$(FLASCC)/usr/bin/g++" -O4 ../common/FWSound.cpp ../common/FWSoundMixer.cpp FW_wrapper.cpp -symbol-class=:0:com.fw_SoundMixer::Console Console.abc -emit-swc=com.rainbowcreatures.FWSoundMixer -swf-version=18 -o FWSoundMixer.swc

console:
	$(AS3COMPILERARGS)	-import $(call nativepath,$(FLASCC)/usr/lib/builtin.abc) \
				-import $(call nativepath,$(FLASCC)/usr/lib/playerglobal.abc) \
				-import $(call nativepath,$(FLASCC)/usr/lib/BinaryData.abc) \
				-import $(call nativepath,$(FLASCC)/usr/lib/ISpecialFile.abc) \
				-import $(call nativepath,$(FLASCC)/usr/lib/IBackingStore.abc) \
				-import $(call nativepath,$(FLASCC)/usr/lib/IVFS.abc) \
				-import $(call nativepath,$(FLASCC)/usr/lib/InMemoryBackingStore.abc) \
				-import $(call nativepath,$(FLASCC)/usr/lib/PlayerKernel.abc) \
				Console.as -outdir . -out Console
