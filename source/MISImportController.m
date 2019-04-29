#import "MISImportController.h"
#import "MISSerializationController.h"
#import "MISSharingController.h"

@implementation MISImportController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];
    
    _objects = [[NSMutableArray alloc] init];

    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.navigationItem setTitle:@"Import"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(import:)];
}

-(void) refreshCells{
    MISSharingController *sharingCont = [MISSharingController sharedInstance];
    [_objects addObject:sharingCont.importArray];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)import:(id)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Import"
                                message:@"Will import from pasteboard."
                                preferredStyle:
                                UIAlertControllerStyleAlert];
    
    UIAlertAction *continueButton = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
                                         NSString *pasteString = generalPasteboard.string;
                                         
                                         NSError *error = nil;
                                         NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
                                         NSArray *matches = [detector matchesInString:pasteString
                                                                              options:0
                                                                                range:NSMakeRange(0, [pasteString length])];
                                         if(matches.count > 0){
                                             // do link stuff
                                         } else {
                                             NSMutableArray *deserialArray = [MISSerializationController deserializeArrayFromString:pasteString];
                                             
                                             MISSharingController *shareCont = [MISSharingController sharedInstance];
                                             for(NSMutableDictionary *dict in deserialArray){
                                                 [shareCont.importArray addObject: dict];
                                             }
                                         }
                                         [self refreshCells];
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
    
    // _objects[indexPath.row]
    cell.textLabel.text = @"Import";
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[_objects removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
