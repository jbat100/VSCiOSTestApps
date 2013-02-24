//
//  SIDataManager.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIDataManager.h"
#import "DDLog.h"
#import <RestKit/RestKit.h>
#import <CoreData/CoreData.h>

/*
 
 Product json example http://streatit-dev.herokuapp.com/produits.json
 
 {
 "category_id":1,
 "created_at":"2013-02-20T18:13:46Z",
 "description":"ECREVISSE, CREAMCHEESE, CIBOULETTE, HERBES FOLLES,SPRING ONION, CONCOMBRE, CRANBERRY S\u00c9CH\u00c9,POUSSES D\u2019\u00c9PINARDS",
 "id":1,
 "image":"bagel",
 "name":"American Bagel",
 "prix":"7.0",
 "updated_at":"2013-02-20T18:13:46Z"
 }
 
 Category json example  http://streatit-dev.herokuapp.com/categories.json
 
 {
 "created_at":"2013-02-20T17:56:29Z",
 "description":"Le hamburger mais avec un trou dedans !",
 "id":1,
 "image":"bagels",
 "name":"Bagels",
 "size":null,
 "updated_at":"2013-02-20T17:56:29Z"
 }
 
 */

NSString * const SIDataManagerErrorDomain = @"SIDataManagerErrorDomain";

NSString* const SIDatabaseUpdateStartedNotification = @"SIDatabaseUpdateStartedNotification";
NSString* const SIDatabaseUpdateEndedNotification = @"SIDatabaseUpdateEndedNotification";

NSString* const SIErrorKey = @"SIErrorKey";
NSString* const SISuccessKey = @"SISuccessKey";
NSString* const SIUpdateTypeKey = @"SIUpdateTypeKey";

NSString* const SIUpdateTypeShops = @"SIUpdateTypeShops";
NSString* const SIUpdateTypeCategories = @"SIUpdateTypeCategories";
NSString* const SIUpdateTypeProducts = @"SIUpdateTypeProducts";

/*
 *  Private SIDataManager Interface
 */

@interface SIDataManager ()

+(NSURL*) dataWebServiceURL;

+(NSString*) applicationDocumentsDirectoryURLString;
+(NSURL*) applicationDocumentsDirectoryURL;

+(NSString*) coreDataStoreName;
+(NSString*) coreDataStoreURLString;
+(NSURL*) coreDataStoreURL;

@property (nonatomic, strong, readwrite) RKObjectManager *restKitObjectManager;
@property (nonatomic, strong, readwrite) RKManagedObjectStore* restKitManagedObjectStore;

@property (nonatomic, strong) NSPersistentStore* persistentStore;

@property (nonatomic, assign, readwrite) BOOL setupSucceeded;
@property (nonatomic, assign, readwrite) BOOL updatingShops;
@property (nonatomic, assign, readwrite) BOOL updatingProducts;

/**
 Setup should only be called once, in the static singleton accessor would be the only good place I can think of right now.
 */

-(void)setup;

/**
 Used to centralise the decision as to which managed object context will be used for fetch requests
 */

-(NSManagedObjectContext*) managedObjectContextForFetchRequests;

@end

#pragma mark - Implementation

@implementation SIDataManager


+(void) load
{
    NSError *error = nil;
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (!success)
    {
        DDLogError(@"%@ failed to create application data directory at path '%@': %@", self, RKApplicationDataDirectory(), error);
        assert(NO);
    }
}

#pragma mark - Singleton

+(SIDataManager*) sharedManager
{
    static SIDataManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SIDataManager alloc] init];
        assert(_sharedClient);
        [_sharedClient setup];
    });
    return _sharedClient;
}

#pragma mark - URLs and Directories

+(NSURL*) dataWebServiceURL
{
    //return [NSURL URLWithString:@"http://restkit.org"];
    return [NSURL URLWithString:@"http://streatit-dev.herokuapp.com"];
}

+(NSString*) applicationDocumentsDirectoryURLString
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSURL*) applicationDocumentsDirectoryURL
{
    return [NSURL fileURLWithPath:[[self class] applicationDocumentsDirectoryURLString]];
}

+(NSString*) coreDataStoreName
{
    return @"StreatModel1.sqlite";
}

+(NSString*) coreDataStoreURLString
{
    return [RKApplicationDataDirectory() stringByAppendingPathComponent:[self coreDataStoreName]];
}

+(NSURL*) coreDataStoreURL
{
    return [NSURL fileURLWithPath:[self coreDataStoreURLString]];
}

#pragma mark - Init and Setup

-(id)init
{
    if ((self = [super init]))
    {

    }
    return self;
}

