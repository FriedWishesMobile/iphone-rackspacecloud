//
//  ASICloudFilesRequest.m
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Michael Mayo on 22/12/09.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//
// A class for accessing data stored on Rackspace's Cloud Files Service
// http://www.rackspacecloud.com/cloud_hosting_products/files
// 
// Cloud Files Developer Guide:
// http://docs.rackspacecloud.com/servers/api/cs-devguide-latest.pdf

#import "ASICloudFilesRequest.h"

static NSString *username = nil;
static NSString *apiKey = nil;
static NSString *authToken = nil;
static NSString *storageURL = nil;
static NSString *cdnManagementURL = nil;
static NSString *serverManagementURL = nil;
static NSString *rackspaceCloudAuthURL = @"https://auth.api.rackspacecloud.com/v1.0";

static NSRecursiveLock *accessDetailsLock = nil;

@implementation ASICloudFilesRequest

+ (void)initialize
{
	if (self == [ASICloudFilesRequest class]) {
		accessDetailsLock = [[NSRecursiveLock alloc] init];
	}
}

#pragma mark -
#pragma mark Attributes and Service URLs

+ (NSString *)authToken {
	return authToken;
}

+ (void)setAuthToken:(NSString *)newAuthToken
{
	[accessDetailsLock lock];
	[authToken release];
	authToken = [newAuthToken retain];
	[accessDetailsLock unlock];
}


+ (NSString *)storageURL {
	return storageURL;
}

+ (void)setStorageURL:(NSString *)newStorageURL
{
	[accessDetailsLock lock];
	[storageURL release];
	storageURL = [newStorageURL retain];
	[accessDetailsLock unlock];
}


+ (NSString *)cdnManagementURL {
	return cdnManagementURL;
}

+ (void)setCdnManagementURL:(NSString *)newCdnManagementURL
{
	[accessDetailsLock lock];
	[cdnManagementURL release];
	cdnManagementURL = [newCdnManagementURL retain];
	[accessDetailsLock unlock];
}

+ (NSString *)serverManagementURL {
	return serverManagementURL;
}

+ (void)setServerManagementURL:(NSString *)newServerManagementURL
{
	[accessDetailsLock lock];
	[serverManagementURL release];
	serverManagementURL = [newServerManagementURL retain];
	[accessDetailsLock unlock];
}

#pragma mark -
#pragma mark Authentication

+ (id)authenticationRequest
{
	[accessDetailsLock lock];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:rackspaceCloudAuthURL]] autorelease];
	[request addRequestHeader:@"X-Auth-User" value:username];
	[request addRequestHeader:@"X-Auth-Key" value:apiKey];
	[accessDetailsLock unlock];
	return request;
}

+ (NSError *)authenticate
{
	[accessDetailsLock lock];
	ASIHTTPRequest *request = [ASICloudFilesRequest authenticationRequest];
	[request startSynchronous];
	
	if (![request error]) {
		NSDictionary *responseHeaders = [request responseHeaders];
		authToken = [responseHeaders objectForKey:@"X-Auth-Token"];
		storageURL = [responseHeaders objectForKey:@"X-Storage-Url"];
		cdnManagementURL = [responseHeaders objectForKey:@"X-Cdn-Management-Url"];
		serverManagementURL = [responseHeaders objectForKey:@"X-Server-Management-Url"];
	}
	[accessDetailsLock unlock];
	return [request error];
}

+ (NSString *)username
{
	return username;
}

+ (void)setUsername:(NSString *)newUsername
{
	[accessDetailsLock lock];
	[username release];
	username = [newUsername retain];
	[accessDetailsLock unlock];
}

+ (NSString *)apiKey {
	return apiKey;
}

+ (void)setApiKey:(NSString *)newApiKey
{
	[accessDetailsLock lock];
	[apiKey release];
	apiKey = [newApiKey retain];
	[accessDetailsLock unlock];
}

#pragma mark -
#pragma mark Date Parser
+(NSDate *)dateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
	// example: 2009-11-04T19:46:20.192723
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSSSSS"];
	NSDate *date = [dateFormatter dateFromString:dateString];
	[dateFormatter release];
	
	return date;
}

-(NSDate *)dateFromString:(NSString *)dateString {
	return [[self class] dateFromString:dateString];
}

@end
