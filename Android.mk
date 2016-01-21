# Note that some host libraries have the same module name as the target
# libraries. This is currently needed to build, for example, adb. But it's
# probably something that should be changed.

LOCAL_PATH := $(call my-dir)

## libboringcrypto

# Target static library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libboringcrypto_static

LOCAL_EXPORT_C_INCLUDE_DIRS += $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/crypto-sources.mk
LOCAL_SDK_VERSION := 9
LOCAL_CFLAGS = -Wno-unused-parameter
# sha256-armv4.S does not compile with clang.
LOCAL_CLANG_ASFLAGS_arm += -no-integrated-as
ifeq ($(TARGET_ARCH),arm64)
ifeq ($(USE_CLANG_PLATFORM_BUILD),true)
LOCAL_ASFLAGS += -march=armv8-a+crypto
endif
endif
include $(LOCAL_PATH)/crypto-sources.mk
include $(BUILD_STATIC_LIBRARY)

# Target shared library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libboringcrypto
LOCAL_EXPORT_C_INCLUDE_DIRS += $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/crypto-sources.mk
LOCAL_CFLAGS += -fvisibility=hidden -DBORINGSSL_SHARED_LIBRARY -DBORINGSSL_IMPLEMENTATION -Wno-unused-parameter
LOCAL_SDK_VERSION := 9
# sha256-armv4.S does not compile with clang.
LOCAL_CLANG_ASFLAGS_arm += -no-integrated-as
ifeq ($(TARGET_ARCH),arm64)
ifeq ($(USE_CLANG_PLATFORM_BUILD),true)
LOCAL_ASFLAGS += -march=armv8-a+crypto
endif
endif
include $(LOCAL_PATH)/crypto-sources.mk
include $(BUILD_SHARED_LIBRARY)

# Target static tool
#include $(CLEAR_VARS)
#LOCAL_CFLAGS += -Wall -Werror -std=c++0x
#LOCAL_CPP_EXTENSION := cc
#LOCAL_MODULE := bssl
#LOCAL_MODULE_TAGS := optional
#LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/sources.mk
#LOCAL_CFLAGS = -Wno-unused-parameter
#LOCAL_SHARED_LIBRARIES=libboringcrypto libboringssl
#LOCAL_SHARED_LIBRARIES += libstlport
#include $(LOCAL_PATH)/sources.mk
#LOCAL_SRC_FILES = $(tool_sources)
#include $(BUILD_EXECUTABLE)


## libboringssl

# Target static library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libboringssl_static
LOCAL_EXPORT_C_INCLUDE_DIRS += $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/ssl-sources.mk
LOCAL_SDK_VERSION := 9
LOCAL_CFLAGS = -Wno-unused-parameter
include $(LOCAL_PATH)/ssl-sources.mk
include $(BUILD_STATIC_LIBRARY)

# Target shared library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libboringssl
LOCAL_EXPORT_C_INCLUDE_DIRS += $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/ssl-sources.mk
LOCAL_CFLAGS += -fvisibility=hidden -DBORINGSSL_SHARED_LIBRARY -DBORINGSSL_IMPLEMENTATION -Wno-unused-parameter
LOCAL_SHARED_LIBRARIES=libboringcrypto
LOCAL_SDK_VERSION := 9
include $(LOCAL_PATH)/ssl-sources.mk
include $(BUILD_SHARED_LIBRARY)

