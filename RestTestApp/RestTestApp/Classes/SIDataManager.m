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

+(NSString*) applicationDocumentsDirectoryURLString;
+(NSURL*) applicationDocumentsDirectoryURL;

+(NSString*) coreDataStoreName;
+(NSString*) coreDataStoreURLString;
+(NSURL*) coreDataStoreURL;

@property (nonatomic, assign, readwrite) BOOL updatingShops;
@property (nonatomic, assign, readwrite) BOOL updatingProducts;

@property (nonatomic, strong) RKManagedObjectStore* restManagedObjectStore;

@end

#pragma mark - Implementation

@implementation SIDataManager

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;

+(void) initialize
{
    NSError *error = nil;
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (!success)
    {
        DDLogError(@"%@ failed to create application data directory at path '%@': %@", self, RKApplicationDataDirectory(), error);
        assert(NO);
    }
}

+(SIDataManager*) sharedManager
{
    static SIDataManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SIDataManager alloc] init];
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

#pragma mark - Directories


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

#pragma mark - Update API

-(BOOL) updateShopsError:(NSError**)pError
{
    
}

-(BOOL) updateProductsError:(NSError**)pError
{
    
}

#pragma mark - CoreData Setup

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
    
    NSURL *storeURL = [[[self class] applicationDocumentsDirectoryURL] URLByAppendingPathComponent:@"StreatModel1.sqlite"];
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

#pragma mark - CoreData Fetches

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

@end
