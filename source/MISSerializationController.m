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
        NSString *onlyBundle = [bundle stringByReplacingOccurrencesOfString:@".plist" withString:@""];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    }
}
@end
