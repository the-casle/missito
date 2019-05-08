#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"
#define DIRECTORY_PATH @"/var/mobile/Library/Missito/Preferences"
#define IMPORT_DIRECTORY_PATH @"/var/mobile/Library/Missito/Bundles"
#define DICT_BUNDLE_DIRECTORY_PATH @"/var/mobile/Library/Missito/DictsFromBundles"

@interface MISSerializationController : NSObject

+(NSString *)serializeDictionary:(NSMutableDictionary *)dict;
+(NSMutableDictionary *)deserializeDictionaryFromData:(NSData *)data;
+(void) overideBundle:(NSString *)bundle withDict:(NSMutableDictionary *) dict;
@end
