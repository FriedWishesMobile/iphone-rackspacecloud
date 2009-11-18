//
//  AddServerViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/20/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "AddServerViewController.h"
#import "Server.h"
#import "ServerNameController.h"
#import "TextFieldCell.h"
#import "AddServerFlavorController.h"
#import "AddServerImageController.h"
#import "RackspaceAppDelegate.h"
#import "Flavor.h"
#import "Image.h"
#import "Response.h"
#import "ServersRootViewController.h"

#define kServerDetails 0
#define kFlavor 1
#define kImage 2

@implementation AddServerViewController

@synthesize server, nameCell, serversRootViewController;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.server = [[Server alloc] init];
		self.server.serverName = @"";
		self.server.flavorId = @"";
		self.server.imageId = @"";
		self.nameCell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"NameCell"];
		self.nameCell.textLabel.text = NSLocalizedString(@"Name", @"Server Name cell label");
		self.nameCell.textField.placeholder = @"";
		self.nameCell.accessoryType = UITableViewCellAccessoryNone;		

		self.nameCell.textField.keyboardType = UIKeyboardTypeDefault;
		self.nameCell.textField.delegate = self;
		self.nameCell.textField.returnKeyType = UIReturnKeyDone;
		
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save") style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonPressed:)];
	}
    return self;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == kServerDetails) {
		return NSLocalizedString(@"Server Details", @"Server Details table section header");
	} else if (section == kFlavor) {
		return NSLocalizedString(@"Choose a Flavor", @"Choose a Flavor table section header");
	} else if (section == kImage) {
		return NSLocalizedString(@"Choose an Image", @"Choose an Image table section header");
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	if (section == kServerDetails) {
		return 1;
	} else if (section == kFlavor) {
		return [app.flavors count];
	} else if (section == kImage) {
		return [app.images count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	flavorCell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:@"AddServerFlavorCell"];
	if (flavorCell == nil) {
		flavorCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AddServerFlavorCell"] autorelease];
		flavorCell.accessoryType = UITableViewCellAccessoryNone;
	}

	imageCell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:@"AddServerImageCell"];
	if (imageCell == nil) {
		imageCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddServerImageCell"] autorelease];
		imageCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];

	if (indexPath.section == kServerDetails) {
		return self.nameCell;
	} else if (indexPath.section == kFlavor) {
		Flavor *flavor = (Flavor *) [app.flavors objectAtIndex:indexPath.row];
		flavorCell.textLabel.text = flavor.flavorName;
		flavorCell.detailTextLabel.text = [NSString stringWithFormat:@"%@MB %@ - %@GB %@", flavor.ram, NSLocalizedString(@"RAM", @"RAM"), flavor.disk, NSLocalizedString(@"Disk", @"Disk")];
		
		// show or hide selection style
		if ([flavor.flavorId isEqualToString:self.server.flavorId]) {
			flavorCell.accessoryType = UITableViewCellAccessoryCheckmark;
			flavorCell.textLabel.textColor = [UIColor colorWithRed:0.222 green:0.326 blue:0.540 alpha:1.0];
			flavorCell.detailTextLabel.textColor = [UIColor colorWithRed:0.222 green:0.326 blue:0.540 alpha:1.0];
			[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		} else {
			flavorCell.accessoryType = UITableViewCellAccessoryNone;
			flavorCell.textLabel.textColor = [UIColor blackColor];
			flavorCell.detailTextLabel.textColor = [UIColor blackColor];
		}
		
		return flavorCell;
	} else if (indexPath.section == kImage) {
		Image *image = (Image *) [app.images objectAtIndex:indexPath.row];
		
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		imageCell.textLabel.text = image.imageName;
		imageCell.imageView.image = [app imageForImage:image];

		// show or hide selection style
		if ([image.imageId isEqualToString:self.server.imageId]) {
			imageCell.accessoryType = UITableViewCellAccessoryCheckmark;
			imageCell.textLabel.textColor = [UIColor colorWithRed:0.222 green:0.326 blue:0.540 alpha:1.0];
			[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		} else {
			imageCell.accessoryType = UITableViewCellAccessoryNone;
			imageCell.textLabel.textColor = [UIColor blackColor];
			
		}
		
		return imageCell;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kServerDetails) {
		ServerNameController *vc = [[ServerNameController alloc] initWithNibName:@"ServerNameController" bundle:nil];
		vc.addServerViewController = self;
		[self.navigationController presentModalViewController:vc animated:YES];
		[vc release];
	} else if (indexPath.section == kFlavor) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		Flavor *flavor = [app.flavors objectAtIndex:indexPath.row];
		self.server.flavorId = flavor.flavorId;
		[aTableView reloadData];
	} else if (indexPath.section == kImage) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		Image *image = [app.images objectAtIndex:indexPath.row];
		self.server.imageId = image.imageId;
		[aTableView reloadData];
	}
	//[aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Keyboard Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	self.server.serverName = textField.text;
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.server.serverName = textField.text;
	NSLog(@"server name = %@", self.server.serverName);
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Button Handlers

-(void) cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void) saveButtonPressed:(id)sender {
	
	self.server.serverName = self.nameCell.textField.text;
	
	// check for a name, flavor, and image
	BOOL isValid = ![self.server.serverName isEqualToString:@""] && ![self.server.flavorId isEqualToString:@""] && ![self.server.imageId isEqualToString:@""];
	
	if (isValid) {
		
		// send the save request
		Response *response = [self.server create];
		
		if ([response isSuccess]) {
			// set serversRootController serversLoaded = NO to refresh the list
			self.serversRootViewController.serversLoaded = NO;
			[self.serversRootViewController.tableView reloadData];

			[self dismissModalViewControllerAnimated:YES];
		} else {
			// handle 413 for rate limit, or isSuccess
			UIAlertView *alert;			
			if (response.statusCode == 413) {				
				alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", @"Error Saving alert title") 
												   message:NSLocalizedString(@"Your server was not saved because you have exceeded the API rate limit.  Please contact the Rackspace Cloud to increase your limit or try again later.", @"Error saving new server due to API rate limit alert message") 
												  delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
			} else {
				alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", @"Error Saving alert title") 
												   message:NSLocalizedString(@"Your server was not saved.  Please check your connection or the data you entered and try again.", @"Error saving new server due to connection or other error alert message") 
												  delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
			}
			[alert show];
			[alert release];
		}
		
	} else { // it's not valid to post
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"All fields are required.", @"New server validation alert message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[server release];
	[nameCell release];
	[serversRootViewController release];
    [super dealloc];
}


@end
