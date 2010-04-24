//
//  PasswordLockViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PasswordLockViewController.h"
//#import "MasterViewController.h"
#import "TextFieldCell.h"
#import "UIViewController+SpinnerView.h"
#import "SettingsViewController.h"
#import "RackspaceAppDelegate.h"

@implementation PasswordLockViewController

@synthesize callback, masterViewController, settingsViewController;

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
    if (self.masterViewController != nil) {
        [self.masterViewController preselect];
    } else if (self.settingsViewController != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *enabled = [defaults objectForKey:@"password_lock_enabled"];
        [self.settingsViewController.passwordLockSwitch setOn:![enabled boolValue] animated:YES];
    }
	[self dismissModalViewControllerAnimated:YES];
}

-(void)loginButtonPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *correctPassword = [defaults stringForKey:@"lock_password"];
    
    if ([textField.text isEqualToString:correctPassword]) {        
        if (self.masterViewController != nil && [self.masterViewController respondsToSelector:callback]) {
            NSMethodSignature *signature = [self.masterViewController methodSignatureForSelector:callback];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self.masterViewController];
            [invocation setSelector:callback];
            [invocation invoke];
        } else if (self.settingsViewController != nil && [self.settingsViewController respondsToSelector:callback]) {
            NSMethodSignature *signature = [self.settingsViewController methodSignatureForSelector:callback];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self.settingsViewController];
            [invocation setSelector:callback];
            [invocation invoke];            
        }
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self alert:@"Login Failed" message:@"The password you provided is incorrect.  Please try again."];
    }
}


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [textField becomeFirstResponder];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Enter Your Password";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TextFieldCell *cell = (TextFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
        textField = cell.textField;
        textField.secureTextEntry = YES;
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyGo;
        cell.textLabel.text = @"Password";
    }
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    [self loginButtonPressed:nil];
    return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [masterViewController release];
    [settingsViewController release];
    [super dealloc];
}


@end

