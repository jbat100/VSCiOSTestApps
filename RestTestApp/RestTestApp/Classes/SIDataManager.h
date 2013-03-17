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
@class SIOrder;

/**
 Error domains and codes.
 */

extern NSString * const SIDataManagerErrorDomain;

extern const NSInteger SIDataManagerUpdateOngoingErrorCode;
extern const NSInteger SIDataManagerNetworkErrorCode;
extern const NSInteger SIDataManagerBadSetupErrorCode;
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

-(void) performFullDatabasUpdate;

/**
 Total price, wanted to handle this duty to SIOrder, but it has no knowledge of product price
 */

-(NSDecimalNumber*) totalPriceForOrder:(SIOrder*)order;

/**
 Products with non zero purchase counts
 */

-(NSArray*) productsWithPositivePurchaseCountForOrder:(SIOrder*)order;


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

/**
 Fetch a product with a given productID
 */

-(SIProduct*) fetchProductWithProductID:(NSString*)productID;

@end
