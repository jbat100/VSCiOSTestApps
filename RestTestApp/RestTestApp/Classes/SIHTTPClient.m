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

NSString* const SIHTTPClientEndedUserCreation = @"SIHTTPClientEndedUserCreation";
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
const NSInteger SIHTTPClientIncompleteUserInfoErrorCode     = 4;
const NSInteger SIHTTPClientNetworkErrorCode                = 5;
const NSInteger SIHTTPClientUserAlreadyExistsErrorCode      = 6;
const NSInteger SIHTTPClientInvalidParameterErrorCode       = 7;
const NSInteger SIHTTPClientUnknownErrorCode                = 998;
const NSInteger SIHTTPClientInternalErrorCode               = 999;

/*
 *  Private SIOrder.h Interface
 */

@interface SIOrder ()

/**
 StreatIt web service URL address
 */

+(NSURL*) dataWebServiceURL;

/**
 Error conversion
 */

+(NSError*) translateRequestError:(NSError*)error;

/**
 JSON Helpers
 */

+(NSArray*) productJSONArrayForOrder:(SIOrder*)order;

+(NSString*)stringInCentimesForPriceInEuros:(NSDecimalNumber*)euros;

@end

@implementation SIHTTPClient

+ (SIHTTPClient *)sharedClient
{
    static SIHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SIHTTPClient alloc] initWithBaseURL:[self dataWebServiceURL]];
        // used for test
        _sharedClient.currentOrder = [[SIOrder alloc] init];
    });
    
    return _sharedClient;
}

+(NSURL*) dataWebServiceURL
{
    return [NSURL URLWithString:@"http://sidev.herokuapp.com"];
}

+(NSArray*) productJSONArrayForOrder:(SIOrder*)order
{
    /*
        Creates an array with the product codes (product codes are duplicated if the count is > 1), which is silly...
     */
    
    NSDictionary* purchaseCounts = [order purchaseCounts]; // this costs a dictionary copy so I create a local copy
    
    NSMutableArray* jsonArray = [NSMutableArray array];
    
    if (purchaseCounts)
    {
        NSArray* productIDs = [purchaseCounts allKeys];
        for (NSString* productID in productIDs)
        {
            NSNumber* countNumber = [purchaseCounts objectForKey:productIDs];
            NSInteger count = [countNumber integerValue];
            if (count > 0)
            {
                for (NSInteger i = 0; i < count; i++)
                {
                    [jsonArray addObject:productID];
                }
            }
        }
        
        return [NSArray arrayWithArray:jsonArray];
    }
    
    return nil;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    //[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	//[self setDefaultHeader:@"Accept" value:@"application/json"];
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    //[self setDefaultHeader:@"Accept" value:@"application/json"];
    //[self setDefaultHeader:@"Accept-Charset" value:@"utf-8"];
    
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

#pragma mark - Custom Setters

-(void) setCurrentUser:(SIUser *)currentUser
{
    _currentUser = currentUser;
    if (currentUser)
    {
        self.currentOrder = [[SIOrder alloc] init];
    }
    else
    {
        self.currentOrder = nil;
    }
}

#pragma mark - Error Translation

+(NSError*) translateRequestError:(NSError*)error
{
    
    DDLogVerbose(@"Translating error %@", error);
    
    if ([error.domain isEqualToString:NSURLErrorDomain])
    {
        // NSURLErrorDomain means there is a network problem
        return [NSError errorWithDomain:SIHTTPClientErrorDomain
                                   code:SIHTTPClientNetworkErrorCode
                               userInfo:nil];
    }
    
    if ([error.domain isEqualToString:AFNetworkingErrorDomain])
    {
        // AFNetworkingErrorDomain means there is a response, but it is not in the expected 200-299 range
        NSString* recovery = [error localizedRecoverySuggestion];
        if (recovery)
        {
            do {
                
                NSData* jsonRecoveryData = [recovery dataUsingEncoding:NSUTF8StringEncoding];
                id jsonRecoveryObject = [NSJSONSerialization JSONObjectWithData:jsonRecoveryData options:0 error:nil];
                if (!jsonRecoveryObject) break;
                if ([jsonRecoveryObject isKindOfClass:[NSDictionary class]] == NO) break;
                NSArray* recoveryMessageArray = [(NSDictionary*)jsonRecoveryObject objectForKey:@"message"];
                if ([recoveryMessageArray isKindOfClass:[NSArray class]] == NO) break;
                if ([recoveryMessageArray count] == 0) break;
                NSString* recoveryMessage = [recoveryMessageArray objectAtIndex:0];
                if ([recoveryMessage isKindOfClass:[NSString class]] == NO) break;
                if ([recoveryMessage isEqualToString:@"Account already created"])
                {
                    return [NSError errorWithDomain:SIHTTPClientErrorDomain
                                               code:SIHTTPClientUserAlreadyExistsErrorCode
                                           userInfo:nil];
                }
                
            } while (0);
            
            
            // attempt to read JSON message...
            
        }
    }
    
    return [NSError errorWithDomain:SIHTTPClientErrorDomain
                               code:SIHTTPClientUnknownErrorCode
                           userInfo:nil];
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
        DDLogError(@"CreateNewUser: ERROR invalid user %@", user);
        *error = [[NSError alloc] initWithDomain:SIHTTPClientErrorDomain code:SIHTTPClientIncompleteUserInfoErrorCode userInfo:nil];
        return NO;
    }
    
    DDLogVerbose(@"CreateNewUser: with %@", user);
    
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
                                 @"firstname" : user.firstName,
                                 @"device_password" : devicePasswordString};
    
    DDLogVerbose(@"CreateNewUser: parameters: %@", parameters);
    
    /*
     Make the post request and get success/failure through blocks
     */
    
    [self postPath:@"/clients.json"
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               NSString* responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
               
               /* On success, response seems to be a big fat pile of html */
               
               DDLogVerbose(@"CreateNewUser:error: SUCCESS, response (%d bytes): %@", [responseObject length], responseString);
               
               /* TODO: Check the response object to see if the creation succeeded!! */
               
               user.authenticated = YES;
               
               self.currentUser = user;
               
               NSDictionary* userInfo = @{SIHTTPClientOutcomeKey : SIHTTPClientSuccess, SIHTTPClientUserKey : user};
               [[NSNotificationCenter defaultCenter] postNotificationName:SIHTTPClientEndedUserCreation object:nil userInfo:userInfo];
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               
               DDLogError(@"CreateNewUser:error: FAILED, error: %@", error);
               
               NSError* translatedError = [[self class] translateRequestError:error];
               
               user.authenticated = NO;
               
               NSDictionary* userInfo = @{SIHTTPClientOutcomeKey : SIHTTPClientFailure,
                                          SIHTTPClientUserKey : user,
                                          SIHTTPClientErrorKey : translatedError};
               
               [[NSNotificationCenter defaultCenter] postNotificationName:SIHTTPClientEndedUserCreation object:nil userInfo:userInfo];
               
           }];
    
    return YES;
}


