#import "MISRootViewController.h"
#import "MISPreferenceViewController.h"
#import "MISSerializationController.h"
#import "MISQueueViewController.h"
#import "MISBadgeBarButtonItem.h"

@implementation MISRootViewController {
	NSMutableArray *_objects;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	_objects = [[NSMutableArray alloc] init];

    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    for(NSString *preference in [self allBundles]){
        [nameArray addObject:[self nameFromBundleID:preference]];
    }
    NSArray *sortedName = [nameArray sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    for(NSString *name in sortedName){
        for(NSString *bundle in [self allBundles]){
            NSString *nameFromBundle = [self nameFromBundleID:bundle];
            if([nameFromBundle isEqualToString:name]){
                [_objects addObject:@{@"Name":nameFromBundle, @"BundleID":bundle}];
                break;
            }
        }
    }
    [self.tableView reloadData];
    
    [self.navigationItem setTitle: @"Preferences"];
    self.navigationItem.rightBarButtonItem = [[MISBadgeBarButtonItem alloc] initWithTitle:@"Queue" style:UIBarButtonItemStylePlain target:self action:@selector(queueButton:)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    MISBadgeBarButtonItem *badgeBar = (MISBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    badgeBar.badgeValue = self.navigationController.tabBarItem.badgeValue;
    
    [self.tableView reloadData];
}

-(void) queueButton:(id)sender{
    MISQueueViewController *queueController = [[MISQueueViewController alloc] init];
    [self.navigationController pushViewController:queueController animated:YES];
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


#pragma mark - Utility

-(NSMutableArray *) allBundles {
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DIRECTORY_PATH
                                                                        error:NULL];
    NSMutableArray *devPrefs = [self preferenceArray];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        BOOL isNew = YES;
        for(NSString *preferenceId in [self preferenceArray]){
            if([preferenceId isEqualToString: filename]){
                isNew = NO;
                break;
            }
        }
        if(isNew){
            [devPrefs addObject:filename];
        }
    }];
    return devPrefs;
}

-(NSMutableArray *) preferenceArray{
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MISPreferenceViewController *preferenceController = [[MISPreferenceViewController alloc] init];
    NSDictionary *rowDict = _objects[indexPath.row];
    preferenceController.bundleID = rowDict[@"BundleID"];
    [preferenceController.navigationItem setTitle: cell.textLabel.text];
    [self.navigationController pushViewController:preferenceController animated:YES];
}
@end
