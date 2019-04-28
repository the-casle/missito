#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"
#define DIRECTORY_PATH @"/var/mobile/Library/Missito"
#define IMPORTED_DIRECTORY_PATH @"/var/mobile/Library/Missito/Imported"

@interface MISSerializationController : NSObject

+(NSString*)serializeDictionary:(NSDictionary *)dictionary;
+(NSDictionary*)deserializeDictionaryFromString:(NSString *)string;

@end
