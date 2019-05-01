@interface MISSharingController : NSObject
+(id) sharedInstance;
-(NSMutableArray *) arrayOfImportsForBundle:(NSString *) bundle;
-(void) writeToFileImportArray:(NSMutableArray *)array;

@property (nonatomic, retain) NSMutableArray *bundleArray;
@property (nonatomic, retain) NSMutableArray *queueArray;
@end
