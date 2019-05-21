#import "MISPreferenceViewController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"
#import "MISQueueViewController.h"
#import "../External/SVProgressHUD/SVProgressHUD.h"


@implementation MISPreferenceViewController {
	NSMutableArray *_objects;
    NSString *_bundleIDPath;
    NSString *_bundleID;
    NSString *_defaultsBundleID;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    BOOL isDir;
    _bundleID = self.infoPlist[@"CFBundleIdentifier"];
    _bundleIDPath = [NSString stringWithFormat:@"%@/%@.plist", DIRECTORY_PATH, _bundleID];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:DIRECTORY_PATH isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString *pathToFile = [NSString stringWithFormat:@"%@/%@.plist", PREFERNCE_PATH, _bundleID];
    if([fileManager fileExistsAtPath:pathToFile isDirectory:&isDir]){
        _defaultsBundleID = _bundleID;
    } else {
        _defaultsBundleID = [self defaultsBundleID];
    }
    
    NSMutableArray *savedObjects = [NSMutableArray arrayWithContentsOfFile:_bundleIDPath];
    if(!savedObjects){
        _objects = [[NSMutableArray alloc] init];
                    NSMutableArray *firstSection = [[NSMutableArray alloc] init];
                    NSMutableArray *secondSection = [[NSMutableArray alloc] init];
                    NSMutableDictionary *currentDict = [[NSMutableDictionary alloc] init];
                    currentDict[@"Name"] = [self unsavedPrefernceString];
                    currentDict[@"Plist"] = [self activePlist];
                    [firstSection addObject:currentDict];
        
        [_objects insertObject:firstSection atIndex:0];
        [_objects insertObject:secondSection atIndex:1];
    } else {
        _objects = savedObjects;
    }
    for(NSMutableDictionary *importDict in [[MISSharingController sharedInstance] arrayOfImportsForBundle:_bundleID]){
        NSMutableDictionary *dict = [importDict mutableCopy];
        dict[@"Name"] = [self singleNameForName:dict[@"Name"]];
        [_objects.lastObject addObject: dict];
        [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:(((NSMutableArray *)_objects.lastObject).count - 1) inSection:_objects.count - 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self saveObjects];
    
    [self updateCurrentCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentCell)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
	
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.tableView.rowHeight =  50;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    for(NSMutableDictionary *importDict in [[MISSharingController sharedInstance] arrayOfImportsForBundle:_bundleID]){
        NSMutableDictionary *dict = [importDict mutableCopy];
        dict[@"Name"] = [self singleNameForName:dict[@"Name"]];
        [_objects.lastObject addObject: dict];
        [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:(((NSMutableArray *)_objects.lastObject).count - 1) inSection:_objects.count - 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self saveObjects];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
	}
    if(indexPath.section){ // Not 0
        MISSharingController *sharingCont = [MISSharingController sharedInstance];
        BOOL isQueued = NO;
        
        for(NSMutableDictionary *shareDict in sharingCont.queueArray){ // THIS IS BUGGED STILL.
            NSMutableDictionary *base = shareDict[@"BaseDict"];
            NSMutableDictionary *currentDict = [self dataForIndex:indexPath];
            if([currentDict[@"Plist"] isEqualToDictionary: base[@"Plist"]] && [currentDict[@"Name"] isEqualToString:base[@"Name"]]){
                isQueued = YES;
                break;
            }
        }
        if(isQueued){
            cell.accessoryView = [self checkedButtonView];
        } else {
            cell.accessoryView = [self queueButtonView];
        }
    } else cell.accessoryType = UITableViewCellAccessoryNone;

    NSMutableDictionary *dataDict = [self dataForIndex: indexPath];
    cell.textLabel.text = dataDict[@"Name"];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dictAtIndex = [self dataForIndex:indexPath];
    NSString *title = [NSString stringWithFormat:@"Are you sure you want to delete \"%@\"?",dictAtIndex[@"Name"]];
    UIAlertController *popAlert = [UIAlertController
                                   alertControllerWithTitle:title
                                   message:@"This item will be deleted immediately. You can't undo this action."
                                   preferredStyle:
                                   UIAlertControllerStyleAlert];
    UIAlertAction* popCancelButton = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleCancel
                                      handler:^(UIAlertAction * action) {
                                      }];
    UIAlertAction* popOkButton = [UIAlertAction
                                  actionWithTitle:@"Delete"
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * action) {
                                      NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
                                      NSMutableDictionary *selectedDict = [self dataForIndex:indexPath];
                                      if([currentDict[@"Name"] isEqualToString:selectedDict[@"Name"]]){
                                          currentDict[@"Name"] = [self unsavedPrefernceString];
                                          [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0], indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
                                      }
                                      [_objects[indexPath.section] removeObjectAtIndex:indexPath.row];
                                      [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                                      [self saveObjects];
                                  }];
    [popAlert addAction:popCancelButton];
    [popAlert addAction:popOkButton];
    [self presentViewController:popAlert animated:YES completion:nil];
}

- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event {
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if (indexPath == nil) return;
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
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

-(NSDictionary *) activePlist {    
    CFStringRef onlyBundle = (__bridge CFStringRef)_defaultsBundleID;
    CFArrayRef arrayKeys = CFPreferencesCopyKeyList(onlyBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if(arrayKeys){
        CFDictionaryRef values = CFPreferencesCopyMultiple(arrayKeys, onlyBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        NSMutableDictionary *preferences = [CFBridgingRelease(values) mutableCopy];
        CFRelease(arrayKeys);
        return preferences;
    }
    NSString *pathToFile = [NSString stringWithFormat:@"%@/%@.plist", PREFERNCE_PATH, _defaultsBundleID];
    return [NSDictionary dictionaryWithContentsOfFile:pathToFile];
}

-(NSString *) defaultsBundleID {
    NSString *pathToBundle = [NSString stringWithFormat:@"%@/%@.bundle", PREFERNCE_BUNDLE_PATH, self.infoPlist[@"CFBundleExecutable"]];
    NSSet* dirs = [NSSet setWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToBundle error:nil]];
    NSString *backup = nil;
    for(NSString *filename in dirs){
        if([filename rangeOfString:@".plist"].location != NSNotFound) {
            NSString *dictString = [NSString stringWithFormat:@"%@/%@",pathToBundle, filename];
            NSDictionary *possibleDict = [NSDictionary dictionaryWithContentsOfFile:dictString];
            NSSet *itemSet = [NSSet setWithArray: possibleDict[@"items"]];
            if(itemSet){
                for(NSDictionary *cell in itemSet){
                    NSString *possibleDefaults = cell[@"defaults"];
                    if(possibleDefaults){
                        backup = possibleDefaults;
                        if([possibleDefaults rangeOfString:@"color" options:NSCaseInsensitiveSearch].location == NSNotFound){
                            return possibleDefaults;
                        }
                    }
                }
            }
        }
    }
    if(backup) return backup;
    else return _bundleID; //If it cant find it
}

-(void) saveObjects{
    if (@available(iOS 11, tvOS 11, *)) {
        [_objects writeToURL:[NSURL fileURLWithPath:_bundleIDPath]
                       error:nil];
    }
}

-(NSString *) unsavedPrefernceString{
    NSString *formated = @"Unsaved - Click here to save";
    return formated;
}

-(NSString *) singleNameForName:(NSString *)name{
    for(int i = 0; [self doesNameExist:name]; i++){
        NSString *removeString = [NSString stringWithFormat:@" (%i)", i];
        name = [name stringByReplacingOccurrencesOfString:removeString withString:@""];
        name = [NSString stringWithFormat:@"%@ (%i)", name, i + 1];
    }
    return name;
}

-(BOOL) doesNameExist:(NSString *)name{
    for(NSDictionary *dict in _objects.lastObject){
        if([dict[@"Name"] isEqualToString:name]){
            return YES;
        }
    }
    return NO;
}
    
-(void) updateCurrentCell{
    NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
    if (![currentDict[@"Plist"] isEqualToDictionary:[self activePlist]]) {
        NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
        currentDict[@"Name"] = [self unsavedPrefernceString];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
}

-(void) queuePush{
    MISQueueViewController *queueController = [[MISQueueViewController alloc] init];
    UIBarButtonItem *queueMore = [[UIBarButtonItem alloc] initWithTitle:@"Continue Queueing"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:nil
                                                                 action:nil];
    self.navigationItem.backBarButtonItem = queueMore;
    [self.navigationController pushViewController:queueController animated:YES];
}

-(UIView *) queueButtonView{
    UIButton *queueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [queueButton addTarget:self
                    action:@selector(accessoryButtonTapped:withEvent:)
          forControlEvents:UIControlEventTouchUpInside];
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                               NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:.478 blue:1 alpha:1]
                               };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"QUEUE" attributes:attrDict];
    [queueButton setAttributedTitle:attrString forState:UIControlStateNormal];
    UIView *queueView = [[UIView alloc] initWithFrame:CGRectMake(0, 16, 74, 26)];
    queueButton.frame = queueView.bounds;
    queueView.layer.cornerRadius = 13;
    queueView.layer.masksToBounds = YES;
    queueView.backgroundColor = [UIColor colorWithRed:.941 green:.941 blue:.969 alpha:1];
    queueView.alpha = 0;
    [queueView addSubview:queueButton];
    return queueView;
}