-(void)setup
{
    static BOOL done = NO;
    
    assert(done == NO);
    
    if (!done)
    {
        done = YES;
        
        // --- Create managedObjectModel --- 
        
        NSManagedObjectModel* managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        assert(managedObjectModel);
        if (!managedObjectModel)
        {
            DDLogError(@"%@ could not initialize managedObjectModel", self);
            self.setupSucceeded = NO;
            return;
        }
        
        
        // --- Create restKitManagedObjectStore --- 
        
        self.restKitManagedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
        assert(self.restKitManagedObjectStore);
        if (!self.restKitManagedObjectStore)
        {
            DDLogError(@"%@ could not initialize restKitManagedObjectStore", self);
            self.setupSucceeded = NO;
            return;
        }
        
        
        // --- Create persistentStore --- 
        
        NSError* error = nil;
        self.persistentStore = [self.restKitManagedObjectStore addSQLitePersistentStoreAtPath:[[self class] coreDataStoreURLString]
                                                                       fromSeedDatabaseAtPath:nil
                                                                            withConfiguration:nil
                                                                                      options:nil
                                                                                        error:&error];
        assert(self.persistentStore);
        if (!self.persistentStore)
        {
            DDLogError(@"%@ could not initialize persistentStore", self);
            self.setupSucceeded = NO;
            return;
        }
        
        
        // --- Create managed object contexts (this will be used for threading) --- 
        
        [self.restKitManagedObjectStore createManagedObjectContexts];
        // Configure a managed object cache to ensure we do not create duplicate objects
        id<RKManagedObjectCaching> cache = [[RKInMemoryManagedObjectCache alloc]
                                            initWithManagedObjectContext:self.restKitManagedObjectStore.persistentStoreManagedObjectContext];
        self.restKitManagedObjectStore.managedObjectCache = cache;
        
        
        // --- Create restKitObjectManager --- 
        
        self.restKitObjectManager = [RKObjectManager managerWithBaseURL:[[self class] dataWebServiceURL]];
        assert(self.restKitObjectManager);
        if (!self.restKitObjectManager)
        {
            DDLogError(@"%@ could not initialize restKitObjectManager", self);
            self.setupSucceeded = NO;
            return;
        }
        self.restKitObjectManager.managedObjectStore = self.restKitManagedObjectStore;
        
        
        // --- Category Mapping --- 
        
        RKEntityMapping *categoryMapping = [RKEntityMapping mappingForEntityForName:@"SICategory"
                                                               inManagedObjectStore:self.restKitManagedObjectStore];
        
        [categoryMapping addAttributeMappingsFromDictionary:@{
         @"id": @"categoryID",
         @"name": @"name",
         @"image" : @"imageURLString",
         @"description" : @"categoryDescription"}];
        
        categoryMapping.identificationAttributes = @[@"categoryID"];
        
        RKResponseDescriptor *categoryDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:categoryMapping
                                                                                           pathPattern:@"/categories"
                                                                                               keyPath:nil
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        [self.restKitObjectManager addResponseDescriptor:categoryDescriptor];
        
        
        // --- Product Mapping --- 
        
        RKEntityMapping *productMapping = [RKEntityMapping mappingForEntityForName:@"SIProduct"
                                                              inManagedObjectStore:self.restKitManagedObjectStore];
        
        [productMapping addAttributeMappingsFromDictionary:@{
         @"id": @"productID",
         @"category_id" : @"categoryID",
         @"name": @"name",
         @"image" : @"imageURLString",
         @"description" : @"productDescription",
         @"prix" : @"price"}];
        
        productMapping.identificationAttributes = @[@"productID"];
        
        RKResponseDescriptor *productDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping
                                                                                           pathPattern:@"/produits"
                                                                                               keyPath:nil
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        [self.restKitObjectManager addResponseDescriptor:productDescriptor];
        
        
        /*
         It is not actually possible using rest kit to establish the mappings between objects resulting from different GET
         requests, blake watters says so himself https://groups.google.com/forum/#!msg/restkit/aDCcCCWNiGw/11Z-Ka0MgnYJ
         so we're going to have to forget about the relationships for now... But we can still use RestKit to do the rest ...
         haha.
        
        [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"category"
                                                                                       toKeyPath:@"category"
                                                                                     withMapping:categoryMapping]];
         */
        
        self.setupSucceeded = YES;

    }
    
    else
    {
        DDLogError(@"%@ setup called multiple times", self);
    }
    

}

-(BOOL) checkSetup
{
    assert(self.restKitManagedObjectStore);
    assert(self.restKitObjectManager);
    
    if (self.restKitManagedObjectStore == nil) return NO;
    if (self.restKitObjectManager == nil) return NO;
    
    if (self.setupSucceeded == NO) return NO;
    
    return YES;
}

