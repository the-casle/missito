#import "MISExportViewController.h"
#import "MISSerializationController.h"

@implementation MISExportViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

	_objects = [[NSMutableArray alloc] init];

    [self.navigationItem setTitle: @"Export"];
    
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	NSDictionary *rowDict = _objects[indexPath.row];
    cell.textLabel.text = rowDict[@"Name"];
    cell.detailTextLabel.text = rowDict[@"BundleID"];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	/*[_objects removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    // This needs to be done better
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
