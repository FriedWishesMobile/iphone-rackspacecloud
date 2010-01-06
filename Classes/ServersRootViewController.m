//
//  ServersRootViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 6/20/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "ServersRootViewController.h"
#import "SpinnerCell.h"
#import "Server.h"
#import "RackspaceAppDelegate.h"
#import "ServerViewController.h"
#import "AddServerViewController.h"
#import "Image.h"

@implementation ServersRootViewController

@synthesize servers, serversLoaded;

#pragma mark -
#pragma mark Load Servers

// thread to load servers
- (void) loadServers {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];

	if (!serversLoaded && app.computeUrl) {
		
		[ObjectiveResourceConfig setSite:app.computeUrl];
		[ObjectiveResourceConfig setAuthToken:app.authToken];
		[ObjectiveResourceConfig setResponseType:JSONResponse];	
		
		self.servers = [NSMutableArray arrayWithArray:[Server findAllRemoteWithResponse:nil]];
		app.servers = [[NSMutableDictionary alloc] initWithCapacity:1];
		
		for (int i = 0; i < [self.servers count]; i++) {
			Server *s = (Server *) [self.servers objectAtIndex:i];
			[app.servers setObject:s forKey:s.serverId];
		}
		
		serversLoaded = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		
		self.tableView.userInteractionEnabled = YES;
		[self.tableView reloadData];
	}
	[autoreleasepool release];	
	
}

#pragma mark -
#pragma mark View Stuff

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem.enabled = NO;	
	[super viewDidLoad];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		serversLoaded = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	
	// set up the accelerometer for the "shake to refresh" feature
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 25)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];	

	if (!serversLoaded) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		app.serversRootViewController = self;	
		[NSThread detachNewThreadSelector:@selector(loadServers) toTarget:self withObject:nil];	
	}
	
	[super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Shake To Refresh
- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	UIAccelerationValue length, x, y, z;
	
	// Use a basic high-pass filter to remove the influence of the gravity
	myAccelerometer[0] = acceleration.x * 0.1 + myAccelerometer[0] * (1.0 - 0.1);
	myAccelerometer[1] = acceleration.y * 0.1 + myAccelerometer[1] * (1.0 - 0.1);
	myAccelerometer[2] = acceleration.z * 0.1 + myAccelerometer[2] * (1.0 - 0.1);
	// Compute values for the three axes of the acceleromater
	x = acceleration.x - myAccelerometer[0];
	y = acceleration.y - myAccelerometer[1];
	z = acceleration.z - myAccelerometer[2];
	
	// Compute the intensity of the current acceleration 
	length = sqrt(x * x + y * y + z * z);
	
	// see if they shook hard enough to refresh
	if (length >= 3.0) {
		serversLoaded = NO;
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self.tableView reloadData];
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		app.serversRootViewController = self;	
		[NSThread detachNewThreadSelector:@selector(loadServers) toTarget:self withObject:nil];	
		
	}
}

#pragma mark -
#pragma mark Table Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (serversLoaded) {
		return 50;
	} else {
		return 460;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (serversLoaded) {
		return [self.servers count];
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (serversLoaded) {
		static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		Server *s = (Server *) [servers objectAtIndex:indexPath.row];
		cell.textLabel.text = s.serverName;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [s flavorName], [s imageName]];
		cell.imageView.image = [app imageForServer:s];
		
		return cell;
		
	} else {
		static NSString *CellIdentifier = @"SpinnerCell";
		SpinnerCell *cell = (SpinnerCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[SpinnerCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.userInteractionEnabled = NO;
			self.tableView.userInteractionEnabled = NO;
		}
		
		return cell;
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ServerViewController *vc = [[ServerViewController alloc] initWithNibName:@"ServerView" bundle:nil];
	vc.server = [servers objectAtIndex:indexPath.row];
	vc.serversRootViewController = self;
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];		
}

#pragma mark -
#pragma mark Button Handlers

-(void) addButtonPressed:(id)sender {
	AddServerViewController *vc = [[AddServerViewController alloc] initWithNibName:@"AddServer" bundle:nil];
	vc.serversRootViewController = self;
	[self.navigationController presentModalViewController:vc animated:YES];
	[vc release];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[servers release];
    [super dealloc];
}


@end
