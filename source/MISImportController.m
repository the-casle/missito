#import "MISImportController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"

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
        NSMutableArray *deserialArray = [MISSerializationController deserializeArrayFromString:pasteString];

        MISSharingController *shareCont = [MISSharingController sharedInstance];
        for(NSMutableDictionary *dict in deserialArray){
            [shareCont.importArray addObject: dict];
        }
    }
}
@end
