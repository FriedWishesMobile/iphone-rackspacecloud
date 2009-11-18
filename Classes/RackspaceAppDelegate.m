//
//  RackspaceAppDelegate.m
//  Rackspace
//
//  Created by Michael Mayo on 5/25/09.
//  Copyright Rackspace Hosting 2009. All rights reserved.
//

#import "RackspaceAppDelegate.h"
#import "LoginViewController.h"
#import "ObjectiveResource.h"
#import "ServersRootViewController.h"
#import "Server.h"
#import "Image.h"

NSString *kScalingModeKey	= @"scalingMode";
NSString *kControlModeKey	= @"controlMode";
NSString *kBackgroundColorKey	= @"backgroundColor";

static UIImage *debianImage = nil;
static UIImage *gentooImage = nil;
static UIImage *ubuntuImage = nil;
static UIImage *archImage = nil;
static UIImage *centosImage = nil;
static UIImage *fedoraImage = nil;
static UIImage *rhelImage = nil;

@implementation RackspaceAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize loginViewController;
@synthesize usernamePreference, apiKeyPreference;
@synthesize computeUrl;
@synthesize storageUrl;
@synthesize cdnManagementUrl;
@synthesize cloudFilesAccountName;
@synthesize authToken;
@synthesize serversRootViewController;
@synthesize flavors, images, servers;
@synthesize imageScrollView;
@synthesize moviePlayer;

- (void)loadOperatingSystemLogos {
	debianImage = [[UIImage imageNamed:@"debian.png"] retain];
	gentooImage = [[UIImage imageNamed:@"gentoo.png"] retain];
	ubuntuImage = [[UIImage imageNamed:@"ubuntu.png"] retain];
	archImage = [[UIImage imageNamed:@"arch.png"] retain];
	centosImage = [[UIImage imageNamed:@"centos.png"] retain];
	fedoraImage = [[UIImage imageNamed:@"fedora.png"] retain];
	rhelImage = [[UIImage imageNamed:@"rhel.png"] retain];	
}

- (UIImage *)imageForServer:(Server *)s {
	
	if ([s.imageId isEqualToString:@"2"]) {
		return centosImage;
	} else if ([s.imageId isEqualToString:@"3"]) {
		return gentooImage;
	} else if ([s.imageId isEqualToString:@"4"]) {
		return debianImage;
	} else if ([s.imageId isEqualToString:@"5"]) {
		return fedoraImage;
	} else if ([s.imageId isEqualToString:@"7"]) {
		return centosImage;
	} else if ([s.imageId isEqualToString:@"8"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"9"]) {
		return archImage;
	} else if ([s.imageId isEqualToString:@"10"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"11"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"12"]) {
		return rhelImage;
	} else if ([s.imageId isEqualToString:@"13"]) {
		return archImage;
	} else if ([s.imageId isEqualToString:@"4056"]) {
		return fedoraImage;
	} else if ([s.imageId isEqualToString:@"14362"]) {
		return ubuntuImage;
	} else {		
		// might be a backup image, so look for the server id in the image
		// if a server is there, call imageForServer on it
		
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		
		s.imageId;
		
		Image *image = [Image findLocalWithImageId:s.imageId];
		if (image && image.serverId) {
			
			// find the image for the serverId
			// call imageForServer on that server
			Server *server = (Server *) [app.servers objectForKey:image.serverId];
			return [self imageForServer:server];
		}
	}
	
	return nil;
}

- (UIImage *)imageForImage:(Image *)i {
	
	if ([i.imageId isEqualToString:@"2"]) {
		return centosImage;
	} else if ([i.imageId isEqualToString:@"3"]) {
		return gentooImage;
	} else if ([i.imageId isEqualToString:@"4"]) {
		return debianImage;
	} else if ([i.imageId isEqualToString:@"5"]) {
		return fedoraImage;
	} else if ([i.imageId isEqualToString:@"7"]) {
		return centosImage;
	} else if ([i.imageId isEqualToString:@"8"]) {
		return ubuntuImage;
	} else if ([i.imageId isEqualToString:@"9"]) {
		return archImage;
	} else if ([i.imageId isEqualToString:@"10"]) {
		return ubuntuImage;
	} else if ([i.imageId isEqualToString:@"11"]) {
		return ubuntuImage;
	} else if ([i.imageId isEqualToString:@"12"]) {
		return rhelImage;
	} else if ([i.imageId isEqualToString:@"13"]) {
		return archImage;
	} else if ([i.imageId isEqualToString:@"4056"]) {
		return fedoraImage;
	} else if ([i.imageId isEqualToString:@"14362"]) {
		return ubuntuImage;
	} else {		
		// might be a backup image, so look for the server id in the image
		// if a server is there, call imageForServer on it
		
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		
		
		Server *aServer = (Server *) [app.servers objectForKey:i.serverId];
		Image *image = [Image findLocalWithImageId:aServer.imageId];
		if (image) { // && image.serverId) {
			
			// find the image for the serverId
			// call imageForServer on that server
			return [self imageForImage:image];
		}
	}		
	return nil;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[self loadOperatingSystemLogos];
	
	[ObjectiveResourceConfig setResponseType:JSONResponse];	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	self.usernamePreference = [defaults stringForKey:@"username_preference"];
	self.apiKeyPreference = [defaults stringForKey:@"api_key_preference"];

	[window addSubview:tabBarController.view];	
	
	loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];	
	[window addSubview:loginViewController.view];
	
	// register user defaults in case the Rackspace Cloud screen in the Settings app has not yet been loaded
	[self loadSettings];
	
	// Register to receive a notification that the movie is now in memory and ready to play
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePreloadDidFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
	
	// Register to receive a notification when the movie has finished playing. 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	// Register to receive a notification when the movie scaling mode has changed. 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieScalingModeDidChange:) name:MPMoviePlayerScalingModeDidChangeNotification object:nil];
}

