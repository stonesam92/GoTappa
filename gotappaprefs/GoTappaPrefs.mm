#import <Preferences/Preferences.h>

@interface GoTappaPrefsListController: PSListController {
}
@end

@implementation GoTappaPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"GoTappaPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)showTwitter {
    NSURL *url;
    url = [NSURL URLWithString:@"twitter://user?screen_name=cmdshiftn"];
    [[UIApplication sharedApplication] openURL:url];

    //twitter.app not installed
    url = [NSURL URLWithString:@"http://twitter.com/cmdshiftn"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)showLicense {
    NSURL *url = [NSURL URLWithString:@"http://github.com/stonesam92/blob/master/LICENSE.md"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)showGitHub {
    NSURL *url = [NSURL URLWithString:@"http://github.com/stonesam92/GoTappa"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)respring {
    system("killall -HUP SpringBoard");
}
@end

// vim:ft=objc