-(UIView *) checkedButtonView{
    UIButton *queueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [queueButton addTarget:self
                    action:@selector(queuePush)
          forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *checkImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checked.png"]];
    checkImgView.image = [checkImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    checkImgView.tintColor = [UIColor colorWithRed:0 green:.478 blue:1 alpha:1];
    checkImgView.frame = CGRectMake(10, 3, 20, 20);
    UIView *checkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 26)];
    checkView.layer.cornerRadius = 13;
    checkView.layer.masksToBounds = YES;
    checkView.backgroundColor = [UIColor colorWithRed:.941 green:.941 blue:.969 alpha:1];
    checkView.alpha = 0;
    
    queueButton.frame = checkView.bounds;
    [checkView addSubview:checkImgView];
    [checkView addSubview:queueButton];
    return checkView;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *shareDict = [[NSMutableDictionary alloc] init];
    
    shareDict[@"BundleID"] = _bundleID;
    shareDict[@"DefaultsBundleID"] = _defaultsBundleID;
    shareDict[@"BaseDict"] = [self dataForIndex:indexPath];
    
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    [sharingCont.queueArray addObject:shareDict];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [self checkedButtonView];
    if(sharingCont.queueArray.count == 0){
        self.navigationController.tabBarItem.badgeValue = nil;
    } else {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)sharingCont.queueArray.count];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section > 0 ? YES : NO;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0){
        UIAlertController *popAlert = [UIAlertController
                                       alertControllerWithTitle:@"New Save"
                                       message:nil
                                       preferredStyle:
                                       UIAlertControllerStyleAlert];
        [popAlert addTextFieldWithConfigurationHandler:^(UITextField *textField){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            dateFormatter.dateFormat = @"MM/dd/yy HH:mm";
            textField.text = [NSString stringWithFormat:@"%@ - %@", self.infoPlist[@"label"],[dateFormatter stringFromDate: [NSDate date]]];
        }];
        UIAlertAction* popCancelButton = [UIAlertAction
                                          actionWithTitle:@"Cancel"
                                          style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action) {
                                          }];
        UIAlertAction* popOkButton = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          NSString *inputText = [self singleNameForName: popAlert.textFields[0].text];
                                          NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
                                          dataDict[@"Name"] = inputText;
                                          dataDict[@"Plist"] = [self activePlist];
                                          [_objects.lastObject addObject: dataDict];
                                          [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:(((NSMutableArray *)_objects.lastObject).count - 1) inSection:_objects.count - 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                          NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
                                          currentDict[@"Name"] = inputText;
                                          currentDict[@"Plist"] = [self activePlist];
                                          
                                          [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                          [self saveObjects];
                                      }];
        [popAlert addAction:popCancelButton];
        [popAlert addAction:popOkButton];
        [self presentViewController:popAlert animated:YES completion:nil];
    }
    
    UIAlertController *alert = [UIAlertController
                                 alertControllerWithTitle:@"Options"
                                 message:nil
                                 preferredStyle:
                                 UIAlertControllerStyleActionSheet];
    
    UIAlertAction *makeCurrentButton = [UIAlertAction
                                        actionWithTitle:@"Make Current"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
                                            UIAlertController *popAlert = [UIAlertController
                                                                           alertControllerWithTitle:@"Unsaved Changes"
                                                                           message:[NSString stringWithFormat:@"%@ will be overriden. Would you like to save it first?", currentDict[@"Name"]]
                                                                           preferredStyle:
                                                                           UIAlertControllerStyleAlert];
                                            [popAlert addTextFieldWithConfigurationHandler:^(UITextField *textField){
                                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                                                dateFormatter.dateFormat = @"MM/dd/yy HH:mm";
                                                textField.text = [NSString stringWithFormat:@"Backup - %@",[dateFormatter stringFromDate: [NSDate date]]];
                                            }];
                                            UIAlertAction* popCancelButton = [UIAlertAction
                                                                              actionWithTitle:@"Cancel"
                                                                              style:UIAlertActionStyleCancel
                                                                              handler:^(UIAlertAction * action) {
                                                                              }];
                                            UIAlertAction* popContinueButton = [UIAlertAction
                                                                                actionWithTitle:@"Continue Anyways"
                                                                                style:UIAlertActionStyleDefault
                                                                                handler:^(UIAlertAction * action) {
                                                                                    NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                                                                                    NSMutableDictionary *selectedDict = [[self dataForIndex:indexPath] copy];
                                                                                    [_objects[currentIndex.section] addObject: [selectedDict mutableCopy]];
                                                                                    [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
                                                                                    
                                                                                    [_objects[currentIndex.section] removeObjectAtIndex: currentIndex.row];
                                                                                    [self.tableView deleteRowsAtIndexPaths: @[currentIndex] withRowAnimation:
                                                                                     UITableViewRowAnimationFade];
                                                                                    [MISSerializationController overideBundle:_defaultsBundleID withDict:selectedDict];
                                                                                    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                                                                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                                                                    [SVProgressHUD showWithStatus:@"Syncronizing"];
                                                                                    [SVProgressHUD dismissWithDelay:3];
                                                                                }];
                                            UIAlertAction* popOkButton = [UIAlertAction
                                                                          actionWithTitle:@"Save"
                                                                          style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                              currentDict[@"Name"] = [self singleNameForName:popAlert.textFields[0].text];
                                                                              [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0], indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
                                                                              NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                                                                              NSMutableDictionary *selectedDict = [[self dataForIndex:indexPath] copy];
                                                                              [_objects[currentIndex.section] addObject: [selectedDict mutableCopy]];
                                                                              [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
                                                                              
                                                                              [_objects[indexPath.section] addObject: currentDict];
                                                                              [_objects[currentIndex.section] removeObjectAtIndex: currentIndex.row];
                                                                              [self.tableView moveRowAtIndexPath: currentIndex toIndexPath: [NSIndexPath indexPathForRow:(((NSMutableArray *)_objects[indexPath.section]).count - 1) inSection:indexPath.section]];
                                                                              [self saveObjects];
                                                                              [MISSerializationController overideBundle:_defaultsBundleID withDict:selectedDict];
                                                                              [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                                                              [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                                                              [SVProgressHUD showWithStatus:@"Syncronizing"];
                                                                              [SVProgressHUD dismissWithDelay:3];
                                                                          }];
                                            if ([currentDict[@"Name"] containsString:@"Unsaved -"]) {
                                                [popAlert addAction:popOkButton];
                                                [popAlert addAction:popContinueButton];
                                                [popAlert addAction:popCancelButton];
                                                [self presentViewController:popAlert animated:YES completion:nil];
                                            } else {
                                                NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                                                NSMutableDictionary *selectedDict = [[self dataForIndex:indexPath] copy];
                                                [_objects[currentIndex.section] addObject: [selectedDict mutableCopy]];
                                                [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
                                                
                                                [_objects[currentIndex.section] removeObjectAtIndex: currentIndex.row];
                                                [self.tableView deleteRowsAtIndexPaths: @[currentIndex] withRowAnimation:
                                                 UITableViewRowAnimationFade];
                                                [self saveObjects];
                                                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                                [SVProgressHUD showWithStatus:@"Syncronizing"];
                                                [SVProgressHUD dismissWithDelay:3];
                                            }
                                        }];
    UIAlertAction *editButton = [UIAlertAction
                                     actionWithTitle:@"Edit Name"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         
                                         UIAlertController *popAlert = [UIAlertController
                                                                        alertControllerWithTitle:@"Edit Name"
                                                                        message:nil
                                                                        preferredStyle:
                                                                        UIAlertControllerStyleAlert];
                                         [popAlert addTextFieldWithConfigurationHandler:^(UITextField *textField){
                                             UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                                             textField.text = cell.textLabel.text;
                                         }];
                                         UIAlertAction* popCancelButton = [UIAlertAction
                                                                           actionWithTitle:@"Cancel"
                                                                           style:UIAlertActionStyleCancel
                                                                           handler:^(UIAlertAction * action) {
                                                                           }];
                                         UIAlertAction* popOkButton = [UIAlertAction
                                                                       actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           NSArray *section = _objects[indexPath.section];
                                                                           NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
                                                                           NSMutableDictionary *row = section[indexPath.row];
                                                                           if([currentDict[@"Name"] isEqualToString:row[@"Name"]]){
                                                                               currentDict[@"Name"] = [self singleNameForName:popAlert.textFields[0].text];
                                                                           }
                                                                           row[@"Name"] = [self singleNameForName:popAlert.textFields[0].text];
                                                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0], indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
                                                                           [self saveObjects];
                                                                       }];
                                         [popAlert addAction:popCancelButton];
                                         [popAlert addAction:popOkButton];
                                         [self presentViewController:popAlert animated:YES completion:nil];
                                     }];
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
    
    if(indexPath.section > 0)[alert addAction:makeCurrentButton];
    if(indexPath.section > 0)[alert addAction:editButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
