//
//  AddContainerViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 11/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AddContainerViewController.h"
#import "TextFieldCell.h"
#import "Container.h"
#import "ContainersRootViewController.h"

@implementation AddContainerViewController

@synthesize nameCell, cdnSwitch, containersRootViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.nameCell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"NameCell"];
		self.nameCell.textLabel.text = NSLocalizedString(@"Name", @"Container Name cell label");
		self.nameCell.textField.placeholder = @"";
		self.nameCell.accessoryType = UITableViewCellAccessoryNone;		
		self.nameCell.textField.keyboardType = UIKeyboardTypeDefault;
		self.nameCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.nameCell.textField.delegate = self;
    }
    return self;
}

#pragma mark -
#pragma mark Button Handlers

-(void) cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void) saveButtonPressed:(id)sender {
	
	Container *c = [[Container alloc] init];
	c.name = self.nameCell.textField.text;
	if (self.cdnSwitch.on) {
		c.cdnEnabled = @"True";
	}
	[c create];	
	[self dismissModalViewControllerAnimated:YES];
	[self.containersRootViewController refreshContainerList];
}

#pragma mark -
#pragma mark Table view methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"Container Details", @"Container Details table section header");
	} else if (section == 1) {
		return NSLocalizedString(@"Settings", @"Container Settings table section header");
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UISwitch *)cdnSwitch {
    if (cdnSwitch == nil) {
        CGRect frame = CGRectMake(198.0, 9.0, 94.0, 27.0);
        cdnSwitch = [[UISwitch alloc] initWithFrame:frame];
		
        // in case the parent view draws with a custom color or gradient, use a transparent color
        cdnSwitch.backgroundColor = [UIColor clearColor];
		
		cdnSwitch.tag = 1;	// tag this view for later so we can remove it from recycled table cells
    }
    return cdnSwitch;
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CDNSwitchCellIdentifier = @"CDNSwitchCell";
	UITableViewCell *cdnSwitchCell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CDNSwitchCellIdentifier];
	if (cdnSwitchCell == nil) {
		cdnSwitchCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDNSwitchCellIdentifier] autorelease];
		cdnSwitchCell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	
    // Set up the cell...
	
	if (indexPath.section == 0) {
		return self.nameCell;
	} else {
		cdnSwitchCell.textLabel.text = NSLocalizedString(@"Publish to CDN", @"Publish to CDN cell label");
		[cdnSwitchCell.contentView addSubview:self.cdnSwitch];
		
		return cdnSwitchCell;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

#pragma mark -
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
	[nameCell release];
	[cdnSwitch release];
	[containersRootViewController release];
    [super dealloc];
}


@end

