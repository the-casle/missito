TARGET = iphone:clang:11.2:10.0
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Missito
Missito_FILES = $(wildcard source/*.m External/*/*.m)
Missito_FRAMEWORKS = UIKit CoreGraphics
Missito_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/source
Missito_CODESIGN_FLAGS = -Sent.xml


include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"SpringBoard\" && uicache " || true
SUBPROJECTS += misuserdefaultsmanager
include $(THEOS_MAKE_PATH)/aggregate.mk
