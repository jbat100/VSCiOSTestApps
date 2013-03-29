//
//  SIDataManager_Private.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/28/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIDataManager.h"

/*
 THESE METHODS AND PROPERTIES ARE NOT MEANT TO BE USED BY THE OUTSIDE WORLD, maybe apart from testing
 */

@interface SIDataManager ()

/**
 Redeclaration of updatingDatabase as readwrite (readonly in public header)
 */

@property (nonatomic, assign, readwrite) BOOL updatingDatabase;

/**
 CoreData
 */

@property (nonatomic, strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

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

@end
