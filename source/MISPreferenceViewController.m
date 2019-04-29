#import "MISPreferenceViewController.h"
#import "MISDetailViewController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"


@implementation MISPreferenceViewController {
	NSMutableArray *_objects;
    NSString *_bundleIdPath;
}

- (void)loadView {
	[super loadView];
    
    BOOL isDir;
    _bundleIdPath = [NSString stringWithFormat:@"%@/%@", DIRECTORY_PATH, self.bundleID];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:DIRECTORY_PATH isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSMutableArray *savedObjects = [NSMutableArray arrayWithContentsOfFile:_bundleIdPath];
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
    for(NSMutableDictionary *importDict in [[MISSharingController sharedInstance] arrayOfImportsForBundle:self.bundleID]){
        NSMutableDictionary *dict = [importDict mutableCopy];
        [_objects.lastObject addObject: dict];
        dict[@"Name"] = [self singleNameForName:dict[@"Name"]];
        [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:(((NSMutableArray *)_objects.lastObject).count - 1) inSection:_objects.count - 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self saveObjects];
    }
    
    [self updateCurrentCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentCell)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
	
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    for(NSMutableDictionary *importDict in [[MISSharingController sharedInstance] arrayOfImportsForBundle:self.bundleID]){
        NSMutableDictionary *dict = [importDict mutableCopy];
        [_objects.lastObject addObject: dict];
        dict[@"Name"] = [self singleNameForName:dict[@"Name"]];
        [self.tableView insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:(((NSMutableArray *)_objects.lastObject).count - 1) inSection:_objects.count - 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self saveObjects];
    }
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
    if(indexPath.section > 0) cell.accessoryType = UITableViewCellAccessoryDetailButton;
    else cell.accessoryType = UITableViewCellAccessoryNone;

    NSMutableDictionary *dataDict = [self dataForIndex: indexPath];
    cell.textLabel.text = dataDict[@"Name"];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
    NSMutableDictionary *selectedDict = [self dataForIndex:indexPath];
    if([currentDict[@"Name"] isEqualToString:selectedDict[@"Name"]]){
        currentDict[@"Name"] = [self unsavedPrefernceString];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0], indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
	[_objects[indexPath.section] removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveObjects];
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

-(NSString *) pathToPreferenceFromBundleID:(NSString *) bundle{
    return [NSString stringWithFormat: @"%@/%@", PREFERNCE_PATH, bundle];
}

-(id) dataForIndex:(NSIndexPath *) indexPath {
    NSArray *section = _objects[indexPath.section];
    return section[indexPath.row];
}

-(NSDictionary *) activePlist {
    NSString *onlyBundle = [self.bundleID stringByReplacingOccurrencesOfString:@".plist" withString:@""];
    CFPreferencesSynchronize((__bridge CFStringRef)onlyBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSString *pathToActive = [self pathToPreferenceFromBundleID:self.bundleID];
    return [NSDictionary dictionaryWithContentsOfFile: pathToActive];
}
-(void) saveObjects{
    if (@available(iOS 11, tvOS 11, *)) {
        [_objects writeToURL:[NSURL fileURLWithPath:_bundleIdPath]
                       error:nil];
    }
    
    NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
    [MISSerializationController overideBundle:self.bundleID withDict:currentDict];
}

-(NSString *) unsavedPrefernceString{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDate *prefEditDate = [[fileManager attributesOfItemAtPath:[self pathToPreferenceFromBundleID:self.bundleID] error:NULL] fileModificationDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yy HH:mm";
    NSString *formated = [NSString stringWithFormat:@"Unsaved - %@",[dateFormatter stringFromDate: prefEditDate]];
    return formated;
}

-(NSString *) singleNameForName:(NSString *)name{
    for(int i = 1; [self doesNameExist:name]; i++){
        NSString *removeString = [NSString stringWithFormat:@" (%i)", i - 1];
        name = [name stringByReplacingOccurrencesOfString:removeString withString:@""];
        name = [NSString stringWithFormat:@"%@ (%i)", name, i];
    }
    return name;
}

-(BOOL) doesNameExist:(NSString *)name{
    BOOL doesExist = NO;
    for(NSDictionary *dict in _objects.lastObject){
        if([dict[@"Name"] isEqualToString:name]){
            doesExist = YES;
            return doesExist;
        } else {
            doesExist = NO;
        }
    }
    return doesExist;
}
    
-(void) updateCurrentCell{
    NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
    if (![currentDict[@"Plist"] isEqualToDictionary:[self activePlist]]) {
        NSMutableDictionary *currentDict = ((NSArray *)_objects.firstObject).firstObject;
        currentDict[@"Name"] = [self unsavedPrefernceString];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MISDetailViewController *detailController = [[MISDetailViewController alloc] init];
    [detailController.navigationItem setTitle: cell.textLabel.text];
    detailController.bundleID = self.bundleID;
    detailController.shareDict = [self dataForIndex:indexPath];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section > 0 ? YES : NO;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0){
        UIAlertController *popAlert = [UIAlertController
                                       alertControllerWithTitle:@"New Preference"
                                       message:nil
                                       preferredStyle:
                                       UIAlertControllerStyleAlert];
        [popAlert addTextFieldWithConfigurationHandler:^(UITextField *textField){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            dateFormatter.dateFormat = @"MM/dd/yy HH:mm";
            textField.text = [NSString stringWithFormat:@"Backup - %@",[dateFormatter stringFromDate: [NSDate date]]];
        }];
        UIAlertAction* popCancelButton = [UIAlertAction
                                          actionWithTitle:@"Cancel"
                                          style:UIAlertActionStyleDefault
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
                                                                              style:UIAlertActionStyleDefault
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
                                                                                    [self saveObjects];
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
                                            }
                                        }];
    UIAlertAction *editNameButton = [UIAlertAction
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
                                                                       style:UIAlertActionStyleDefault
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
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
    
    if(indexPath.section > 0)[alert addAction:makeCurrentButton];
    if(indexPath.section > 0)[alert addAction:editNameButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
