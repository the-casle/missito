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
    [_objects insertObject:firstSection atIndex:0];
    
    [firstSection addObject: @{@"Title":@"Yeet", @"Link":@"apollo://reddit.com/r/jailbreak"}];
    
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.layer.cornerRadius = 10.0;
    cell.imageView.clipsToBounds = YES;
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/pwn20wnd/profile_image?size=original"]];
        if(data == nil) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = [self scaleImageWithData:data proportionallyToSize:CGSizeMake(40,40)];
            [cell setNeedsLayout];
        });
    });

    NSMutableDictionary *dataDict = [self dataForIndex: indexPath];
    cell.textLabel.text = dataDict[@"Title"];
    cell.detailTextLabel.text = dataDict[@"Subtitle"];
    cell.imageView.image = dataDict[@"Image"];
	return cell;
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
-(id) dataForIndex:(NSIndexPath *) indexPath {
    NSArray *section = _objects[indexPath.section];
    return section[indexPath.row];
}

- (UIImage *)scaleImageWithData:(NSData *)imageData proportionallyToSize:(CGSize)newSize {
    return [self scaleImage:[UIImage imageWithData:imageData] toSize:[self estimateNewSize:newSize forImage:[UIImage imageWithData:imageData]]];
}
- (CGSize)estimateNewSize:(CGSize)newSize forImage:(UIImage *)image
{
    if (image.size.width > image.size.height) {
        newSize = CGSizeMake((image.size.width/image.size.height) * newSize.height, newSize.height);
    } else {
        newSize = CGSizeMake(newSize.width, (image.size.height/image.size.width) * newSize.width);
    }
    
    return newSize;
}
- (UIImage *)scaleImage:(UIImage *)originalImage toSize:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), originalImage.CGImage);
    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), originalImage.CGImage);
    }
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    
    return image;
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
        // twitter stuff
    }
}
@end
