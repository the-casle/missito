TARGET = iphone:latest:10.0
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Missito
$(APPLICATION_NAME)_FILES = $(wildcard source/*.m External/SVProgressHUD/*.m)
$(APPLICATION_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(APPLICATION_NAME)_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/source


include $(THEOS_MAKE_PATH)/application.mk


ifeq ($(FINALPACKAGE),1)
after-install::
	install.exec "killall \"Missito\" && uicache " || true
else
after-install::
	install.exec "killall \"Missito\"" || true
endif
