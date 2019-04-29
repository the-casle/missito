#import "MISSharingController.h"
#import "MISSerializationController.h"

@implementation MISSharingController
@synthesize bundleArray = _bundleArray;
@synthesize importArray = _importArray;
@synthesize queueArray = _queueArray;

-(instancetype) init{
    if(self = [super init]){
        _importArray = [[NSMutableArray alloc] init];
        _queueArray = [[NSMutableArray alloc] init];
        _bundleArray = [[NSMutableArray alloc] init];
    }
    return self;
}
+(instancetype)sharedInstance {
    static MISSharingController *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MISSharingController alloc] init];
    });
    return sharedInstance;
}

-(void) writeToFileImportArray:(NSMutableArray *)array{
    BOOL isDir;
    NSString *path = [NSString stringWithFormat:@"%@/%@", DICT_BUNDLE_DIRECTORY_PATH, @"dicts.plist"];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:DICT_BUNDLE_DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
        if (@available(iOS 11, tvOS 11, *)) {
            [array writeToURL:[NSURL fileURLWithPath:path]
                           error:nil];
        }
    } else {
        NSMutableArray *oldArray = [NSMutableArray arrayWithContentsOfFile:path];
        for(NSMutableDictionary *dict in array){
            [oldArray addObject:dict];
        }
        if (@available(iOS 11, tvOS 11, *)) {
            [oldArray writeToURL:[NSURL fileURLWithPath:path]
                        error:nil];
        }
    }
}

-(NSMutableArray *) arrayOfImportsForBundle:(NSString *) bundle{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", DICT_BUNDLE_DIRECTORY_PATH, @"dicts.plist"];
    NSMutableArray *oldArray = [NSMutableArray arrayWithContentsOfFile:path];
    int count = oldArray.count - 1;
    for(int i = 0; i < count; i++){
        NSMutableDictionary *sharingDict = oldArray.firstObject;
        if([sharingDict[@"BundleID"] isEqualToString:bundle]){
            [tempArray addObject:sharingDict[@"BaseDict"]];
            [oldArray removeObjectAtIndex:0];
        }
    }
    if (@available(iOS 11, tvOS 11, *)) {
        [oldArray writeToURL:[NSURL fileURLWithPath:path]
                       error:nil];
    }
    return tempArray;
}


@end
