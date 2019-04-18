TARGET = iphone:latest:10.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Missito
Missito_FILES = main.m MISAppDelegate.m MISRootViewController.m
Missito_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"Missito\" && uicache" || true
