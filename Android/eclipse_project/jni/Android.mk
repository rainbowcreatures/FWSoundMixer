# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := com_rainbowcreatures_FWSoundMixer_JNIWrapper
LOCAL_SRC_FILES := com_rainbowcreatures_FWSoundMixer_JNIWrapper.c $(LOCAL_PATH)/../../../../common/FW_exception.cpp $(LOCAL_PATH)/../../../../common/FWSound.cpp $(LOCAL_PATH)/../../../../common/FWSoundMixer.cpp

LOCAL_C_INCLUDES :=  $(LOCAL_PATH)/../../../

LOCAL_CFLAGS := -DANDROID -DDEBUG -x c++ -fexceptions
LOCAL_LDFLAGS    +=  -o libjniwrapper.so

#LOCAL_C_INCLUDES += ${ANDROID_NDK_ROOT}\sources\cxx-stl\stlport\stlport
#LOCAL_C_INCLUDES += $(NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/4.6/include
#LOCAL_C_INCLUDES += $(NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/4.6/libs/armeabi-v7a/include

LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -llog
LOCAL_LDLIBS += $(NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/4.6/libs/armeabi-v7a/libgnustl_static.a

#APP_ABI := ALL

include $(BUILD_SHARED_LIBRARY)