-(void)loadSettings {
	
	NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"ssh_app_protocol_preference"];
	
	if (testValue == nil) {
		
		// settings haven't been created, so let's create them here
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"ssh://", @"ssh_app_protocol_preference",
									 [NSNumber numberWithBool:YES], @"ssh_enabled_preference",
									 nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}	
}

-(void)initAndPlayMovie:(NSURL *)movieURL {
	// Initialize a movie player object with the specified URL
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
	if (mp)
	{
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
		
		// Apply the user specified settings to the movie player object
		[self setMoviePlayerUserSettings];
		
		// Play the movie!
		[self.moviePlayer play];
	}
}

-(void)setMoviePlayerUserSettings
{
    /* First get the movie player settings defaults (scaling, controller type and background color)
	 set by the user via the built-in iPhone Settings application */
	
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kScalingModeKey];
    if (testValue == nil)
    {
        // No default movie player settings values have been set, create them here based on our 
        // settings bundle info.
        //
        // The values to be set for movie playback are:
        //
        //    - scaling mode (None, Aspect Fill, Aspect Fit, Fill)
        //    - controller mode (Standard Controls, Volume Only, Hidden)
        //    - background color (Any UIColor value)
        //
        
        NSString *pathStr = [[NSBundle mainBundle] bundlePath];
        NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
        NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        
        NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
        
        NSNumber *controlModeDefault;
        NSNumber *scalingModeDefault;
        NSNumber *backgroundColorDefault = [NSNumber numberWithInt:0];
        
        NSDictionary *prefItem;
        for (prefItem in prefSpecifierArray)
        {
            NSString *keyValueStr = [prefItem objectForKey:@"Key"];
            id defaultValue = [prefItem objectForKey:@"DefaultValue"];
            
            if ([keyValueStr isEqualToString:kScalingModeKey])
            {
                scalingModeDefault = defaultValue;
            }
            else if ([keyValueStr isEqualToString:kControlModeKey])
            {
                controlModeDefault = defaultValue;
            }
            else if ([keyValueStr isEqualToString:kBackgroundColorKey])
            {
                backgroundColorDefault = defaultValue;
            }
        }
        
        // since no default values have been set, create them here
		/*
        NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
                                      scalingModeDefault, kScalingModeKey,
                                      controlModeDefault, kControlModeKey,
                                      backgroundColorDefault, kBackgroundColorKey,
                                      nil];
		 */
		
		NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithCapacity:3];
		//[appDefaults setObject:scalingModeDefault forKey:kScalingModeKey];
		//[appDefaults setObject:controlModeDefault forKey:kControlModeKey];
		[appDefaults setObject:backgroundColorDefault forKey:kBackgroundColorKey];
        
//        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	
    /* Now apply these settings to the active Movie Player (MPMoviePlayerController) object  */
	
    /* 
	 Movie scaling mode can be one of: MPMovieScalingModeNone, MPMovieScalingModeAspectFit,
	 MPMovieScalingModeAspectFill, MPMovieScalingModeFill.
	 */
    self.moviePlayer.scalingMode = [[NSUserDefaults standardUserDefaults] integerForKey:kScalingModeKey];
    
    /* 
	 Movie control mode can be one of: MPMovieControlModeDefault, MPMovieControlModeVolumeOnly,
	 MPMovieControlModeHidden.
	 */
    self.moviePlayer.movieControlMode = [[NSUserDefaults standardUserDefaults] integerForKey:kControlModeKey];
	
    /*
	 The color of the background area behind the movie can be any UIColor value.
	 */
    UIColor *colors[15] = {[UIColor blackColor], [UIColor darkGrayColor], [UIColor lightGrayColor], [UIColor whiteColor], 
        [UIColor grayColor], [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], 
        [UIColor yellowColor], [UIColor magentaColor],[UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], 
        [UIColor clearColor]};
	self.moviePlayer.backgroundColor = colors[ [[NSUserDefaults standardUserDefaults] integerForKey:kBackgroundColorKey] ];
	
	/*
	 The time relative to the duration of the video when playback should start, if possible. 
	 Defaults to 0.0. When set, the closest key frame before the provided time will be used as the 
	 starting frame.
	 self.moviePlayer.initialPlaybackTime = <specify a movie time here>;
	 
	 */
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	/* 
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    /*     
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
}

//  Notification called when the movie scaling mode has changed.
- (void) movieScalingModeDidChange:(NSNotification*)notification
{
    /* 
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
}

- (void)dealloc {
    [tabBarController release];
	[loginViewController release];
    [window release];
	[usernamePreference release];
	[apiKeyPreference release];
	[computeUrl release];
	[storageUrl release];
	[cdnManagementUrl release];
	[cloudFilesAccountName release];
	[authToken release];
	[serversRootViewController release];
	[flavors release];
	[images release];
	[servers release];
	[imageScrollView release];
	[moviePlayer release];
    [super dealloc];
}

@end

