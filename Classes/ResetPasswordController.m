//
//  ResetPasswordController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/26/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "ResetPasswordController.h"
#import "SecureEditableCell.h"
#import "Server.h"
#import "ServerViewController.h"
#import "RoundedRectView.h"
#import "Response.h"

@implementation ResetPasswordController

@synthesize passwordCell, confirmPasswordCell, server, serverViewController, spinnerView, footerView;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.passwordCell = [[SecureEditableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"PasswordCell"];
		self.confirmPasswordCell = [[SecureEditableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ConfirmPasswordCell"];
		
		self.passwordCell.labelField.text = NSLocalizedString(@"Password", @"Password cell label");
		self.confirmPasswordCell.labelField.text = NSLocalizedString(@"Confirm Password", @"Confirm password cell label");
		
		self.navigationItem.title = NSLocalizedString(@"Reset Password", @"Reset Password navigation title");
		
		self.passwordCell.textField.keyboardType = UIKeyboardTypeDefault;
		self.passwordCell.textField.delegate = self;	
		self.confirmPasswordCell.textField.keyboardType = UIKeyboardTypeDefault;
		self.confirmPasswordCell.textField.delegate = self;	
		
		// show a rounded rect view
		self.spinnerView = [[RoundedRectView alloc] initWithDefaultFrame];
		[self.view addSubview:self.spinnerView];

		self.tableView.scrollEnabled = NO;
		
    }
    return self;
}

- (void)viewDidLoad {
	
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, footerView.frame.size.height);
	footerView.backgroundColor = [UIColor clearColor];
	footerView.frame = newFrame;
	self.tableView.tableFooterView = self.footerView;	// note this will override UITableView's 'sectionFooterHeight' property

    [super viewDidLoad];	
}	

#pragma mark Keyboard Handler

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if ([self.passwordCell.textField isFirstResponder]) {
		[self.confirmPasswordCell.textField becomeFirstResponder];
	} else {
		[self.confirmPasswordCell.textField resignFirstResponder];		
	}
	
	return YES;
}


#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"Enter a new password", @"Enter a new password table section header");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return NSLocalizedString(@"The root password will be updated and the server will be restarted. Please note that this process will only work if you have a user line for \"root\" in your passwd or shadow file.", @"Change password warning");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return passwordCell;
	} else {
		return confirmPasswordCell;
	}
}

#pragma mark Spinner Methods

- (void)showSpinnerViewInThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.tableView.contentOffset = CGPointMake(0, 0);
	[self.spinnerView show];
	[pool release];
}

- (void)hideSpinnerViewInThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self.spinnerView hide];
	[pool release];
}

- (void)showSpinnerView {
	self.view.userInteractionEnabled = NO;
	[NSThread detachNewThreadSelector:@selector(showSpinnerViewInThread) toTarget:self withObject:nil];
}

- (void)hideSpinnerView {
	self.view.userInteractionEnabled = YES;
	[NSThread detachNewThreadSelector:@selector(hideSpinnerViewInThread) toTarget:self withObject:nil];
}

#pragma mark Button Handlers

- (void)saveButtonPressed:(id)sender {
	
	// see if they match, and if so, set it and pop the view controller
	if ([self.passwordCell.textField.text isEqualToString:@""] || [self.confirmPasswordCell.textField.text isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"The password and confirmation cannot be blank and must be the same value.", @"Password validation alert message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	} else if (![self.passwordCell.textField.text isEqualToString:self.confirmPasswordCell.textField.text]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"The password and confirmation cannot be blank and must be the same value.", @"Password validation alert message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	self.server.newPassword = self.passwordCell.textField.text;
	
	[self showSpinnerView];
	
	BOOL success = NO;
	BOOL overRateLimit = NO;
	// TODO: lose potentially wasteful save call
	
	Response *saveResponse = [self.server saveRemote];
	success = [saveResponse isSuccess];
	overRateLimit = (saveResponse.statusCode == 413);
	
	[self hideSpinnerView];
	
	if (!success) {
		UIAlertView *av;
		if (overRateLimit) {
			av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", @"Error saving server password change alert title") 
											message:NSLocalizedString(@"Your new password was not saved because you have exceeded the API rate limit.  Please contact the Rackspace Cloud to increase your limit or try again later.", @"Error saving password change due to API rate limit alert message") 
										   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		} else {
			av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", @"Error saving server password change alert title") 
											message:NSLocalizedString(@"Your new password was not saved.  Please check your connection or the data you entered.", @"Error saving password change due to connection or other error alert message") 
										   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		}
	    [av show];
		[av release];
	}
}

#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[passwordCell release];
	[confirmPasswordCell release];
	[server release];
	[serverViewController release];
	[spinnerView release];
	[footerView release];
    [super dealloc];
}


@end
