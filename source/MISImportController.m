#import "MISImportController.h"

@implementation MISImportController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

    [self.navigationItem setTitle:@"Import"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(transitionToPageController:)];
}

- (void)transitionToPageController:(id)sender {

}
@end
