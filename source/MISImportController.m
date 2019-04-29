#import "MISImportController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"

@implementation MISImportController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];
    
    BOOL isDir;
    NSString *importPath = [NSString stringWithFormat:@"%@/object.plist", IMPORT_DIRECTORY_PATH];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:IMPORT_DIRECTORY_PATH isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:IMPORT_DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSMutableArray *savedObjects = [NSMutableArray arrayWithContentsOfFile:importPath];
    if(!savedObjects){
        _objects = [[NSMutableArray alloc] init];
    } else {
        _objects = savedObjects;
    }

    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.navigationItem setTitle:@"Import"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(import:)];
}

-(void) addImported{
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    NSMutableDictionary *holdDict = [[NSMutableDictionary alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yy HH:mm";
    holdDict[@"Name"] = [NSString stringWithFormat:@"Bundle - %@",[dateFormatter stringFromDate: [NSDate date]]];
    holdDict[@"Array"] = sharingCont.importArray;
    [_objects addObject:holdDict];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveObjects];
}
- (void)import:(id)sender {
    
    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteString = generalPasteboard.string;
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *matches = [detector matchesInString:pasteString
                                         options:0
                                           range:NSMakeRange(0, [pasteString length])];
    if(matches.count > 0){
        // do link stuff
    }
    NSMutableArray *deserialArray = [MISSerializationController deserializeArrayFromString:pasteString];
    if(deserialArray){
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Import"
                                    message:@"Will import from pasteboard."
                                    preferredStyle:
                                    UIAlertControllerStyleAlert];
        
        UIAlertAction *continueButton = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             MISSharingController *shareCont = [MISSharingController sharedInstance];
                                             for(NSMutableDictionary *dict in deserialArray){
                                                 [shareCont.importArray addObject: dict];
                                             }
                                             [self addImported];
                                         }];
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle no, thanks button
                                       }];
        
        [alert addAction:cancelButton];
        [alert addAction:continueButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Error"
                                    message:@"Cannot import from pasteboard. Check that you've selected the entire string."
                                    preferredStyle:
                                    UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"Dismiss"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle no, thanks button
                                       }];
        
        [alert addAction:cancelButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void) saveObjects{
    if (@available(iOS 11, tvOS 11, *)) {
        NSString *importPath = [NSString stringWithFormat:@"%@/object.plist", IMPORT_DIRECTORY_PATH];
        [_objects writeToURL:[NSURL fileURLWithPath:importPath]
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
        NSString *removeString = [NSString stringWithFormat:@" (%i)", i - 1];
        name = [name stringByReplacingOccurrencesOfString:removeString withString:@""];
        name = [NSString stringWithFormat:@"%@ (%i)", name, i];
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
    NSString *message = nil;
    NSMutableDictionary *row = _objects[indexPath.row];
    NSMutableArray *holdArray = row[@"Array"];
    for(NSMutableDictionary *holdDict in holdArray){
        NSString *bundleId = holdDict[@"BundleID"];
        if(!message) message = bundleId;
        else message = [NSString stringWithFormat:@"%@\n%@", message, bundleId];
    }

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"BundleIDs"
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
                                        actionWithTitle:@"Enable"
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
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
    
    [alert addAction:activeButton];
    [alert addAction:editNameButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
