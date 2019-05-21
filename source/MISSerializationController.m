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
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutable
                                                       options:0
                                                         error:nil];
    if (! jsonData) {
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
        CFArrayRef arrayKeys = CFPreferencesCopyKeyList((__bridge CFStringRef)bundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if(arrayKeys){
            CFPreferencesSetMultiple((__bridge CFDictionaryRef)dict[@"Plist"], nil, (__bridge CFStringRef)bundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        } else {
            NSString *pathToFile = [NSString stringWithFormat:@"%@/%@.plist", PREFERNCE_PATH, bundle];
            if (@available(iOS 11, tvOS 11, *)) {
                [dict[@"Plist"] writeToURL:[NSURL fileURLWithPath:pathToFile]
                               error:nil];
            }
        }
        CFPreferencesAppSynchronize((__bridge CFStringRef)bundle);
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
            dict[@"label"] = entry[@"label"];
            [sortedPrefs addObject:dict];
        }
    }
    return sortedPrefs;
}

+(NSString *) nameFromBundleID:(NSString *) bundle{
    NSArray *sepWithRest = [bundle componentsSeparatedByString:@"."];
    int count = sepWithRest.count;
    int nameIndex = 0;
    if(count > 1) {
        nameIndex = count - (count - 2);
    } else {
        nameIndex = 0;
    }
    NSString *baseName = sepWithRest[nameIndex];
    return [baseName capitalizedString];
}

@end
