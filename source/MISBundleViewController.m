#import "MISBundleViewController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"
#import "NSTask.h"
#import "../External/SVProgressHUD/SVProgressHUD.h"

@implementation MISBundleViewController {
	NSMutableArray *_objects;
    NSString *_savedBundlePath;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
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
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [info addTarget:self action:@selector(infoIcon:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:info];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self transferFromQueue];
}

-(void) infoIcon:(id)sender{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Bundles"
                                message:@"Bundles are groups of preferences that can be activated together. This is useful for saving and switching between setups. Missito uses this format to share."
                                preferredStyle:
                                UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Dismiss"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
    
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    holdDict[@"Name"] = [NSString stringWithFormat:@"%lu Prefs - %@", array.count,[dateFormatter stringFromDate: [NSDate date]]];
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

-(void) handleURL:(NSURL *) url{
    [self.tabBarController setSelectedIndex:1];
    NSURL *urlRawPaste = [self sourceURLFromSharingString:url.absoluteString];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlRawPaste];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(data){
            NSMutableDictionary *dict = [MISSerializationController deserializeDictionaryFromData:data];
            [self importDictionary:dict];
        } else {
            NSURLSessionDataTask *task2 = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                if(data){
                    NSMutableDictionary *dict = [MISSerializationController deserializeDictionaryFromData:data];
                    [self importDictionary:dict];
                } else {
                    [self importDictionary:nil];
                }
            }];
            [task2 resume];
        }
    }];
    [task resume];
}


-(void) importDictionary:(NSMutableDictionary *) deserialDict{
    UIAlertController *alert = nil;
    UIAlertAction *continueButton = nil;
    UIAlertAction *cancelButton = nil;
    
    if(deserialDict){
        alert = [UIAlertController
                 alertControllerWithTitle:@"Import"
                 message:@"Importing from link."
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
                        style:UIAlertActionStyleCancel
                        handler:^(UIAlertAction * action) {
                            //Handle no, thanks button
                        }];
        
        [alert addAction:cancelButton];
        [alert addAction:continueButton];
    } else {
        alert = [UIAlertController
                 alertControllerWithTitle:@"Error"
                 message:@"Cannot import, not in the correct format."
                 preferredStyle:
                 UIAlertControllerStyleAlert];
        cancelButton = [UIAlertAction
                        actionWithTitle:@"Dismiss"
                        style:UIAlertActionStyleCancel
                        handler:^(UIAlertAction * action) {
                            //Handle no, thanks button
                        }];
        
        [alert addAction:cancelButton];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)import:(id)sender {
    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteString = generalPasteboard.string;
    if(pasteString){
        NSURL *urlRawPaste = [self sourceURLFromSharingString:pasteString];
        NSURLRequest *request = [NSURLRequest requestWithURL:urlRawPaste];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(data){
                NSMutableDictionary *dict = [MISSerializationController deserializeDictionaryFromData:data];
                [self importDictionary:dict];
            } else {
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"Error"
                                            message:@"Incorrect link in pasteboard."
                                            preferredStyle:
                                            UIAlertControllerStyleAlert];
                UIAlertAction *cancelButton = [UIAlertAction
                                               actionWithTitle:@"Dismiss"
                                               style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction * action) {
                                                   //Handle no, thanks button
                                               }];
                
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        [task resume];
    } else {
        UIAlertController *alert = [UIAlertController
                 alertControllerWithTitle:@"Error"
                 message:@"Cannot import from pasteboard. Pasteboard is empty."
                 preferredStyle:
                 UIAlertControllerStyleAlert];
        UIAlertAction *cancelButton = [UIAlertAction
                        actionWithTitle:@"Dismiss"
                        style:UIAlertActionStyleCancel
                        handler:^(UIAlertAction * action) {
                            //Handle no, thanks button
                        }];
        
        [alert addAction:cancelButton];
         [self presentViewController:alert animated:YES completion:nil];
    }
}

-(NSURL *) sourceURLFromSharingString:(NSString *) string{
    NSArray *urlComp = [string componentsSeparatedByString:@"?"];
    NSString *identifier = urlComp.lastObject;
    NSString *pasteLink = [NSString stringWithFormat:@"https://pastecode.xyz/view/raw/%@", identifier];
    return [NSURL URLWithString:pasteLink];
}

-(void) saveObjects{
    if (@available(iOS 11, tvOS 11, *)) {
        [_objects writeToURL:[NSURL fileURLWithPath:_savedBundlePath]
                       error:nil];
    }
}

