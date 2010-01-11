//
//  IPGroupViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/3/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "IPGroupViewController.h"
#import "SharedIpGroup.h"
#import "Server.h"
#import "RackspaceAppDelegate.h"
#import "ServerViewController.h"

#define kIPGroupDetails 0
#define kServers 1

@implementation IPGroupViewController

@synthesize ipGroup;

#pragma mark -
#pragma mark View Stuff

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = self.ipGroup.sharedIpGroupName;
    [super viewDidLoad];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == kIPGroupDetails) {
		return NSLocalizedString(@"IP Group Details", @"IP Group Details table section header");
	} else if (section == kServers) {
		return NSLocalizedString(@"Servers", @"IP Group server list table section header");
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == kIPGroupDetails) {
		return 1;
	} else if (section == kServers) {
		return [self.ipGroup.servers count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == kIPGroupDetails) {

		static NSString *CellIdentifier = @"IPNameCell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		cell.textLabel.text = NSLocalizedString(@"Name", @"Shared IP Group Name cell label");
		cell.detailTextLabel.text = self.ipGroup.sharedIpGroupName;
		
		return cell;
		
	} else if (indexPath.section == kServers) {
		
		static NSString *CellIdentifier = @"IPServerCell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];		
		Server *server = [app.servers objectForKey:((Server *)[self.ipGroup.servers objectAtIndex:indexPath.row]).serverId];
			
		cell.textLabel.text = server.serverName;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [server flavorName], [server imageName]];
		cell.imageView.image = [app imageForServer:server];
		
		return cell;
	} else {
		return nil;
	}
	return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kServers) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];		
		ServerViewController *vc = [[ServerViewController alloc] initWithNibName:@"ServerView" bundle:nil server:[app.servers objectForKey:((Server *)[self.ipGroup.servers objectAtIndex:indexPath.row]).serverId]];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
		[aTableView deselectRowAtIndexPath:indexPath animated:NO];		
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
	[ipGroup release];
    [super dealloc];
}


@end
