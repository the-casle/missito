#import "MISExportViewController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"

@implementation MISExportViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];
    _objects = [[NSMutableArray alloc] init];
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    for(NSMutableDictionary *dict in [sharingCont arrayOfExportsAndClear]){
        [_objects addObject: dict];
        [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    self.tableView.allowsSelection = NO;
    [self.navigationItem setTitle: @"Export"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    for(NSMutableDictionary *dict in [sharingCont arrayOfExportsAndClear ]){
        [_objects addObject: dict];
        [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:_objects.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)share:(id)sender {
    if(_objects.count > 0){
        NSString *serialDict = [MISSerializationController serializeArray:_objects];
        NSArray *activityItems = @[serialDict];
        NSArray *applicationActivities = nil;
        NSArray *excludeActivities = @[UIActivityTypePrint];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        activityController.excludedActivityTypes = excludeActivities;
        [self presentViewController:activityController animated:YES completion:nil];
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
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Utility

-(NSArray *) preferenceArray{
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:PREFERNCE_PATH
                                                                        error:NULL];
    NSMutableArray *devPrefs = [[NSMutableArray alloc] init];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([filename rangeOfString:@"com.apple"].location == NSNotFound && [extension isEqualToString:@"plist"]) {
            if([filename componentsSeparatedByString:@"."].count >= 4){
                [devPrefs addObject:filename];
            }
        }
    }];
    return devPrefs;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
