//
//  Container.h
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ObjectiveResource.h"

@class Response;

@interface Container : NSObject {

	NSString *name;
	NSString *count;
	NSString *bytes;	
	NSMutableArray *objects;
	NSString *object;
	
	// CDN fields
	NSString *cdnEnabled;
	NSString *ttl;
	NSString *logRetention;
	NSString *cdnUrl;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *count;
@property (nonatomic, retain) NSString *bytes;

@property (nonatomic, retain) NSString *cdnEnabled;
@property (nonatomic, retain) NSString *ttl;
@property (nonatomic, retain) NSString *logRetention;
@property (nonatomic, retain) NSString *cdnUrl;

@property (nonatomic, retain) NSMutableArray *objects;
@property (nonatomic, retain) NSString *object;

-(NSString *)humanizedBytes;
-(NSString *)humanizedCount;

+(NSString *)urlencode: (NSString *) url;

-(Response *)save;
-(Response *)create;
-(Response *)updateCdnAttributes:(NSArray *)knownCDNContainers;

@end
