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

-(NSMutableArray *) arrayOfImportsForBundle:(NSString *) bundle{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.importArray.count; i++){
        NSMutableDictionary *sharingDict = self.importArray[i];
        if([sharingDict[@"BundleID"] isEqualToString:bundle]){
            [tempArray addObject:sharingDict[@"BaseDict"]];
            [self.importArray removeObjectAtIndex:i];
        }
    }
    return tempArray;
}


@end
