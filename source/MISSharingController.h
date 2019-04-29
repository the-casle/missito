@interface MISSharingController : NSObject
+(id) sharedInstance;
-(NSMutableArray *) arrayOfImportsForBundle:(NSString *) bundle;

@property (nonatomic, retain, readonly) NSMutableArray *importArray;
@property (nonatomic, retain) NSMutableArray *bundleArray;
@property (nonatomic, retain) NSMutableArray *queueArray;
@end
