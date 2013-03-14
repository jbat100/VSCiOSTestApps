//
//  StreatitHTTPClient.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "AFHTTPClient.h"

@class SIUser;
@class SIOrder;

/**
 Notifications names
 */

extern NSString* const SIHTTPClientEndedUserCreation;
extern NSString* const SIHTTPClientEndedUserAuthentication;
extern NSString* const SIHTTPClientEndedOrder;

/**
 Notification userInfo keys
 */

// key for SIHTTPClientEndedOrder notification, value SIHTTPClientSuccess or SIHTTPClientFailure
extern NSString* const SIHTTPClientOutcomeKey;
// value is SIUser instance
extern NSString* const SIHTTPClientUserKey;
// value is SIOrder instance
extern NSString* const SIHTTPClientOrderKey;
// value is NSError instance
extern NSString* const SIHTTPClientErrorKey;

/**
 Notification userInfo values
 */

// possible values for SIHTTPClientOutcomeKey
extern NSString* const SIHTTPClientSuccess;
extern NSString* const SIHTTPClientFailure;

/**
 Error Domain and Codes
 */

extern NSString* const SIHTTPClientErrorDomain;

extern const NSInteger SIHTTPClientUserNotAuthenticatedErrorCode;
extern const NSInteger SIHTTPClientIncompleteUserInfoErrorCode;
extern const NSInteger SIHTTPClientInvalidOrderContentErrorCode;
extern const NSInteger SIHTTPClientInvalidOrderStateErrorCode;
extern const NSInteger SIHTTPClientInternalErrorCode;

/**
 Main HTTP client used to do non-core-data related stuff (core-data stuff is in SIDataManager)
 */

@interface SIHTTPClient : AFHTTPClient

/**
 AFHTTPClient stuff
 */

+ (SIHTTPClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

/*
 The device dependent password used as device_password field in user creation/authentification requests
 */

+(NSString*) devicePassword;

/**
 SI specific operations
 */

-(BOOL) createNewUser:(SIUser*)user error:(NSError**)error;
-(BOOL) performAuthentificationForUser:(SIUser*)user error:(NSError**)error;
-(BOOL) performOrder:(SIOrder*)order forUser:(SIUser*)user error:(NSError**)error;

@end
