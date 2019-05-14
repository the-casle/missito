#import "MISQueueViewController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"

@implementation MISQueueViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];
    _objects = [[NSMutableArray alloc] init];
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    for(NSMutableDictionary *dict in sharingCont.queueArray){
        [_objects addObject: dict];
    }
    [self.tableView reloadData];
    [self updateBadgeCount];
    self.tableView.allowsSelection = NO;
    [self.navigationItem setTitle: @"Queue"];
    if(_objects.count > 0){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Build" style:UIBarButtonItemStylePlain target:self action:@selector(compile:)];
    } else {
        UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [info addTarget:self action:@selector(infoIcon:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:info];
    }
}

-(void) infoIcon:(id)sender{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Queue"
                                message:@"The queue is used to convert saved preferences into a shareable format. Multiple can be bundled together to save setups or for sharing."
                                preferredStyle:
                                UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Dismiss"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
    
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)compile:(id)sender {
    if(_objects.count > 0){
        MISSharingController *sharingCont = [MISSharingController sharedInstance];
        sharingCont.bundleArray = [sharingCont.queueArray mutableCopy];
        self.navigationController.tabBarItem.badgeValue = nil;
        [self.tabBarController setSelectedIndex:1];
        [self.navigationController popViewControllerAnimated:NO];
        _objects = [[NSMutableArray alloc] init];
        [self saveObjects];
    }
}

-(void) saveObjects{
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    sharingCont.queueArray = _objects;
}

-(void) updateBadgeCount {
    if(_objects.count > 0){
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)_objects.count];
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
    
	NSMutableDictionary *rowDict = _objects[indexPath.row];
    NSMutableDictionary *baseDict = rowDict[@"BaseDict"];
    cell.textLabel.text = baseDict[@"Name"];
    cell.detailTextLabel.text = rowDict[@"BundleID"];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[_objects removeObjectAtIndex:indexPath.row];
    [self saveObjects];
    [self updateBadgeCount];
	[self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
