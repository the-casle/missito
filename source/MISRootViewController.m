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
    for(NSDictionary *info in [MISSerializationController infoPlists]){
        [nameArray addObject:info[@"label"]];
    }
    NSArray *sortedName = [nameArray sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    for(NSString *name in sortedName){
        for(NSDictionary *info in [MISSerializationController infoPlists]){
            NSString *nameFromBundle = info[@"label"];
            if([nameFromBundle isEqualToString:name]){
                [_objects addObject:info];
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
    cell.imageView.image = [self imageWithImage: [self imageForInfoPlist:rowDict] convertToSize:CGSizeMake(30,30)];
    cell.imageView.layer.cornerRadius = 8.0;
    cell.imageView.clipsToBounds = YES;
    cell.textLabel.text = rowDict[@"label"];
    cell.detailTextLabel.text = rowDict[@"CFBundleIdentifier"];
	return cell;
}
-(UIImage *) imageForInfoPlist:(NSDictionary *)infoPlist{
    NSString *path = [NSString stringWithFormat:@"%@/%@.plist", PREFERNCE_LOADER_PATH, infoPlist[@"CFBundleExecutable"]];
    NSDictionary *preferenceLoader = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *entry = preferenceLoader[@"entry"];
    NSString *iconName = entry[@"icon"];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.bundle/%@", PREFERNCE_BUNDLE_PATH, infoPlist[@"CFBundleExecutable"], iconName];
    return [UIImage imageWithContentsOfFile:imagePath];
}

#pragma mark - Utility
- (UIImage *)imageWithImage:(UIImage *)img convertToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MISPreferenceViewController *preferenceController = [[MISPreferenceViewController alloc] init];
    preferenceController.infoPlist = _objects[indexPath.row];
    [preferenceController.navigationItem setTitle: cell.textLabel.text];
    [self.navigationController pushViewController:preferenceController animated:YES];
}
@end
