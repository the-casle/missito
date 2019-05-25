#import "MISDefaultsManager.h"

@interface MISDefaultsManager ()

@end

@implementation MISDefaultsManager
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
@end
