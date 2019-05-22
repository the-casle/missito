#import "MISSettingsViewController.h"
#import "MISSerializationController.h"

@implementation MISSettingsViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];

     self.tableView = [[UITableView alloc] initWithFrame: self.tableView.bounds style:UITableViewStyleGrouped];
    _objects = [[NSMutableArray alloc] init];
    [self.navigationItem setTitle: @"Info"];
    
    NSMutableArray *firstSection = [[NSMutableArray alloc] init];
    NSMutableArray *secondSection = [[NSMutableArray alloc] init];
    NSMutableArray *thirdSection = [[NSMutableArray alloc] init];
    NSMutableArray *forthSection = [[NSMutableArray alloc] init];
    [_objects addObject:firstSection];
    [_objects addObject:secondSection];
    [_objects addObject:thirdSection];
    [_objects addObject:forthSection];
    
    [firstSection addObject: @{@"Title":@"the casle", @"Subtitle":@"he made it or something", @"Link":@"https://twitter.com/the_casle", @"Image":@"https://twitter.com/the_casle/profile_image?size=original"}];
    [firstSection addObject: @{@"Title":@"Donate", @"Subtitle":@"money is nice", @"Link":@"https://paypal.me/thecasle", @"Image":@"https://www.paypalobjects.com/webstatic/icon/pp258.png"}];
    [secondSection addObject: @{@"Title":@"Bugs/Feature Requests", @"Subtitle":@"oh no it didnt work", @"Link":@"https://github.com/the-casle/missito/issues", @"Image":@"https://camo.githubusercontent.com/7710b43d0476b6f6d4b4b2865e35c108f69991f3/68747470733a2f2f7777772e69636f6e66696e6465722e636f6d2f646174612f69636f6e732f6f637469636f6e732f313032342f6d61726b2d6769746875622d3235362e706e67"}];
    [secondSection addObject: @{@"Title":@"Tutorial", @"Subtitle":@"Link to write up", @"Link":@"https://github.com/the-casle/missito/issues", @"Image":@"https://images-eu.ssl-images-amazon.com/images/I/418PuxYS63L.png"}];
    
    [thirdSection addObject: @{@"Title":@"midnightchips", @"Subtitle":@"good friend and helped some", @"Link":@"https://twitter.com/midnightchip", @"Image":@"https://twitter.com/midnightchip/profile_image?size=original"}];
    [thirdSection addObject: @{@"Title":@"DGh0st", @"Subtitle":@"base64 dumb", @"Link":@"https://twitter.com/D_Gh0st", @"Image":@"https://twitter.com/D_Gh0st/profile_image?size=original"}];
    [thirdSection addObject: @{@"Title":@"Karim", @"Subtitle":@"preferences dumb", @"Link":@"https://twitter.com/karimo299", @"Image":@"https://twitter.com/karimo299/profile_image?size=original"}];
    
    [forthSection addObject: @{@"Title":@"Clear Cache", @"Subtitle":@"Clear uninstalled tweak saves", @"Image":@"https://cdn3.iconfinder.com/data/icons/cleaning-icons/512/Bucket_with_Soap-512.png", @"Block":^{
        [MISSerializationController clearCache];
    }}];
    
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
            return @"Support";
            break;
            
        case 2:
            return @"Special Thanks";
            break;
        case 3:
            return @"Utility";
            break;
            
        default:
            return @"Special Thanks";
            break;
    }
}

#pragma mark - Utility
-(id) dataForIndex:(NSIndexPath *) indexPath {
    NSArray *section = _objects[indexPath.section];
    return section[indexPath.row];
}

- (UIImage *)imageWithImage:(UIImage *)img convertToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dict = [self dataForIndex:indexPath];
    NSString *linkString = dict[@"Link"];
    if(linkString){
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
    } else {
        ((void (^)(void))dict[@"Block"])();
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
