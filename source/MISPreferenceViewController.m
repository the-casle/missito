#import "MISPreferenceViewController.h"
#import "MISDetailViewController.h"

#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"

@implementation MISPreferenceViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];
    
	_objects = [[NSMutableArray alloc] init];
    [_objects insertObject:@[@"Filler Name"] atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];

}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_objects.count > section) return ((NSArray *)_objects[section]).count;
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

    cell.textLabel.text = [self dataForIndex: indexPath];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[_objects removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Current";
            break;
            
        case 1:
            return @"Saved";
            break;
            
        default:
            return @"Extra Section";
            break;
    }
}

#pragma mark - Utility

-(NSString *) pathToPreferenceFromBundleID:(NSString *) bundle{
    return [NSString stringWithFormat: @"%@/%@", PREFERNCE_PATH, bundle];
}

-(id) dataForIndex:(NSIndexPath *) indexPath {
    NSArray *section = _objects[indexPath.section];
    return section[indexPath.row];
}
#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MISDetailViewController *detailController = [[MISDetailViewController alloc] init];
    [detailController.navigationItem setTitle: cell.textLabel.text];
    detailController.bundleID = self.bundleID;
    [self.navigationController pushViewController:detailController animated:YES];
}

@end
