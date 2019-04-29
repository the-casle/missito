#import "MISDetailViewController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"
#import <malloc/malloc.h>


@implementation MISDetailViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

	_objects = [[NSMutableArray alloc] init];
    [_objects insertObject:self.bundleID atIndex:0];

    NSString *formatSize = [NSString stringWithFormat:@"%zd bytes", malloc_size((__bridge const void *) self.shareDict)];
    [_objects insertObject:formatSize atIndex:1];
    
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.tableView.allowsSelection = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style: UIBarButtonItemStylePlain target:self action:@selector(export:)];
}

- (void)export:(id)sender {
    NSMutableDictionary *shareDict = [[NSMutableDictionary alloc] init];

    shareDict[@"BundleID"] = self.bundleID;
    shareDict[@"BaseDict"] = self.shareDict;
    
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    [sharingCont.exportArray addObject:shareDict];
    [self.tabBarController setSelectedIndex:2];
    [self.navigationController popToRootViewControllerAnimated:NO];
}
#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    cell.textLabel.text = _objects[indexPath.section];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[_objects removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"BundleID";
            break;
            
        case 1:
            return @"Size";
            break;
            
        default:
            return @"Extra Section";
            break;
    }
}

#pragma mark - Utility

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MISImportController *secondController = [[MISImportController alloc] init];
    [secondController.navigationItem setTitle: cell.textLabel.text];
    
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    secondController.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    [self.navigationController pushViewController:secondController animated:YES];*/
}

@end
