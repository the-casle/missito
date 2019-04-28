#import "MISSerializationController.h"

@implementation MISSerializationController

+(NSString*)serializeDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutable = [dictionary mutableCopy];
    
    NSData *plist = [NSPropertyListSerialization dataWithPropertyList:mutable
                                                               format:NSPropertyListBinaryFormat_v1_0
                                                              options:kNilOptions
                                                                error:NULL];
    return [plist base64EncodedStringWithOptions:kNilOptions];
}

+(NSDictionary*)deserializeDictionary:(NSString *)string {
    NSData *plist = [[NSData alloc] initWithBase64EncodedString:string options:kNilOptions];
    return [NSPropertyListSerialization propertyListWithData:plist
                                                     options:kNilOptions
                                                      format:NULL
                                                       error:NULL];
}
@end
