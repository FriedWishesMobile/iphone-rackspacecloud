//
//  SettingsViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController {
	IBOutlet UITableView *tableView;
	NSUserDefaults *defaults;
    UISwitch *passwordLockSwitch;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UISwitch *passwordLockSwitch;

@end
