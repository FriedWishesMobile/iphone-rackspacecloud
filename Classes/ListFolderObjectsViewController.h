//
//  ListFolderObjectsViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListFolderObjectsViewController : UITableViewController {
	NSString *title;
	NSMutableArray *objects;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *objects;

@end
