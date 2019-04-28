#import "MISImportController.h"
#import "MISSerializationController.h"

@implementation MISImportController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

    [self.navigationItem setTitle:@"Import"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(transitionToPageController:)];
}

- (void)transitionToPageController:(id)sender {
    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteString = generalPasteboard.string;
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *matches = [detector matchesInString:pasteString
                                         options:0
                                           range:NSMakeRange(0, [pasteString length])];
    if(matches.count > 0){
        // do link stuff
    } else {
        BOOL isDir;
        NSFileManager *fileManager= [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath: IMPORTED_DIRECTORY_PATH isDirectory:&isDir]){
            [fileManager createDirectoryAtPath:IMPORTED_DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        NSDictionary *deserialDict = [MISSerializationController deserializeDictionaryFromString:pasteString];
        NSMutableDictionary *baseDict = deserialDict[@"BaseDict"];
        NSString *importPath = [NSString stringWithFormat:@"%@/%@", IMPORTED_DIRECTORY_PATH, deserialDict[@"BundleID"]];
        if (@available(iOS 11, tvOS 11, *)) {
            [baseDict writeToURL: [NSURL fileURLWithPath:importPath]
                           error:nil];
        }
    }
    
}
@end
