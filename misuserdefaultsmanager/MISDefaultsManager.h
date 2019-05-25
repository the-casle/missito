#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"
#define PREFERNCE_LOADER_PATH @"Library/PreferenceLoader/Preferences"
#define PREFERNCE_BUNDLE_PATH @"Library/PreferenceBundles"

@interface MISDefaultsManager : NSObject
+(NSMutableArray *) infoPlists;
@end
