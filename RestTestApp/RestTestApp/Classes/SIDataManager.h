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

@class SICategory;
@class SIUser;
@class SIProduct;

/**
 Error domains and codes.
 */

extern NSString * const SIDataManagerErrorDomain;

extern const NSInteger SIDataManagerUpdateOngoingErrorCode;
extern const NSInteger SIDataManagerNetworkErrorCode;
extern const NSInteger SIDataManagerBadSetupErrorCode;
extern const NSInteger SIDataManagerNoCurrentUserErrorCode;
extern const NSInteger SIDataManagerOngoingOrderErrorCode;
extern const NSInteger SIDataManagerPurchaseCountIsZeroErrorCode;
extern const NSInteger SIDataManagerInternalErrorCode;

/**
 Notification names
 */

extern NSString* const SIDatabaseUpdateStartedNotification;
extern NSString* const SIDatabaseUpdateEndedNotification;

/**
    Notification userInfo dictionary keys
 */

extern NSString* const SIOutcomeKey;        // value should be SIOutcomeError or SIOutcomeSuccess
extern NSString* const SIUpdateTypeKey;     // value should be SIUpdateTypeShops, SIUpdateTypeCategories or SIUpdateTypeProducts
extern NSString* const SIErrorKey;          // if SIOutcomeKey has value SIOutcomeError this should contain an NSError

/**
 Notification userInfo dictionary values
 */

// outcomes (values for SIOutcomeKey) 
extern NSString* const SIOutcomeError;
extern NSString* const SIOutcomeSuccess;
// update types (values for SIUpdateTypeKey)
extern NSString* const SIUpdateTypeShops;
extern NSString* const SIUpdateTypeCategories;
extern NSString* const SIUpdateTypeProducts;



@interface SIDataManager : NSObject

+(SIDataManager*) sharedManager;

+(NSString*) applicationDocumentsDirectoryURLString;
+(NSURL*) applicationDocumentsDirectoryURL;

/**
 No need to make the properties atomic, we should only call these methods from the main thread anyway so as to make sure that we do not upset CoreData
 */

@property (nonatomic, strong, readonly) RKObjectManager *restKitObjectManager;
@property (nonatomic, strong, readonly) RKManagedObjectStore* restKitManagedObjectStore;

@property (nonatomic, assign, readonly) BOOL updatingShops;
@property (nonatomic, assign, readonly) BOOL updatingCategories;
@property (nonatomic, assign, readonly) BOOL updatingProducts;

/**
 User
 */
@property (nonatomic, strong) SIUser* currentUser;

/**
 Order management, operations can fail if:
    - there is no currentUser (self.currentUser == nil), see SIDataManagerNoCurrentUserErrorCode
    - an order is ongoing (being validated with the server), see SIDataManagerOngoingOrderErrorCode
    - decreasePurchaseCountForProduct: can fail if the current purchase count is 0, see SIDataManagerPurchaseCountIsZeroErrorCode
 */
-(BOOL) resetPurchaseCountsError:(NSError**)error;
-(BOOL) increasePurchaseCountForProduct:(SIProduct*)product error:(NSError**)error;
-(BOOL) decreasePurchaseCountForProduct:(SIProduct*)product error:(NSError**)error;
-(NSInteger) purchaseCountForProduct:(SIProduct*)product error:(NSError**)error;

/**
 Update SIShop entries in CoreData database, if for some reason the update cannot be performed then the method will return NO and the error parameter will be filled. This method is asynchronous if it returns YES, it broadcasts a SIShopUpdateStartedNotification immediately and completion of the update is marked with a SIShopUpdateEndedNotification.
 */

-(BOOL) updateShopsError:(NSError**)pError;

/**
 Update SIProduct entries in CoreData database, if for some reason the update cannot be performed then the method will return NO and the error parameter will be filled. This method is asynchronous if it returns YES, it broadcasts a SIProductUpdateStartedNotification immediately and completion of the update is marked with a SIProductUpdateEndedNotification.
 */

-(BOOL) updateProductsError:(NSError**)pError;

/**
 Update SICategory entries in CoreData database, if for some reason the update cannot be performed then the method will return NO and the error parameter will be filled. This method is asynchronous if it returns YES, it broadcasts a SIProductUpdateStartedNotification immediately and completion of the update is marked with a SIProductUpdateEndedNotification.
 */

-(BOOL) updateCategoriesError:(NSError**)pError;

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
 Fetch an array containing all the products for a given category
 */

-(NSArray*) fetchAllProductsForCategory:(SICategory*)category;

@end
