//
//  ListFolderObjectsViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 12/3/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Container;

@interface ListFolderObjectsViewController : UITableViewController {
	NSString *title;
	NSMutableArray *objects;
	NSUInteger filenamePrefixLength;
	Container *container;

	NSMutableArray *objectsInFolders;
	NSMutableArray *objectsOutsideFolders;
	NSDictionary *subfolders;
	//NSMutableArray *stack;	
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *objects;
@property (nonatomic) NSUInteger filenamePrefixLength;
@property (nonatomic, retain) Container *container;

- (void)loadSubfolders;

@end
