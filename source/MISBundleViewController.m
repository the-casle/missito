#import "MISBundleViewController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"

@implementation MISBundleViewController {
	NSMutableArray *_objects;
    NSString *_savedBundlePath;
}

- (void)loadView {
	[super loadView];
    
    BOOL isDir;
    _savedBundlePath = [NSString stringWithFormat:@"%@/SavedBundles.plist", IMPORT_DIRECTORY_PATH];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:IMPORT_DIRECTORY_PATH isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:IMPORT_DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSMutableArray *savedObjects = [NSMutableArray arrayWithContentsOfFile:_savedBundlePath];
    if(!savedObjects){
        _objects = [[NSMutableArray alloc] init];
    } else {
        _objects = savedObjects;
    }
    

    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.navigationItem setTitle:@"Bundles"];
    
    [self transferFromQueue];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(import:)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self transferFromQueue];
}

-(void) transferFromQueue{
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    if(sharingCont.bundleArray.count > 0){
        [self includingArray:sharingCont.bundleArray];
    }
    sharingCont.bundleArray = [[NSMutableArray alloc] init];
}

-(void) includingArray:(NSMutableArray *) array{
    NSMutableDictionary *holdDict = [[NSMutableDictionary alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yy HH:mm";
    holdDict[@"Name"] = [NSString stringWithFormat:@"Bundle - %@",[dateFormatter stringFromDate: [NSDate date]]];
    holdDict[@"Name"] = [self singleNameForName:holdDict[@"Name"]];
    holdDict[@"Array"] = array;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ // Make sure the animation is there.
        [_objects addObject:holdDict];
        [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:(_objects.count - 1) inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self saveObjects];
    });
}

-(void) addImported:(NSMutableDictionary *)dict{
    dict = [dict mutableCopy];
    dict[@"Name"] = [self singleNameForName:dict[@"Name"]];
    [_objects addObject:dict];
    
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:(_objects.count - 1) inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveObjects];
}
- (void)import:(id)sender {
    
    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteString = generalPasteboard.string;
    
    UIAlertController *alert = nil;
    UIAlertAction *continueButton = nil;
    UIAlertAction* cancelButton = nil;
    
    if(pasteString){
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        NSArray *matches = [detector matchesInString:pasteString
                                             options:0
                                               range:NSMakeRange(0, [pasteString length])];
        if(matches.count > 0){
            // do link stuff
        }
        NSMutableDictionary *deserialDict = [MISSerializationController deserializeDictionaryFromString:pasteString];
        if(deserialDict){
            alert = [UIAlertController
                                        alertControllerWithTitle:@"Import"
                                        message:@"Will import from pasteboard."
                                        preferredStyle:
                                        UIAlertControllerStyleAlert];
            
            continueButton = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 MISSharingController *shareCont = [MISSharingController sharedInstance];
                                                 NSMutableArray *array = deserialDict[@"Array"];
                                                 [shareCont writeToFileImportArray:array];
                                                 [self addImported:deserialDict];
                                             }];
            cancelButton = [UIAlertAction
                                           actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               //Handle no, thanks button
                                           }];
            
            [alert addAction:cancelButton];
            [alert addAction:continueButton];
        } else {
            alert = [UIAlertController
                                        alertControllerWithTitle:@"Error"
                                        message:@"Cannot import from pasteboard. Check that you've selected the entire string."
                                        preferredStyle:
                                        UIAlertControllerStyleAlert];
            cancelButton = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               //Handle no, thanks button
                                           }];
            
            [alert addAction:cancelButton];
        }
    } else {
        alert = [UIAlertController
                 alertControllerWithTitle:@"Error"
                 message:@"Cannot import from pasteboard. Pasteboard is empty."
                 preferredStyle:
                 UIAlertControllerStyleAlert];
        cancelButton = [UIAlertAction
                        actionWithTitle:@"Dismiss"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            //Handle no, thanks button
                        }];
        
        [alert addAction:cancelButton];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) saveObjects{
    if (@available(iOS 11, tvOS 11, *)) {
        [_objects writeToURL:[NSURL fileURLWithPath:_savedBundlePath]
                       error:nil];
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
	}
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    NSMutableDictionary *row = _objects[indexPath.row];
    cell.textLabel.text = row[@"Name"];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[_objects removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
     [self saveObjects];
}

#pragma mark - Utility

-(NSString *) pathToPreferenceFromBundleID:(NSString *) bundle{
    return [NSString stringWithFormat: @"%@/%@", PREFERNCE_PATH, bundle];
}

-(NSString *) singleNameForName:(NSString *)name{
    for(int i = 1; [self doesNameExist:name]; i++){
        unichar end = [name characterAtIndex:(name.length-2)];
        if(end>='0' && end<='9'){
            NSString *removeString = [NSString stringWithFormat:@" (%c)", end];
            name = [name stringByReplacingOccurrencesOfString:removeString withString:@""];
            name = [NSString stringWithFormat:@"%@ (%i)", name, i];
        }
    }
    return name;
}

-(BOOL) doesNameExist:(NSString *)name{
    BOOL doesExist = NO;
    for(NSDictionary *dict in _objects){
        if([dict[@"Name"] isEqualToString:name]){
            doesExist = YES;
            return doesExist;
        } else {
            doesExist = NO;
        }
    }
    return doesExist;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *message = @"Bundles are groups of preferences:\n";
    NSMutableDictionary *row = _objects[indexPath.row];
    NSMutableArray *holdArray = row[@"Array"];
    for(NSMutableDictionary *holdDict in holdArray){
        NSString *bundleId = holdDict[@"BundleID"];
        message = [NSString stringWithFormat:@"%@\n%@", message, bundleId];
    }

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Details"
                                message:message
                                preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Dismiss"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
    
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Options"
                                message:nil
                                preferredStyle:
                                UIAlertControllerStyleActionSheet];
    
    UIAlertAction *activeButton = [UIAlertAction
                                        actionWithTitle:@"Activate"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            NSMutableDictionary *row = _objects[indexPath.row];
                                            NSMutableArray *holdArray = row[@"Array"];
                                            for(NSMutableDictionary *holdDict in holdArray){
                                                NSString *bundleId = holdDict[@"BundleID"];
                                                NSMutableDictionary *baseDict = holdDict[@"BaseDict"];
                                                [MISSerializationController overideBundle:bundleId withDict: baseDict];
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
                                                                           NSMutableDictionary *row = _objects[indexPath.row];
                                                                           row[@"Name"] = [self singleNameForName:popAlert.textFields[0].text];
                                                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0], indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
                                                                           [self saveObjects];
                                                                       }];
                                         [popAlert addAction:popCancelButton];
                                         [popAlert addAction:popOkButton];
                                         [self presentViewController:popAlert animated:YES completion:nil];
                                     }];
    
    UIAlertAction *shareButton = [UIAlertAction
                                   actionWithTitle:@"Share"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       NSString *serialDict = [MISSerializationController serializeDictionary:_objects[indexPath.row]];
                                       NSArray *activityItems = @[serialDict];
                                       NSArray *applicationActivities = nil;
                                       NSArray *excludeActivities = @[UIActivityTypePrint];
                                       UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
                                       activityController.excludedActivityTypes = excludeActivities;
                                       [self presentViewController:activityController animated:YES completion:nil];
                                   }];
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
    
    [alert addAction:activeButton];
    [alert addAction:editNameButton];
    [alert addAction:shareButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
