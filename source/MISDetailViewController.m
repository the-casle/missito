#import "MISDetailViewController.h"
#import "MISSerializationController.h"

#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"

@implementation MISDetailViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

	_objects = [[NSMutableArray alloc] init];
    [_objects insertObject:self.bundleID atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.tableView.allowsSelection = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(export:)];
}

- (void)export:(id)sender {
    NSMutableDictionary *shareDict = [[NSMutableDictionary alloc] init];
    NSString *pathToFile = [self pathToPreferenceFromBundleID:self.bundleID];
    
    shareDict[@"PathToFile"] = pathToFile;
    shareDict[@"PLIST"] = [NSDictionary dictionaryWithContentsOfFile: pathToFile];
    shareDict[@"Name"] = self.navigationItem.title;
    NSString *serialDict = [MISSerializationController serializeDictionary:shareDict];
    
    NSArray * activityItems = @[serialDict];
    NSArray * applicationActivities = nil;
    NSArray * excludeActivities = @[UIActivityTypePrint];
    UIActivityViewController * activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityController.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityController animated:YES completion:nil];
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
    cell.textLabel.text = _objects[indexPath.row];
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
            return @"Root Path";
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
