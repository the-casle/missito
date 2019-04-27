#import "MISPreferenceViewController.h"
#import "MISDetailViewController.h"

#define PREFERNCE_PATH @"/private/var/mobile/Library/Preferences"

@implementation MISPreferenceViewController {
	NSMutableArray *_objects;
}

- (void)loadView {
	[super loadView];
    
	_objects = [[NSMutableArray alloc] init];
    NSMutableArray *firstSection = [[NSMutableArray alloc] init];
    [firstSection addObject:@"Filler Name"];
    NSMutableArray *secondSection = [[NSMutableArray alloc] init];
    [secondSection addObject:@"Other cell"];
    [secondSection addObject:@"Boo"];
    [secondSection addObject:@"Yuh"];
    [secondSection addObject:@"name"];
    [_objects insertObject:firstSection atIndex:0];
    [_objects insertObject:secondSection atIndex:1];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;

    cell.textLabel.text = [self dataForIndex: indexPath];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	/*[_objects removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];*/
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
#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MISDetailViewController *detailController = [[MISDetailViewController alloc] init];
    [detailController.navigationItem setTitle: cell.textLabel.text];
    detailController.bundleID = self.bundleID;
    [self.navigationController pushViewController:detailController animated:YES];
}
- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Options"
                                 message:nil
                                 preferredStyle:
                                 UIAlertControllerStyleActionSheet];
    
    UIAlertAction* makeCurrentButton = nil;
    if(indexPath.section > 0){
        makeCurrentButton = [UIAlertAction
                             actionWithTitle:@"Make Current"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                                 NSDictionary *currentDict = [self dataForIndex:currentIndex];
                                 NSDictionary *selectedDict = [self dataForIndex:indexPath];
                                 [_objects[currentIndex.section] addObject: selectedDict];
                                 [_objects[indexPath.section] removeObjectAtIndex: indexPath.row];
                                 [self.tableView moveRowAtIndexPath: indexPath toIndexPath: [NSIndexPath indexPathForRow:1 inSection:0]];
                                 [self.tableView reloadData];
                                 
                                 [_objects[indexPath.section] addObject: currentDict];
                                 [_objects[currentIndex.section] removeObjectAtIndex: currentIndex.row];
                                 [self.tableView moveRowAtIndexPath: currentIndex toIndexPath: [NSIndexPath indexPathForRow:(((NSMutableArray *)_objects[indexPath.section]).count - 1) inSection:indexPath.section]];
                             }];
    }
    
    UIAlertAction* editNameButton = [UIAlertAction
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
                                                                              [_objects[indexPath.section] replaceObjectAtIndex: indexPath.row withObject:popAlert.textFields[0].text];
                                                                              [self.tableView reloadData];
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
    [alert addAction:editNameButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
