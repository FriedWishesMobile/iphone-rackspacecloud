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

static UIImage *debianImage = nil;
static UIImage *gentooImage = nil;
static UIImage *ubuntuImage = nil;
static UIImage *archImage = nil;
static UIImage *centosImage = nil;
static UIImage *fedoraImage = nil;
static UIImage *rhelImage = nil;

@implementation IPGroupViewController

@synthesize ipGroup;

+ (void)initialize {
    // The images are cached as part of the class, so they need to be explicitly retained.
	debianImage = [[UIImage imageNamed:@"debian.png"] retain];
	gentooImage = [[UIImage imageNamed:@"gentoo.png"] retain];
	ubuntuImage = [[UIImage imageNamed:@"ubuntu.png"] retain];
	archImage = [[UIImage imageNamed:@"arch.png"] retain];
	centosImage = [[UIImage imageNamed:@"centos.png"] retain];
	fedoraImage = [[UIImage imageNamed:@"fedora.png"] retain];
	rhelImage = [[UIImage imageNamed:@"rhel.png"] retain];
}

- (UIImage *)imageForServer:(Server *)s {
	
	if ([s.imageId isEqualToString:@"2"]) {
		return centosImage;
	} else if ([s.imageId isEqualToString:@"3"]) {
		return gentooImage;
	} else if ([s.imageId isEqualToString:@"4"]) {
		return debianImage;
	} else if ([s.imageId isEqualToString:@"5"]) {
		return fedoraImage;
	} else if ([s.imageId isEqualToString:@"7"]) {
		return centosImage;
	} else if ([s.imageId isEqualToString:@"8"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"9"]) {
		return archImage;
	} else if ([s.imageId isEqualToString:@"10"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"11"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"12"]) {
		return rhelImage;
	} else if ([s.imageId isEqualToString:@"13"]) {
		return archImage;
	} else if ([s.imageId isEqualToString:@"4056"]) {
		return fedoraImage;
	}
	
	return nil;
}

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
		cell.imageView.image = [self imageForServer:server];
		
		return cell;
	} else {
		return nil;
	}
	return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kServers) {
		ServerViewController *vc = [[ServerViewController alloc] initWithNibName:@"ServerView" bundle:nil];
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];		
		vc.server = [app.servers objectForKey:((Server *)[self.ipGroup.servers objectAtIndex:indexPath.row]).serverId];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
		[aTableView deselectRowAtIndexPath:indexPath animated:NO];		
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = self.ipGroup.sharedIpGroupName;
    [super viewDidLoad];
}

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
	[ipGroup release];
    [super dealloc];
}


@end
