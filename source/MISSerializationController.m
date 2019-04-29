#import "MISSerializationController.h"

@implementation MISSerializationController

+(NSString*)serializeArray:(NSMutableArray *)array {
    NSMutableArray *mutable = [array mutableCopy];
    
    NSData *plist = [NSPropertyListSerialization dataWithPropertyList:mutable
                                                               format:NSPropertyListBinaryFormat_v1_0
                                                              options:kNilOptions
                                                                error:NULL];
    return [plist base64EncodedStringWithOptions:kNilOptions];
}

+(NSMutableArray*)deserializeArrayFromString:(NSString *)string {
    NSData *plist = [[NSData alloc] initWithBase64EncodedString:string options:kNilOptions];
    if(!plist) return nil;
    return [NSPropertyListSerialization propertyListWithData:plist
                                                     options:kNilOptions
                                                      format:NULL
                                                       error:NULL];
}
+(void) overideBundle:(NSString *)bundle withDict:(NSMutableDictionary *) dict{
    if(bundle && dict){
        NSString *onlyBundle = [bundle stringByReplacingOccurrencesOfString:@".plist" withString:@""];
        CFPreferencesSetMultiple((__bridge CFDictionaryRef)dict[@"Plist"], nil, (__bridge CFStringRef)onlyBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        CFPreferencesSynchronize((__bridge CFStringRef)onlyBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    }
}
@end
