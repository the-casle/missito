#import "MISSharingController.h"
#import "MISSerializationController.h"

@implementation MISSharingController
@synthesize exportArray = _exportArray;
@synthesize importArray = _importArray;

-(instancetype) init{
    if(self = [super init]){
        _importArray = [[NSMutableArray alloc] init];
        _exportArray = [[NSMutableArray alloc] init];
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

-(NSMutableArray *) arrayOfExportsAndClear{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.exportArray.count; i++){
        NSMutableDictionary *sharingDict = self.exportArray[i];
        [tempArray addObject:sharingDict];
        [self.exportArray removeObjectAtIndex:i];
    }
    return tempArray;
}

@end
