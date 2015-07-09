include theos/makefiles/common.mk

BUNDLE_NAME = GoTappaPrefs
GoTappaPrefs_FILES = GoTappaPrefs.mm
GoTappaPrefs_INSTALL_PATH = /Library/PreferenceBundles
GoTappaPrefs_FRAMEWORKS = UIKit
GoTappaPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/GoTappaPrefs.plist$(ECHO_END)
