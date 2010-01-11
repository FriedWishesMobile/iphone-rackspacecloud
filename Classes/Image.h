//
//  Image.h
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "ObjectiveResource.h"


@interface Image : NSObject {

	NSString *imageId;
	NSString *imageName;
	NSString *timeStamp;
	NSString *status;
	NSString *progress;	
	NSString *serverId; // for backup images
}

@property (nonatomic, retain) NSString *imageId;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *timeStamp;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *progress;
@property (nonatomic, retain) NSString *serverId;

+ (Image *)findLocalWithImageId:(NSString *)imageId;

// don't fully trust this method, as a backup image could be windows but return NO
// because it's not one of the Rackspace-provided Windows images
- (BOOL)isWindows;

@end
