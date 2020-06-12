THEOS_OBJ_DIR_NAME = obj-app # Required to avoid errors with the directory being named "MK1" and the cli tool being named "mk1"

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = MK1
MK1_FILES = $(wildcard MK1/*.m) $(wildcard MK1/*/*.m) $(wildcard MK1/*/*/*.m)
MK1_LIBRARIES = rocketbootstrap
MK1_PRIVATE_FRAMEWORKS = AppSupport
MK1_FRAMEWORKS = UIKit CoreGraphics
MK1_CODESIGN_FLAGS = -SMK1/MK1.entitlements
MK1_CFLAGS = -fobjc-arc -I./MK1 -I./MK1/Headers 
MK1_CFLAGS += -I./MK1/UI -I./MK1/UI/Editor -I./MK1/UI/Home -I./MK1/UI/Settings
MK1_CFLAGS += -I./MK1/Models
MK1_CFLAGS += -I./MK1/Syntax

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"MK1\"" || true
