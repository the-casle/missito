#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"
#define DIRECTORY_PATH @"/var/mobile/Library/Missito"
#define IMPORT_DIRECTORY_PATH @"/var/mobile/Library/Missito/Import"

@interface MISSerializationController : NSObject

+(NSString*)serializeArray:(NSMutableArray *)array;
+(NSMutableArray*)deserializeArrayFromString:(NSString *)string;
+(void) overideBundle:(NSString *)bundle withDict:(NSMutableDictionary *) dict;
@end
