#import "MISSerializationController.h"

@implementation MISSerializationController

+(NSString *)serializeDictionary:(NSMutableDictionary *)dict {
    NSMutableDictionary *mutable = [dict mutableCopy];
    if(![NSJSONSerialization isValidJSONObject:mutable]){
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for(NSString *key in mutable.allKeys){
            if([NSJSONSerialization isValidJSONObject:mutable[key]]){
                newDict[key] = mutable[key];
            }
        }
        mutable = newDict;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutable options:0 error:nil];
    if (!jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+(NSMutableDictionary *)deserializeDictionaryFromData:(NSData *)data {
    NSError *error;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    return dict;
}

+(void) overideBundle:(NSString *)bundle withDict:(NSMutableDictionary *) dict {
    if(bundle && dict){
        
        CFArrayRef arrayKeys = CFPreferencesCopyKeyList((__bridge CFStringRef)bundle, CFSTR("mobile"), kCFPreferencesAnyHost);
        if(arrayKeys && CFArrayGetCount(arrayKeys) > 0){
            CFPreferencesSetMultiple((__bridge CFDictionaryRef)dict[@"Plist"], nil, (__bridge CFStringRef)bundle, CFSTR("mobile"), kCFPreferencesAnyHost);
        } else {
            NSString *pathToFile = [NSString stringWithFormat:@"%@/%@.plist", PREFERNCE_PATH, bundle];
            if (@available(iOS 11, tvOS 11, *)) {
                NSError *error;
                [dict[@"Plist"] writeToURL:[NSURL fileURLWithPath:pathToFile]
                               error:&error];
                NSLog(@"missito_APP | error: %@",error);
            }
        }
        CFPreferencesSynchronize((__bridge CFStringRef)bundle, CFSTR("mobile"), kCFPreferencesAnyHost);
    }
}

+(NSMutableArray *) infoPlists{
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:PREFERNCE_LOADER_PATH
                                                                        error:NULL];
    NSMutableArray *rawPrefs = [[NSMutableArray alloc] init];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        [rawPrefs addObject:filename];
    }];
    NSMutableArray *sortedPrefs = [[NSMutableArray alloc] init];
    for(NSString *fileName in rawPrefs){
        NSString *bundleNoPlist = [fileName stringByReplacingOccurrencesOfString:@"plist" withString:@"bundle"];
        NSString *path = [NSString stringWithFormat:@"%@/%@/Info.plist", PREFERNCE_BUNDLE_PATH, bundleNoPlist];
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
        if(dict){
            NSString *path = [NSString stringWithFormat:@"%@/%@.plist", PREFERNCE_LOADER_PATH, dict[@"CFBundleExecutable"]];
            NSDictionary *preferenceLoader = [NSDictionary dictionaryWithContentsOfFile:path];
            NSDictionary *entry = preferenceLoader[@"entry"];
            if(entry[@"label"]){
                dict[@"label"] = entry[@"label"];
            } else {
                dict[@"label"] = dict[@"CFBundleExecutable"];
            }
            [sortedPrefs addObject:dict];
        }
    }
    return sortedPrefs;
}

+(void)clearCache{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSSet* dirs = [NSSet setWithArray: [fileManager contentsOfDirectoryAtPath:DIRECTORY_PATH error:NULL]];
    for(NSString *fileName in dirs){
        NSString *fileNoPlist = [fileName stringByReplacingOccurrencesOfString:@".plist" withString:@""];
        BOOL exists = NO;
        for(NSDictionary *infoPlists in [self infoPlists]){
            if([fileNoPlist isEqualToString: infoPlists[@"CFBundleIdentifier"]]){
                exists = YES;
                break;
            }
        }
        if(!exists){
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",DIRECTORY_PATH, fileName] error:nil];
        }
    }
    [fileManager removeItemAtPath:DICT_BUNDLE_DIRECTORY_PATH error:nil];
}

+(NSDictionary *) activePlistForBundle:(NSString *)bundleID {
    CFStringRef onlyBundle = (__bridge CFStringRef)bundleID;
    CFArrayRef arrayKeys = CFPreferencesCopyKeyList(onlyBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if(arrayKeys){
        CFDictionaryRef values = CFPreferencesCopyMultiple(arrayKeys, onlyBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        NSMutableDictionary *preferences = [CFBridgingRelease(values) mutableCopy];
        return preferences;
    }
    NSString *pathToFile = [NSString stringWithFormat:@"%@/%@.plist", PREFERNCE_PATH, bundleID];
    return [NSDictionary dictionaryWithContentsOfFile:pathToFile];
}
+(NSString *) defaultsBundleIDForInfoPlist:(NSDictionary *)infoPlist{
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

@end
