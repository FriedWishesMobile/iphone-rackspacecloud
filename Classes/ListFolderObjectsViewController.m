//
//  ListFolderObjectsViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 12/3/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "ListFolderObjectsViewController.h"
#import "CloudFilesObject.h"
#import "Container.h"
#import "ObjectViewController.h"

#define kFolders 0
#define kFiles 1

@implementation ListFolderObjectsViewController

@synthesize title, objects, filenamePrefixLength, container;

NSMutableArray *objectsInFolders = nil;
NSMutableArray *objectsOutsideFolders = nil;
NSDictionary *subfolders = nil;

NSMutableArray *stack = nil;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)loadSubfolders {
	
	if (stack == nil) {
		stack = [[NSMutableArray alloc] init];
	}
	
	
	
	if (objectsInFolders) {
		[objectsInFolders release];
	}
	if (objectsOutsideFolders) {
		[objectsOutsideFolders release];
	}
	if (subfolders) {
		[subfolders release];
	}
	
	objectsInFolders = [[NSMutableArray alloc] init];
	objectsOutsideFolders = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [objects count]; i++) {
		CloudFilesObject *cfo = [objects objectAtIndex:i];
		NSString *filename = [cfo.name substringFromIndex:filenamePrefixLength];
		NSRange range = [filename rangeOfString:@"/" ];
		if (range.location == NSNotFound) {
			[objectsOutsideFolders addObject:cfo];
		} else {
			[objectsInFolders addObject:cfo];
		}
	}
	
	// put folders files in folder
	subfolders = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < [objectsInFolders count]; i++) {
		CloudFilesObject *cfo = [objectsInFolders objectAtIndex:i];
		NSString *filename = [cfo.name substringFromIndex:filenamePrefixLength];
		NSString *key = [filename substringToIndex:[filename rangeOfString:@"/"].location];
		NSMutableArray *folder = [subfolders objectForKey:key];
		if (folder == nil) {
			folder = [[NSMutableArray alloc] init];
		}
		[folder addObject:cfo];
		[subfolders setValue:folder forKey:key];
	}
	
	NSArray *stackContents = [NSArray arrayWithObjects:objectsInFolders, objectsOutsideFolders, subfolders, nil];
	
	[stack addObject:stackContents];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.title = self.title;	
	[self loadSubfolders];	
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([subfolders count] > 0) {
		return 2;
	} else {
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if ([subfolders count] > 0 && section == kFolders) {
		return @"Folders"; // TODO: localize
	} else { //if (section == kFiles) {
		return NSLocalizedString(@"Files", @"Container Files table section header");
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([subfolders count] > 0 && section == kFolders) {
		return [subfolders count];
	} else { // if (section == kFiles) {
		return [objectsOutsideFolders count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	if ([subfolders count] > 0 && indexPath.section == kFolders) {
		NSString *key = [[subfolders allKeys] objectAtIndex:indexPath.row];
		NSInteger count = [[subfolders objectForKey:key] count];
		cell.textLabel.text = key;
		if (count == 1) {
			cell.detailTextLabel.text = @"1 file"; // TODO: localize
		} else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%i files", count]; // TODO: localize
		}
		
	} else { //if (indexPath.section == kFiles) {	
		CloudFilesObject *o = (CloudFilesObject *) [objectsOutsideFolders objectAtIndex:indexPath.row];	
		NSString *filename = [o.name substringFromIndex:filenamePrefixLength];
		cell.textLabel.text = filename;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", o.contentType, [o humanizedBytes]];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([subfolders count] > 0 && indexPath.section == kFolders) {
		ListFolderObjectsViewController *vc = [[ListFolderObjectsViewController alloc] initWithNibName:@"ListFolderObjectsViewController" bundle:nil];
		
		NSString *key = [[subfolders allKeys] objectAtIndex:indexPath.row];
		vc.title = key;
		vc.objects = [subfolders valueForKey:key];
		vc.filenamePrefixLength = [key length] + 1 + filenamePrefixLength;
		vc.container = self.container;
		
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	} else { // if (indexPath.section == kFiles) {
		CloudFilesObject *o = (CloudFilesObject *) [objectsOutsideFolders objectAtIndex:indexPath.row];	
		ObjectViewController *vc = [[ObjectViewController alloc] initWithNibName:@"ObjectView" bundle:nil];
		vc.cfObject = o;
		vc.container = self.container;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
		[aTableView deselectRowAtIndexPath:indexPath animated:NO];
	}
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


- (void)dealloc {
	[title release];
	[objects release];
	[container release];
	if (objectsInFolders) {
		[objectsInFolders release];
	}
	if (objectsOutsideFolders) {
		[objectsOutsideFolders release];
	}
	if (subfolders) {
		[subfolders release];
	}
    [super dealloc];
}


@end

