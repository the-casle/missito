#import "MISSerializationController.h"

@implementation MISSerializationController

+(NSString *)serializeDictionary:(NSMutableDictionary *)dict {
    NSMutableDictionary *mutable = [dict mutableCopy];
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
        CFPreferencesSetMultiple((__bridge CFDictionaryRef)dict[@"Plist"], nil, (__bridge CFStringRef)bundle, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
        //CFPreferencesSynchronize((__bridge CFStringRef)onlyBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
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
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        if(dict){
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
