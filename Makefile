TARGET = iphone:latest:10.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Missito
$(APPLICATION_NAME)_FILES = $(wildcard source/*.m)
$(APPLICATION_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(APPLICATION_NAME)_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/source

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"Missito\"" || true


# install.exec "killall \"Missito\" && uicache " || true


