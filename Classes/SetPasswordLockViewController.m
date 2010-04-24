//
//  SetPasswordLockViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SetPasswordLockViewController.h"
#import "TextFieldCell.h"
#import "UIViewController+SpinnerView.h"
#import "SettingsViewController.h"
#import "RackspaceAppDelegate.h"


@implementation SetPasswordLockViewController

@synthesize newPasswordTextField, confirmPasswordTextField;
@synthesize settingsViewController;

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
    NSNumber *enabled = [defaults objectForKey:@"password_lock_enabled"];
    [self.settingsViewController.passwordLockSwitch setOn:[enabled boolValue] animated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {
    
    NSLog(@"new password: %@", newPasswordTextField.text);
    NSLog(@"confirm password: %@", confirmPasswordTextField.text);
    
    if ([newPasswordTextField.text isEqualToString:@""]) {
        [self alert:@"Error" message:@"Please enter a password."];
    } else if ([confirmPasswordTextField.text isEqualToString:@""]) {
        [self alert:@"Error" message:@"Please confirm your password."];
    } else if ([newPasswordTextField.text isEqualToString:confirmPasswordTextField.text]) {
        // we're all good
        [defaults setObject:newPasswordTextField.text forKey:@"lock_password"];
        [defaults synchronize];
        [self dismissModalViewControllerAnimated:YES];
        [self.settingsViewController.tableView reloadData];

        RackspaceAppDelegate *app = [[UIApplication sharedApplication] delegate];
        app.isPasswordLocked = YES;
    } else {
        [self alert:@"Error" message:@"The password and confirmation do not match."];
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    defaults = [NSUserDefaults standardUserDefaults];
}

- (void)viewDidAppear:(BOOL)animated {
    [newPasswordTextField becomeFirstResponder];
    [super viewDidAppear:animated];
}

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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Enter a New Password";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TextFieldCell *cell;
    
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"NewCell";
        cell = (TextFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            cell.textField.secureTextEntry = YES;
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.delegate = self;
            newPasswordTextField = cell.textField;
            cell.textLabel.text = @"Password";
        }
    } else {
        static NSString *CellIdentifier = @"ConfirmCell";
        cell = (TextFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            cell.textField.secureTextEntry = YES;
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.delegate = self;
            confirmPasswordTextField = cell.textField;
            cell.textLabel.text = @"Confirm";
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == newPasswordTextField) {
        [confirmPasswordTextField becomeFirstResponder];
    } else if (textField == confirmPasswordTextField) {
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [newPasswordTextField release];
    [confirmPasswordTextField release];
    [settingsViewController release];
    [super dealloc];
}


@end

