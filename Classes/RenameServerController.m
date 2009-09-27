//
//  RenameServerController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/23/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "RenameServerController.h"
#import "RackspaceAppDelegate.h"
#import "Server.h"
#import "TextFieldCell.h"

@implementation RenameServerController

@synthesize server;

#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"Server Name", @"Rename Server Server Name table section header");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"EditServerNameCell";
	TextFieldCell *cell = (TextFieldCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
		cell.textLabel.text = NSLocalizedString(@"Name", @"Server Name cell label");
	}
	
	cell.textField.text = self.server.serverName;
	
	return cell;
}


#pragma mark Button Handlers

-(void)saveButtonPressed:(id)sender {
	NSLog(@"save pressed!");
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
	[server release];
    [super dealloc];
}


@end
