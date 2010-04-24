//
//  PasswordLockViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MasterViewController, SettingsViewController;

@interface PasswordLockViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    SEL callback;
    MasterViewController *masterViewController;
    SettingsViewController *settingsViewController;
    UITextField *textField;
}

@property (nonatomic) SEL callback;
@property (nonatomic, retain) MasterViewController *masterViewController;
@property (nonatomic, retain) SettingsViewController *settingsViewController;

-(void)cancelButtonPressed:(id)sender;
-(void)loginButtonPressed:(id)sender;

@end
