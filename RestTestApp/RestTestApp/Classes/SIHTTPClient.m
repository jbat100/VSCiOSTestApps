//
//  StreatitHTTPClient.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIHTTPClient.h"
#import "SIOrder.h"
#import "SIUser.h"

#import "DDLog.h"
#import "AFJSONRequestOperation.h"
#import "UIDevice+IdentifierAddition.h"

NSString* const SIHTTPClientEndedAuthentication = @"SIHTTPClientEndedAuthentication";
NSString* const SIHTTPClientEndedOrder = @"SIHTTPClientEndedOrder";

NSString* const SIHTTPClientOutcomeKey = @"SIHTTPClientOutcomeKey";
NSString* const SIHTTPClientUserKey = @"SIHTTPClientUserKey";
NSString* const SIHTTPClientErrorKey = @"SIHTTPClientErrorKey";

NSString* const SIHTTPClientSuccess = @"SIHTTPClientSuccess";
NSString* const SIHTTPClientFailure = @"SIHTTPClientFailure";

NSString* const SIHTTPClientErrorDomain = @"SIHTTPClientErrorDomain";

const NSInteger SIHTTPClientUserNotAuthenticatedErrorCode   = 1;
const NSInteger SIHTTPClientInvalidOrderContentErrorCode    = 2;
const NSInteger SIHTTPClientInvalidOrderStateErrorCode      = 3;
const NSInteger SIHTTPClientInternalErrorCode               = 4;

/*
 *  Private SIOrder.h Interface
 */

@interface SIOrder ()

@property (nonatomic, assign) SIOrderState state;

@end

static NSString * const kStreatitAPIBaseURLString = @"https://api.twitter.com/1.1/";

@implementation SIHTTPClient

+ (SIHTTPClient *)sharedClient
{
    static SIHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SIHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kStreatitAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    //self.parameterEncoding = AFFormURLParameterEncoding;
    self.parameterEncoding = AFJSONParameterEncoding;
    
    return self;
}

+(NSString*) devicePassword
{
    static __strong NSString* pass = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pass = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    });
    
    if (!pass)
    {
        DDLogError(@"%@ devicePassword FAILED", self);
    }
    
    return pass;
}

#pragma mark - User Creation Request

-(BOOL) createNewUser:(SIUser*)user error:(NSError**)error
{
    /*
    
     PEG email:
     
     donc le nouveau site c'est : http://sidev.herokuapp.com/
     
     Pour ajouter un client tu execute une requete POST sur la ressources clients. En data tu pousse un json qui doit contenir un objet "client" avec:
     une "api_key" ("marvellous" pour l'instant ;-))
     un "email"
     un "device_password" (c'est a toi de générer le mdp que tu utilisera ensuite pour te connecter.)
     au choix soit un "fullname" soit un "name" soit un "firstname" ou les 3 !
     Attention tu dois bien penser a indiqué ton mime type dans le header de ta requete. (application/json)
     
     tu peut tester avec cette commande curl:
     
     curl -X POST -H "Content-Type: application/json" http://sidev.herokuapp.com/clients.json -d '{"client":{"api_key":"marvellous","email":"test@guerton.net","device_password":"trezvvnujrznpjdfionzoqjeaiorjez","fullname":"pierre-emmanuel guerton"}}'
    
    */
    
    /*
     Check the user related parameters
     */
    
    assert(user.email);
    assert(user.firstName);
    assert(user.lastName);
    
    if (!user.email || !user.email || !user.lastName)
    {
        DDLogError(@"%@ createNewUser:error: ERROR invalid user %@", self, user);
        *error = [[NSError alloc] initWithDomain:SIHTTPClientErrorDomain code:SIHTTPClientIncompleteUserInfoErrorCode userInfo:nil];
        return NO;
    }
    
    /*
     Check the device password (should exist and be less that 50 characters long)
     */
    
    NSString* devicePasswordString = [[self class] devicePassword];
    assert(devicePasswordString);
    assert([devicePasswordString length] > 0);
    assert([devicePasswordString length] < 50);
    
    if (!devicePasswordString || [devicePasswordString length] == 0 || [devicePasswordString length] >= 50)
    {
        *error = [[NSError alloc] initWithDomain:SIHTTPClientErrorDomain code:SIHTTPClientInternalErrorCode userInfo:nil];
        return NO;
    }
    
    /*
      Build the parameter dictionary 
     */
    
    NSDictionary* parameters = @{@"api_key" : @"marvellous",
                                 @"email" : user.email,
                                 @"name" : user.lastName,
                                 @"firstname" : user.lastName,
                                 @"device_password" : devicePasswordString};
    
    /*
     Make the post request and get success/failure through blocks
     */
    
    [self postPath:@"/clients.json"
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               DDLogVerbose(@"%@ createNewUser:error: SUCCESS, response: %@", self, responseObject);
               
               /* TODO: Check the response object to see if the creation succeeded!! */
               
               user.authenticated = YES;
               NSDictionary* userInfo = @{SIHTTPClientOutcomeKey : SIHTTPClientSuccess, SIHTTPClientUserKey : user};
               [[NSNotificationCenter defaultCenter] postNotificationName:SIHTTPClientEndedUserCreation object:nil userInfo:userInfo];
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               
               DDLogError(@"%@ createNewUser:error: FAILED, error: %@", self, error);
               user.authenticated = NO;
               NSDictionary* userInfo = @{SIHTTPClientOutcomeKey : SIHTTPClientFailure,
                                          SIHTTPClientUserKey : user,
                                          SIHTTPClientErrorKey : error};
               [[NSNotificationCenter defaultCenter] postNotificationName:SIHTTPClientEndedUserCreation object:nil userInfo:userInfo];
               
           }];
    
    return YES;
}

#pragma mark - User Authentification Request

-(BOOL) performAuthentificationForUser:(SIUser*)user error:(NSError**)error
{
    return YES;
}

#pragma mark - Perform Order Request

-(BOOL) performOrder:(SIOrder*)order forUser:(SIUser*)user error:(NSError**)error
{
    return YES;
}

@end