#pragma mark - Update API

-(BOOL) updateShopsError:(NSError**)pError
{
    [self checkSetup];
    
    return NO;
}

-(BOOL) updateProductsError:(NSError**)pError
{
    [self checkSetup];
    
    DDLogVerbose(@"Updating products...");
    [self.restKitObjectManager getObjectsAtPath:@"/produits" parameters:nil success:^(RKObjectRequestOperation *op, RKMappingResult *result) {
        DDLogVerbose(@"Success: %@", [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DDLogVerbose(@"Failure: %@", error);
    }];
    
    return NO;
}

-(BOOL) updateCategoriesError:(NSError**)pError
{
    [self checkSetup];
    
    DDLogVerbose(@"Updating categories...");
    [self.restKitObjectManager getObjectsAtPath:@"/categories" parameters:nil success:^(RKObjectRequestOperation *op, RKMappingResult *result) {
        DDLogVerbose(@"Success: %@", [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DDLogVerbose(@"Failure: %@", error);
    }];
    
    return NO;
}

#pragma mark - CoreData Fetches

-(NSArray*) fetchAllShops
{
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Shop"
                                                         inManagedObjectContext:[self managedObjectContextForFetchRequests]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *fetchResults = [[self managedObjectContextForFetchRequests] executeFetchRequest:request error:&error];
    
    if (error)
    {
        DDLogError(@"%@ fetchShops %@ : %@", self, error, [error userInfo]);
    }
    
    DDLogVerbose(@"%@ fetchShops (%lu results)", self, (unsigned long)[fetchResults count]);
    
    return fetchResults;
}

-(NSArray*) fetchAllCategories
{
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"ProductType"
                                                         inManagedObjectContext:[self managedObjectContextForFetchRequests]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *fetchResults = [[self managedObjectContextForFetchRequests] executeFetchRequest:request error:&error];
    
    if (error)
    {
        DDLogError(@"%@ fetchProductTypes %@ : %@", self, error, [error userInfo]);
    }
    
    DDLogVerbose(@"%@ fetchProductTypes (%lu results)", self, (unsigned long)[fetchResults count]);
    
    return fetchResults;
}

-(NSArray*) fetchAllProducts
{
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Product"
                                                         inManagedObjectContext:[self managedObjectContextForFetchRequests]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *fetchResults = [[self managedObjectContextForFetchRequests] executeFetchRequest:request error:&error];
    
    if (error)
    {
        DDLogError(@"%@ fetchProducts %@ : %@", self, error, [error userInfo]);
    }
    
    DDLogVerbose(@"%@ fetchProducts (%lu results)", self, (unsigned long)[fetchResults count]);
    
    return fetchResults;
}


-(NSArray*) fetchAllProductsForCategory:(SICategory*)category
{
    
}


#pragma mark - Normal CoreData Setup

/*
 
 - (NSManagedObjectModel *)managedObjectModel
 {
 if (_managedObjectModel != nil)
 {
 return _managedObjectModel;
 }
 
 NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"StreatModel1" ofType:@"momd"];
 NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
 
 _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
 
 assert(_managedObjectModel);
 if(!_managedObjectModel)
 {
 DDLogError(@"%@ could not create NSManagedObjectModel", self);
 abort();
 }
 
 DDLogVerbose(@"%@ created %@", self, _managedObjectModel);
 
 return _managedObjectModel;
 }
 
 -(NSPersistentStoreCoordinator*) persistentStoreCoordinator
 {
 if (_persistentStoreCoordinator != nil)
 {
 return _persistentStoreCoordinator;
 }
 
 NSURL *storeURL = [[[self class] applicationDocumentsDirectoryURL] URLByAppendingPathComponent:@"SIData.sqlite"];
 NSError *error = nil;
 
 _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
 
 if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
 {
 DDLogError(@"%@ could not add persistent store at %@ (%@ : %@)", _persistentStoreCoordinator, storeURL, error, [error userInfo]);
 abort();
 }
 
 DDLogVerbose(@"%@ created %@", self, _persistentStoreCoordinator);
 
 return _persistentStoreCoordinator;
 }
 
 -(NSManagedObjectContext*) managedObjectContext
 {
 if (_managedObjectContext != nil)
 {
 return _managedObjectContext;
 }
 
 NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
 
 _managedObjectContext = [[NSManagedObjectContext alloc] init];
 [_managedObjectContext setPersistentStoreCoordinator:coordinator];
 
 return _managedObjectContext;
 }
 
 */


@end
