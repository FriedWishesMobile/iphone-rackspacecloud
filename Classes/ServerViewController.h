//
//  ServerViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/1/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server, RoundedRectView, ServersRootViewController;

@interface ServerViewController : UITableViewController <UIActionSheetDelegate, UITextFieldDelegate> {
	Server *server;
	IBOutlet UIView *footerView;
	IBOutlet UIBarButtonItem *saveButton;
	UITableViewCell *statusCell;
	RoundedRectView *spinnerView;
	ServersRootViewController *serversRootViewController;
	NSMutableDictionary *actions;
	NSString *flavorName;
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) UITableViewCell *statusCell;
@property (nonatomic, retain) RoundedRectView *spinnerView;
@property (nonatomic, retain) ServersRootViewController *serversRootViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil server:(Server *)aServer;

- (void) softRebootButtonPressed:(id)sender;
- (void) hardRebootButtonPressed:(id)sender;
- (void) showRebootDialog;
- (void) saveButtonPressed:(id)sender;
- (void) detachProgressPollingThread;

@end
