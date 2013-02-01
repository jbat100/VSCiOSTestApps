//
//  StreatitDataManager.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "StreatitDataManager.h"
#import "DDLog.h"

#import <CoreData/CoreData.h>

@interface StreatitDataManager ()


@end

@implementation StreatitDataManager

+(StreatitDataManager*) sharedManager
{
    static StreatitDataManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[StreatitDataManager alloc] init];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"StreatModel1.sqlite"];
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

-(NSArray*) fetchShops
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
    
    DDLogVerbose(@"%@ fetchShops (%d results)", [fetchResults count]);
    
    return fetchResults;
}

-(NSArray*) fetchProductTypes
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
    
    DDLogVerbose(@"%@ fetchProductTypes (%d results)", [fetchResults count]);
    
    return fetchResults;
}

-(NSArray*) fetchProducts
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
    
    DDLogVerbose(@"%@ fetchProducts (%d results)", [fetchResults count]);
    
    return fetchResults;
}

@end
