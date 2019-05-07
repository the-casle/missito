#import "MISSessionManager.h"
#import <objc/runtime.h>

typedef void(^completion)(NSString *);

@interface  MISSessionManager ()
@property (nonatomic, copy) completion completionHandler;
@property (nonatomic, retain) NSString *returnString;
@property (nonatomic, retain) NSMutableDictionary *responsesData;
@end

@implementation MISSessionManager {
    
}

+ (instancetype)sharedManager {
    static MISSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedManager = [[MISSessionManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init{
    self = [super init];
    if(self){
        self.responsesData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dataForURL:(NSURL *) url completion:(completion) completionHandler{
    if(completionHandler) self.completionHandler = completionHandler;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"MissitoDownload"];
    config.discretionary = YES;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionTask *downloadTask = [session dataTaskWithURL:url];
    [downloadTask resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSMutableData *responseData = self.responsesData[@(dataTask.taskIdentifier)];
    if (!responseData) {
        responseData = [NSMutableData dataWithData:data];
        self.responsesData[@(dataTask.taskIdentifier)] = responseData;
    } else {
        [responseData appendData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"missito_APP | %@ failed: %@", task.originalRequest.URL, error);
    }
    NSMutableData *responseData = self.responsesData[@(task.taskIdentifier)];
    if (responseData) {
        NSString *pasteOutput = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"missito_APP | %@, %lu", pasteOutput, (unsigned long)[pasteOutput length]);
        pasteOutput = [pasteOutput componentsSeparatedByString:@"~"].firstObject;
        if (pasteOutput) {
            self.completionHandler(pasteOutput);
        } else {
            NSLog(@"missito_APP | responseData = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
        [self.responsesData removeObjectForKey:@(task.taskIdentifier)];
    } else {
        NSLog(@"missito_APP | responseData is nil");
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.backgroundSessionCompletionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundSessionCompletionHandler();
            self.backgroundSessionCompletionHandler = nil;
        });
    }
}
@end
