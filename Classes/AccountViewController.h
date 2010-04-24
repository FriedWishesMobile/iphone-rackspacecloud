//
//  AccountViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface AccountViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UINavigationItem *navigationItem;
    SettingsViewController *settingsViewController;
    BOOL primaryAccount;
    NSString *originalUsername;
	UITextField *usernameTextField;
	UITextField *apiKeyTextField;
    IBOutlet UIView *footerView;
    IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic) BOOL primaryAccount;
@property (nonatomic, retain) NSString *originalUsername;
@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;
-(void)deleteButtonPressed:(id)sender;

@end
