
@interface MISSessionManager : NSObject <NSURLSessionDelegate>
@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)(void);
- (void) dataForURL:(NSURL *) url completion:(void(^)(NSString *base64)) completionHandler;
+(id)sharedManager;
@end
