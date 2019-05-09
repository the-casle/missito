#import "MISSettingsViewController.h"

@implementation MISSettingsViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

     self.tableView = [[UITableView alloc] initWithFrame: self.tableView.bounds style:UITableViewStyleGrouped];
    _objects = [[NSMutableArray alloc] init];
    [self.navigationItem setTitle: @"Settings"];
    
    NSMutableArray *firstSection = [[NSMutableArray alloc] init];
    NSMutableArray *secondSection = [[NSMutableArray alloc] init];
    [_objects addObject:firstSection];
    [_objects addObject:secondSection];
    
    [firstSection addObject: @{@"Title":@"the casle", @"Subtitle":@"he made it or something", @"Link":@"https://twitter.com/the_casle", @"Image":@"https://twitter.com/the_casle/profile_image?size=original"}];
    [secondSection addObject: @{@"Title":@"midnightchips", @"Subtitle":@"good friend and helped some", @"Link":@"https://twitter.com/midnightchip", @"Image":@"https://twitter.com/midnightchip/profile_image?size=original"}];
    
    [self.tableView reloadData];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSMutableArray *)_objects[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
    NSMutableDictionary *dataDict = [self dataForIndex: indexPath];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: dataDict[@"Image"]]];
        if(data == nil) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = [self imageWithImage:[UIImage imageWithData: data] convertToSize:CGSizeMake(40,40)];
            [cell setNeedsLayout];
        });
    });
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.layer.cornerRadius = 10.0;
    cell.imageView.clipsToBounds = YES;
    cell.textLabel.text = dataDict[@"Title"];
    cell.detailTextLabel.text = dataDict[@"Subtitle"];
	return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Developer";
            break;
            
        case 1:
            return @"Special Thanks";
            break;
            
        default:
            return @"Extra Section";
            break;
    }
}

#pragma mark - Utility
-(id) dataForIndex:(NSIndexPath *) indexPath {
    NSArray *section = _objects[indexPath.section];
    return section[indexPath.row];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dict = [self dataForIndex:indexPath];
    NSString *linkString = dict[@"Link"];
    if ([linkString rangeOfString:@"Twitter" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *link = [NSURL URLWithString:linkString];
        if ([app canOpenURL:link]){
            [app openURL:link options:@{} completionHandler:nil];
        } else{
            NSURLComponents *components = [NSURLComponents componentsWithURL:link resolvingAgainstBaseURL:YES];
            components.scheme = @"https";
            [app openURL:components.URL options:@{} completionHandler:nil];
        }
    } else {
        [self _openTwitterForUser:linkString];
    }
}
- (void)_openTwitterForUser:(NSString*)link {
    NSURLComponents *components = [NSURLComponents componentsWithURL:[NSURL URLWithString:link] resolvingAgainstBaseURL:YES];
    NSString *username = [components.query componentsSeparatedByString:@"="].lastObject;
    if(!username){
        username = [components.path componentsSeparatedByString:@"/"].lastObject;
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *twitterapp = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:///user?screen_name=%@", username]];
    NSURL *tweetbot = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", username]];
    NSURL *twitterweb = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", username]];
    
    
    if ([app canOpenURL:twitterapp])
        [app openURL:twitterapp options:@{} completionHandler:nil];
    else if ([app canOpenURL:tweetbot])
        [app openURL:tweetbot options:@{} completionHandler:nil];
    else
        [app openURL:twitterweb options:@{} completionHandler:nil];
}
@end
