#import "MISViewController.h"

@implementation MISViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

    [self.navigationItem setTitle:@"Some Title"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(transitionToPageController:)];
}

- (void)transitionToPageController:(id)sender {
    MISViewController *secondController = [[MISViewController alloc] init];
    
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    secondController.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    [self.navigationController pushViewController:secondController animated:YES];
}
@end
