@interface MISSharingController : NSObject
+(id) sharedInstance;
-(NSMutableArray *) arrayOfImportsForBundle:(NSString *) bundle;
-(NSMutableArray *) arrayOfExportsAndClear;

@property (nonatomic, retain, readonly) NSMutableArray *importArray;
@property (nonatomic, retain, readonly) NSMutableArray *exportArray;
@end