#pragma mark - Perform Order Request

-(BOOL) performOrder:(SIOrder*)order forUser:(SIUser*)user error:(NSError**)error
{
    if (order == nil)
    {
        DDLogError(@"%@ performOrder:forUser:error: order must not be nil", self);
        if (error) *error = [NSError errorWithDomain:SIHTTPClientErrorDomain code:SIHTTPClientInvalidParameterErrorCode userInfo:nil];
        return NO;
    }
    
    if (user == nil)
    {
        DDLogError(@"%@ performOrder:forUser:error: user must not be nil", self);
        if (error) *error = [NSError errorWithDomain:SIHTTPClientErrorDomain code:SIHTTPClientInvalidParameterErrorCode userInfo:nil];
        return NO;
    }
    
    if (order.state != SIOrderStateValidated)
    {
        DDLogError(@"%@ performOrder:forUser:error: order.state must be SIOrderStateValidated", self);
        if (error) *error = [NSError errorWithDomain:SIHTTPClientErrorDomain code:SIHTTPClientInvalidOrderStateErrorCode userInfo:nil];
        return NO;
    }
    
    if (order.shopId == nil)
    {
        // TODO: shopId should be verified more (check in database if it refers to a proper entry)
        DDLogError(@"%@ performOrder:forUser:error: order.shopId not be nil", self);
        if (error) *error = [NSError errorWithDomain:SIHTTPClientErrorDomain code:SIHTTPClientInvalidOrderContentErrorCode userInfo:nil];
        return NO;
    }

    // http://sidev.herokuapp.com/ipn
    
    NSDictionary* clientJSONDict = @{ @"email" : user.email, @"pass" : [[self class] devicePassword] };
    
    NSDecimalNumber* totalPrice = order.paidPrice;
    NSDecimalNumber* totalPriceInCentimes = [totalPrice decimalNumberByMultiplyingByPowerOf10:2];
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingMode = NSNumberFormatterRoundFloor;
    formatter.maximumFractionDigits = 0;
    NSString* centimes = [formatter stringFromNumber:totalPriceInCentimes];
    
    
    NSDictionary* parameters = @{ @"client" : clientJSONDict,
                                  @"commande" : @{ @"magasin_id" : order.shopId, @"paykey" : order.payKey }
                                  };
    
    
    return YES;

}

@end
