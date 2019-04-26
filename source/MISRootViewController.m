#import "MISRootViewController.h"
#import "MISPreferenceViewController.h"

#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"

@implementation MISRootViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

	_objects = [[NSMutableArray alloc] init];

    [self.navigationItem setTitle: @"Preferences"];
    for(NSString *preference in [self preferenceArray]){
        [_objects insertObject:@{@"Name":[self nameFromBundleID:preference], @"BundleID":preference} atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	NSDictionary *rowDict = _objects[indexPath.row];
    cell.textLabel.text = rowDict[@"Name"];
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

-(NSString *) nameFromBundleID:(NSString *) bundle{
    NSArray *sepWithRest = [bundle componentsSeparatedByString:@"."];
    int count = sepWithRest.count;
    int nameIndex = 0;
    if(count > 1) {
        nameIndex = count - (count - 2);
    } else {
        nameIndex = 0;
    }
    NSString *baseName = sepWithRest[nameIndex];
    return [baseName capitalizedString];
}

-(NSString *) pathToPreferenceFromBundleID:(NSString *) bundle{
    return [NSString stringWithFormat: @"%@/%@", PREFERNCE_PATH, bundle];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MISPreferenceViewController *preferenceController = [[MISPreferenceViewController alloc] init];
    NSDictionary *rowDict = _objects[indexPath.row];
    preferenceController.bundleID = rowDict[@"BundleID"];
    [preferenceController.navigationItem setTitle: cell.textLabel.text];
    [self.navigationController pushViewController:preferenceController animated:YES];
}

@end
