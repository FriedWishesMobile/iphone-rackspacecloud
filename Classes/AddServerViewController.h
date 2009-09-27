//
//  AddServerViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/20/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server, TextFieldCell, ServersRootViewController;

@interface AddServerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	Server *server;
	TextFieldCell *nameCell;
	UITableViewCell *flavorCell;
	UITableViewCell *imageCell;
	ServersRootViewController *serversRootViewController;
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) TextFieldCell *nameCell;
@property (nonatomic, retain) ServersRootViewController *serversRootViewController;

-(void) cancelButtonPressed:(id)sender;
-(void) saveButtonPressed:(id)sender;

@end
