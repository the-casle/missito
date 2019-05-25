#import "MISDefaultsManager.h"
#import "MHWDirectoryWatcher/MHWDirectoryWatcher.h"

void directoryWatcherAtPath(NSString *bundleID){
    NSString *path = [NSString stringWithFormat:@"%@/%@.plist", PREFERNCE_PATH, bundleID];
    CFStringRef onlyBundle = (__bridge CFStringRef)bundleID;
    [MHWDirectoryWatcher directoryWatcherAtPath:path callback:^{
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
        CFArrayRef arrayKeys = CFPreferencesCopyKeyList(onlyBundle, CFSTR("mobile"), kCFPreferencesAnyHost);
        if(arrayKeys && CFArrayGetCount(arrayKeys) > 0){
            CFPreferencesSetMultiple((__bridge CFDictionaryRef)plist, nil, onlyBundle, CFSTR("mobile"), kCFPreferencesAnyHost);
            CFPreferencesAppSynchronize(onlyBundle);
        }
        for(NSString *key in plist.allKeys){
            NSLog(@"missito_APP | key:%@ value:%@", key, plist[key]);
        }
        directoryWatcherAtPath(bundleID);
    }];
}

NSString * defaultsBundleID(NSDictionary *infoPlist){
    NSString *pathToBundle = [NSString stringWithFormat:@"%@/%@.bundle", PREFERNCE_BUNDLE_PATH, infoPlist[@"CFBundleExecutable"]];
    NSSet* dirs = [NSSet setWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToBundle error:nil]];
    NSString *backup = nil;
    for(NSString *filename in dirs){
        if([filename rangeOfString:@".plist"].location != NSNotFound) {
            NSString *dictString = [NSString stringWithFormat:@"%@/%@",pathToBundle, filename];
            NSDictionary *possibleDict = [NSDictionary dictionaryWithContentsOfFile:dictString];
            NSSet *itemSet = [NSSet setWithArray: possibleDict[@"items"]];
            if(itemSet){
                for(NSDictionary *cell in itemSet){
                    NSString *possibleDefaults = cell[@"defaults"];
                    if(possibleDefaults){
                        backup = possibleDefaults;
                        if([possibleDefaults rangeOfString:@"color" options:NSCaseInsensitiveSearch].location == NSNotFound){
                            return possibleDefaults;
                        }
                    }
                }
            }
        }
    }
    if(backup) return backup;
    else return infoPlist[@"CFBundleIdentifier"]; //If it cant find it
}

%ctor{
    for(NSDictionary *infoPlist in [MISDefaultsManager infoPlists]){
        NSString *bundle = defaultsBundleID(infoPlist);
        directoryWatcherAtPath(bundle);
    }
}
