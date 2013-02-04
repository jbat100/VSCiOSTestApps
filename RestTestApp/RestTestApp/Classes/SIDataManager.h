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

/**
 Error domains and codes.
 */

extern NSString * const SIDataManagerErrorDomain;

/**
 Notification names
 */

extern NSString* const SIShopUpdateStartedNotification;

/**
 SIShopUpdateEndedNotification userInfo dictionary will contain an NSNumber for SIErrorKey and optionnaly a NSError object for SIErrorKey.
 */

extern NSString* const SIShopUpdateEndedNotification;

extern NSString* const SIProductUpdateStartedNotification;

/**
 SIProductUpdateEndedNotification userInfo dictionary will contain an NSNumber for SIErrorKey and optionnaly a NSError object for SIErrorKey.
 */

extern NSString* const SIProductUpdateEndedNotification;

/**
    Notification userInfo dictionary keys
 */

extern NSString* const SIErrorKey;
extern NSString* const SISuccesKey;

/**
 Note on notification userInfo (see NSNotification )
 */

@interface SIDataManager : NSObject

+(SIDataManager*) sharedManager;

+(NSString*) applicationDocumentsDirectoryURLString;
+(NSURL*) applicationDocumentsDirectoryURL;

/**
 No need to make the properties atomic, we should only call these methods from the main thread anyway so as to make sure that we do not upset CoreData
 */

@property (nonatomic, strong, readonly) RKObjectManager *restKitObjectManager;
@property (nonatomic, strong, readonly) RKManagedObjectStore* restKitManagedObjectStore;
@property (nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;
//@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;
//@property (nonatomic, strong, readonly) NSManagedObjectContext* managedObjectContext;

@property (nonatomic, assign, readonly) BOOL updatingShops;
@property (nonatomic, assign, readonly) BOOL updatingProducts;

/**
 Update shop entries in CoreData database, if for some reason the update cannot be performed then the method will return NO and the error parameter will be filled. This method is asynchronous if it returns YES, it broadcasts a SIShopUpdateStartedNotification immediately and completion of the update is marked with a SIShopUpdateEndedNotification.
 */

-(BOOL) updateShopsError:(NSError**)pError;

/**
 Update Product and ProductType entries in CoreData database, if for some reason the update cannot be performed then the method will return NO and the error parameter will be filled. This method is asynchronous if it returns YES, it broadcasts a SIProductUpdateStartedNotification immediately and completion of the update is marked with a SIProductUpdateEndedNotification.
 */

-(BOOL) updateProductsError:(NSError**)pError;

/**
 Fetch an array containing all Shop instances
 */

-(NSArray*) fetchAllShops;

/**
 Fetch an array containing all the ProductType instances (which will all have their corresponding products in the @products property)
 */
 
-(NSArray*) fetchAllProductTypes;

/**
 Fetch an array containing all the products, of any ProductType
 */

-(NSArray*) fetchAllProducts;

@end
