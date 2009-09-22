//
//  SharedIpGroup.m
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "SharedIpGroup.h"
#import "ObjectiveResource.h"
#import "RackspaceAppDelegate.h"
#import "Response.h"
#import "ORConnection.h"
#import "Server.h"

@implementation SharedIpGroup

@synthesize sharedIpGroupId, sharedIpGroupName, servers;

-(SharedIpGroup *) init {
	self.servers = [[NSMutableArray alloc] initWithCapacity:1];
	return self;
}

-(void)count {
	return;
}

+ (NSArray *)parseJSON:(NSString *)json {
	NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:0];
	
	// the xml parser is messy, and the json parser doesn't work, so i'd rather write a new one than 
	// try to fit shared ip groups into it.  so, let's do a rough json parse and make a nicer parser later
	BOOL parsing = YES;
	BOOL parsingServers = YES;
	NSRange startRange;
	NSRange endRange;

	while (parsing) {
		startRange = [json rangeOfString:@"\"id\":"];
		
		if (startRange.location == NSNotFound) {
			parsing = NO;
		} else {
			json = [json substringFromIndex:startRange.location];
			
			NSString *stringToParse = [json	substringToIndex:[json rangeOfString:@"}"].location];
			json = [json substringFromIndex:[json rangeOfString:@"}"].location + 1];
			
			endRange = [stringToParse rangeOfString:@",\"servers\":"];
			
			if (endRange.location == NSNotFound) {
				// no servers, so parse differently				
				SharedIpGroup *ipGroup = [[SharedIpGroup alloc] init];
				endRange = [stringToParse rangeOfString:@",\"name\":"];
				ipGroup.sharedIpGroupId = [[stringToParse substringFromIndex:5] substringToIndex:(endRange.location - 5)];
				stringToParse = [stringToParse substringFromIndex:endRange.location + endRange.length + 1];
				stringToParse = [stringToParse substringToIndex:[stringToParse length] - 1];
				ipGroup.sharedIpGroupName = stringToParse;
				[results addObject:ipGroup];
			} else { // we have servers
				SharedIpGroup *ipGroup = [[SharedIpGroup alloc] init];
				ipGroup.sharedIpGroupId = [[stringToParse substringFromIndex:5] substringToIndex:(endRange.location - 5)];
				
				// now for servers!
				startRange = [stringToParse rangeOfString:@",\"servers\":["];
				stringToParse = [stringToParse substringFromIndex:startRange.location + startRange.length];
				
				parsingServers = YES;
				while (parsingServers) {
					startRange = [stringToParse rangeOfString:@","];
					endRange = [stringToParse rangeOfString:@"]"];
					if (startRange.location != NSNotFound || endRange.location != 0) {
						Server *server = [[Server alloc] init];
						
						if (endRange.location < startRange.location || startRange.location == NSNotFound) {
							// only one left
							server.serverId = [stringToParse substringToIndex:endRange.location];
							stringToParse = [stringToParse substringFromIndex:endRange.location + 1];
							parsingServers = NO;
						} else {
							// more than one left
							server.serverId = [stringToParse substringToIndex:startRange.location];
							stringToParse = [stringToParse substringFromIndex:startRange.location + 1];
						}
						[ipGroup.servers addObject:server];
					} else {
						parsingServers = NO;
					}
				}
				
				stringToParse = [stringToParse substringFromIndex:endRange.location + endRange.length + 1];
				startRange = [stringToParse rangeOfString:@"\"name\":\""];
				stringToParse = [stringToParse substringFromIndex:2];				
				ipGroup.sharedIpGroupName = [stringToParse substringToIndex:[stringToParse length] - 1];
				[results addObject:ipGroup];
			}
		}
	}
	return results;
}

// Find all items 
+ (NSArray *)findAllRemoteWithResponse:(NSError **)aError {
		
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@shared_ip_groups/detail.json", app.computeUrl]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	Response *res = [ORConnection sendRequest:request withAuthToken:app.authToken];
	
	if ([res isError] && aError) {
		*aError = res.error;
	}

	NSString *responseString = [[NSString alloc] initWithData:res.body encoding:NSASCIIStringEncoding];	
	return [self parseJSON:responseString];
}

-(void) dealloc {
	[sharedIpGroupId release];
	[sharedIpGroupName release];
	[servers release];
	[super dealloc];
}

@end