-(void) shareDictionary:(NSMutableDictionary *)dict forExpire:(double) expire{
    NSString *serialDict = [MISSerializationController serializeDictionary:dict];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://pastecode.xyz/api/create"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSString *body = [NSString stringWithFormat: @"text=%@&title=%@&expire=%f&name=%@",serialDict, dict[@"Name"], expire, @"Missito-Share"];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *pasteOutput = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *pasteComp = [pasteOutput componentsSeparatedByString:@"/"];
        NSString *identifier = pasteComp.lastObject;
        identifier = [identifier stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *shareLink = [NSString stringWithFormat:@"https://the-casle.github.io/missito?%@", identifier];
        NSArray *activityItems = @[shareLink];
        NSArray *applicationActivities = nil;
        NSArray *excludeActivities = @[UIActivityTypePrint];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        activityController.excludedActivityTypes = excludeActivities;
        [self presentViewController:activityController animated:YES completion:nil];
    }];
    [task resume];
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
    NSMutableDictionary *dictAtIndex = _objects[indexPath.row];
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
                                      [_objects removeObjectAtIndex:indexPath.row];
                                      [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                                      [self saveObjects];
                                  }];
    [popAlert addAction:popCancelButton];
    [popAlert addAction:popOkButton];
    [self presentViewController:popAlert animated:YES completion:nil];
}

#pragma mark - Utility
-(NSString *) singleNameForName:(NSString *)name{
    for(int i = 0; [self doesNameExist:name]; i++){
        NSString *removeString = [NSString stringWithFormat:@" (%i)", i];
        name = [name stringByReplacingOccurrencesOfString:removeString withString:@""];
        name = [NSString stringWithFormat:@"%@ (%i)", name, i + 1];
    }
    return name;
}

-(BOOL) doesNameExist:(NSString *)name{
    for(NSDictionary *dict in _objects){
        if([dict[@"Name"] isEqualToString:name]){
            return YES;
        }
    }
    return NO;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *message = @"";
    NSMutableDictionary *row = _objects[indexPath.row];
    NSMutableArray *holdArray = row[@"Array"];
    for(NSMutableDictionary *holdDict in holdArray){
        NSString *bundleId = holdDict[@"BundleID"];
        message = [NSString stringWithFormat:@"%@\n%@", message, bundleId];
    }

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Contains the Following Preferences:"
                                message:message
                                preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Dismiss"
                                   style:UIAlertActionStyleCancel
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
                                                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                                [SVProgressHUD showWithStatus:@"Syncronizing"];
                                                [SVProgressHUD dismissWithDelay:3];
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
                                                                           style:UIAlertActionStyleCancel
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
                                       NSMutableDictionary *bundleDict =  _objects[indexPath.row];
                                       UIAlertController *alert = [UIAlertController
                                                                   alertControllerWithTitle:@"Expiration"
                                                                   message:nil
                                                                   preferredStyle:
                                                                   UIAlertControllerStyleActionSheet];
                                       
                                       UIAlertAction *thirtyMins = [UIAlertAction
                                                                      actionWithTitle:@"30 Minutes"
                                                                      style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          
                                                                          [self shareDictionary:bundleDict forExpire:30];
                                                                      }];
                                       UIAlertAction *oneDay = [UIAlertAction
                                                                        actionWithTitle:@"One Day"
                                                                        style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                                                                            [self shareDictionary:bundleDict forExpire:1440];
                                                                        }];
                                       
                                       UIAlertAction *oneMonth = [UIAlertAction
                                                                     actionWithTitle:@"One Month"
                                                                     style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [self shareDictionary:bundleDict forExpire:43800];
                                                                     }];
                                       UIAlertAction *forever = [UIAlertAction
                                                                  actionWithTitle:@"Forever"
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self shareDictionary:bundleDict forExpire:1051200]; // Ha not actaully forever
                                                                  }];
                                       UIAlertAction* cancelButton = [UIAlertAction
                                                                      actionWithTitle:@"Cancel"
                                                                      style:UIAlertActionStyleCancel
                                                                      handler:^(UIAlertAction * action) {
                                                                          //Handle no, thanks button
                                                                      }];
                                       
                                       [alert addAction:thirtyMins];
                                       [alert addAction:oneDay];
                                       [alert addAction:oneMonth];
                                       [alert addAction:forever];
                                       [alert addAction:cancelButton];
                                       
                                       [self presentViewController:alert animated:YES completion:nil];

                                       
                                   }];
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
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
