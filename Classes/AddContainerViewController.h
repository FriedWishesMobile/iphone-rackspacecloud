//
//  AddContainerViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 11/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextFieldCell, ContainersRootViewController;

@interface AddContainerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	TextFieldCell *nameCell;
	UISwitch *cdnSwitch;
	ContainersRootViewController *containersRootViewController;
}

@property (nonatomic, retain) TextFieldCell *nameCell;
@property (nonatomic, retain) UISwitch *cdnSwitch;
@property (nonatomic, retain) ContainersRootViewController *containersRootViewController;

-(void) cancelButtonPressed:(id)sender;
-(void) saveButtonPressed:(id)sender;

@end
