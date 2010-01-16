//
//  ListObjectsViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Container, CFAccount, RoundedRectView, TextFieldCell, ContainersRootViewController;

@interface ListObjectsViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAccelerometerDelegate, UITextFieldDelegate> {
	NSString *containerName;
	Container *container;
	Container *objectsContainer;
	CFAccount *account;
	UIAccelerationValue	myAccelerometer[3];
	UISwitch *cdnSwitch;
	UISwitch *logSwitch;
	RoundedRectView *spinnerView;
	TextFieldCell *cdnURLCell;
	TextFieldCell *ttlCell;
	ContainersRootViewController *containersRootViewController;
}

@property (nonatomic, retain) NSString *containerName;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) Container *objectsContainer;
@property (nonatomic, retain) CFAccount *account;
@property (nonatomic, retain) UISwitch *cdnSwitch;
@property (nonatomic, retain) UISwitch *logSwitch;
@property (nonatomic, retain) RoundedRectView *spinnerView;
@property (nonatomic, retain) TextFieldCell *ttlCell;
@property (nonatomic, retain) ContainersRootViewController *containersRootViewController;


- (void)showSpinnerView;
- (void)hideSpinnerView;
- (void)refreshFileList;

@end
