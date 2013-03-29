//
//  StreatitDataManager.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

#import "AFHTTPClient.h"

@class SICategory;
@class SIUser;
@class SIProduct;
@class SIOrder;

/**
 Error domains and codes.
 */

extern NSString * const SIDataManagerErrorDomain;

extern const NSInteger SIUpdateOngoingErrorCode;
extern const NSInteger SINetworkErrorCode;
extern const NSInteger SIBadSetupErrorCode;
extern const NSInteger SIUserNotAuthenticatedErrorCode;
extern const NSInteger SIUserAlreadyExistsErrorCode;
extern const NSInteger SIIncompleteUserInfoErrorCode;
extern const NSInteger SIInvalidOrderContentErrorCode;
extern const NSInteger SIInvalidOrderStateErrorCode;
extern const NSInteger SIInvalidParameterErrorCode;
extern const NSInteger SIUnknownErrorCode;
extern const NSInteger SIInternalErrorCode;

/**
 Notification names
 */

extern NSString* const SIDatabaseUpdateEndedNotification;
extern NSString* const SIUserCreationEndedNotification;
extern NSString* const SIOrderEndedNotification;

/**
    Notification userInfo dictionary keys
 */

extern NSString* const SIOutcomeKey;        // value should be SIOutcomeError or SIOutcomeSuccess
extern NSString* const SIErrorKey;          // if SIOutcomeKey has value SIOutcomeError this should contain an NSError
extern NSString* const SIUserKey;           // value is SIUser instance
extern NSString* const SIOrderKey;          // value is SIOrder instance

/**
 Notification userInfo dictionary values
 */

// outcomes (values for SIOutcomeKey) 
extern NSString* const SIOutcomeError;
extern NSString* const SIOutcomeSuccess;


@interface SIDataManager : AFHTTPClient

+(SIDataManager*) sharedManager;
- (id)initWithBaseURL:(NSURL *)url;

/**
 StreatIt webservice URL
 */

/**
 The device dependent password used as device_password field in user creation/authentification requests
 */

+(NSString*) devicePassword;

/**
 Application document directory path
 */

+(NSString*) applicationDocumentsDirectoryURLString;
+(NSURL*) applicationDocumentsDirectoryURL;

/**
 Check if database is updating
 */

@property (nonatomic, assign, readonly) BOOL updatingDatabase;

/**
 User
 */

@property (nonatomic, strong) SIUser* currentUser;

/**
 Order
 */

@property (nonatomic, strong) SIOrder* currentOrder;

/**
 Perform full database update, shops, products, categories, formulas.
 When done, a SIDatabaseUpdateEndedNotification will be broadcast
 */

-(void) performDatabaseUpdate;

/**
 SI specific operations
 */

-(BOOL) createNewUser:(SIUser*)user error:(NSError**)error;

/**
 Perform order once the payment has been validated with paypal, the order state must be SIOrderStateValidated
 */

-(BOOL) performOrder:(SIOrder*)order forUser:(SIUser*)user error:(NSError**)error;

/**
 Total price, wanted to handle this duty to SIOrder, but it has no knowledge of product price
 */

-(NSDecimalNumber*) totalPriceForOrder:(SIOrder*)order;

/**
 Products with non zero purchase counts
 */

-(NSArray*) productsWithPositivePurchaseCountForOrder:(SIOrder*)order;


/**
 Fetch an array containing all Shop instances
 */

-(NSArray*) fetchAllShops;

/**
 Fetch an array containing all the ProductType instances (which will all have their corresponding products in the @products property)
 */
 
-(NSArray*) fetchAllCategories;

/**
 Fetch an array containing all the products (all Categories)
 */

-(NSArray*) fetchAllProducts;

/**
 Fetch a product with a given productID
 */

-(SIProduct*) fetchProductWithProductID:(NSString*)productID;

@end
