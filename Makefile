TARGET = iphone:clang::11.0
ARCHS = arm64 arm64e

THEOS_OBJ_DIR_NAME = obj-app
# Required to avoid errors with the directory being named "MK1" and the cli tool being named "mk1"

INSTALL_TARGET_PROCESSES = MK1

ifeq ($(JAILED),1)
PACKAGE_FORMAT = ipa
endif

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = MK1
MK1_LIBRARIES = rocketbootstrap
MK1_PRIVATE_FRAMEWORKS = AppSupport

ifeq ($(JAILED),1)
TARGET_CODESIGN =
else
MK1_CODESIGN_FLAGS = -SMK1/MK1.entitlements
DEFINES += JB
endif

MK1_XCODEFLAGS += DEF_CFLAGS="$(foreach def,$(DEFINES),-D$(def)=1)"
# MK1_XCODEFLAGS += DEF_SWIFT_FLAGS="$(foreach def,$(DEFINES),-D$(def))"

include $(THEOS_MAKE_PATH)/xcodeproj.mk
