//
//  StreatitDataManager.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface StreatitDataManager : NSObject

+(StreatitDataManager*) sharedManager;

+(NSString*) applicationDocumentsDirectoryString;
+(NSURL*) applicationDocumentsDirectoryURL;

/*
 No need to make the properties atomic, we should only call these methods from the main
 thread anyway so as to make sure that we do not upset CoreData
 */

@property (nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext* managedObjectContext;

/**
 Fetch an array containing all Shop instances
 */

-(NSArray*) fetchAllShops;

/**
 Fetch an array containing all the ProductType instances (which will all have their corresponding
 products in the @products property)
 */
 
-(NSArray*) fetchAllProductTypes;

/**
 Fetch an array containing all the products, of any ProductType
 */

-(NSArray*) fetchAllProducts;

@end
