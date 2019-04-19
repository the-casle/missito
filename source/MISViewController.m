#import "MISViewController.h"

@implementation MISViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];
    
    self.title = @"Yeet";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(transitionToPageController:)];
}

- (void)transitionToPageController:(id)sender {
    MISViewController *secondController = [[MISViewController alloc] init];
    secondController.view.backgroundColor = [UIColor greenColor];
    [self.navigationController pushViewController:secondController animated:YES];
}
@end
