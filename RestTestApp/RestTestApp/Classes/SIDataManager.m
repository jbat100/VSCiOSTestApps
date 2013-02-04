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

NSString * const SIDataManagerErrorDomain = @"SIDataManagerErrorDomain";

NSString* const SIShopUpdateStartedNotification = @"SIShopUpdateStartedNotification";
NSString* const SIShopUpdateEndedNotification = @"SIShopUpdateEndedNotification";
NSString* const SIProductUpdateStartedNotification = @"SIProductUpdateStartedNotification";
NSString* const SIProductUpdateEndedNotification = @"SIProductUpdateEndedNotification";

NSString* const SIErrorKey = @"SIErrorKey";
NSString* const SISuccesKey = @"SISuccesKey";

@interface SIDataManager ()

+(NSURL*) dataWebServiceURL;

+(NSString*) applicationDocumentsDirectoryURLString;
+(NSURL*) applicationDocumentsDirectoryURL;

+(NSString*) coreDataStoreName;
+(NSString*) coreDataStoreURLString;
+(NSURL*) coreDataStoreURL;

/**
 Setup should only be called once, in the static singleton accessor would be the only good place I can think of right now.
 */

-(void)setup;

@property (nonatomic, assign, readwrite) BOOL setupSucceeded;
@property (nonatomic, assign, readwrite) BOOL updatingShops;
@property (nonatomic, assign, readwrite) BOOL updatingProducts;

@property (nonatomic, strong, readwrite) RKObjectManager *restKitObjectManager;
@property (nonatomic, strong, readwrite) RKManagedObjectStore* restKitManagedObjectStore;
@property (nonatomic, strong, readwrite) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStore* persistentStore;

@end

#pragma mark - Implementation

@implementation SIDataManager

//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//@synthesize managedObjectContext = _managedObjectContext;


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

#pragma mark - Initialization and Setup

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
        
        // Create managedObjectModel
        
        self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        assert(self.managedObjectModel);
        if (!self.managedObjectModel)
        {
            DDLogError(@"%@ could not initialize managedObjectModel", self);
            self.setupSucceeded = NO;
            return;
        }
        
        // Create restKitManagedObjectStore
        
        self.restKitManagedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
        assert(self.restKitManagedObjectStore);
        if (!self.restKitManagedObjectStore)
        {
            DDLogError(@"%@ could not initialize restKitManagedObjectStore", self);
            self.setupSucceeded = NO;
            return;
        }
        
        // Create persistentStore
        
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
        
        // Create managed object contexts (this will be used for threading)
        
        [self.restKitManagedObjectStore createManagedObjectContexts];
        
        // Create restKitObjectManager
        
        self.restKitObjectManager = [RKObjectManager managerWithBaseURL:[[self class] dataWebServiceURL]];
        assert(self.restKitObjectManager);
        if (!self.restKitObjectManager)
        {
            DDLogError(@"%@ could not initialize restKitObjectManager", self);
            self.setupSucceeded = NO;
            return;
        }
        
        self.setupSucceeded = YES;
        
        // Create mappings
        
        RKEntityMapping *categoryMapping = [RKEntityMapping mappingForEntityForName:@"Category"
                                                               inManagedObjectStore:self.restKitManagedObjectStore];
        
        [categoryMapping addAttributeMappingsFromDictionary:@{ @"id": @"categoryID", @"name": @"name" }];
        
        RKEntityMapping *articleMapping = [RKEntityMapping mappingForEntityForName:@"Article"
                                                              inManagedObjectStore:self.restKitManagedObjectStore];
        
        [articleMapping addAttributeMappingsFromArray:@[@"title", @"author", @"body"]];
        
        [articleMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"categories"
                                                                                       toKeyPath:@"categories"
                                                                                     withMapping:categoryMapping]];

    }
    
    else
    {
        DDLogError(@"%@ setup called multiple times", self);
    }
    

}

#pragma mark - URLs and Directories

+(NSURL*) dataWebServiceURL
{
    return [NSURL URLWithString:@"http://restkit.org"];
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


-(BOOL) checkSetup
{
    assert(self.restKitManagedObjectStore);
    assert(self.managedObjectModel);
    assert(self.restKitObjectManager);
    
    if (self.restKitManagedObjectStore == nil) return NO;
    if (self.managedObjectModel == nil) return NO;
    if (self.restKitObjectManager == nil) return NO;
    
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
    
    return NO;
}

#pragma mark - CoreData Setup

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

#pragma mark - CoreData Fetches

/*

-(NSArray*) fetchAllShops
{
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Shop"
                                                         inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
    if (error)
    {
        DDLogError(@"%@ fetchShops %@ : %@", self, error, [error userInfo]);
    }
    
    DDLogVerbose(@"%@ fetchShops (%lu results)", self, (unsigned long)[fetchResults count]);
    
    return fetchResults;
}

-(NSArray*) fetchAllProductTypes
{
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"ProductType"
                                                         inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
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
                                                         inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
    if (error)
    {
        DDLogError(@"%@ fetchProducts %@ : %@", self, error, [error userInfo]);
    }
    
    DDLogVerbose(@"%@ fetchProducts (%lu results)", self, (unsigned long)[fetchResults count]);
    
    return fetchResults;
}
 
 */

@end
