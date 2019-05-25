export ARCHS = arm64 arm64e
export TARGET = iphone:clang:11.2:10.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MISUserDefaultsManager
MISUserDefaultsManager_FILES = $(wildcard *.m *.xm MHWDirectoryWatcher/*.m)
MISUserDefaultsManager_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
