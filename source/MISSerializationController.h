#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"

@interface MISSerializationController : NSObject

+(NSString*)serializeDictionary:(NSDictionary *)dictionary;
+(NSDictionary*)deserializeDictionary:(NSString *)string;

@end
