//
//  AddObjectViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/19/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CFAccount, Container, ListObjectsViewController;

@interface AddObjectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	CFAccount *account;
	Container *container;
	ListObjectsViewController *listObjectsViewController;
}

@property (nonatomic, retain) CFAccount *account;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) ListObjectsViewController *listObjectsViewController;

- (void) cancelButtonPressed:(id)sender;

@end
