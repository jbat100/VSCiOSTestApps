//
//  SIOrder.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/7/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIOrder.h"
#import "SIOrderPrivate.h"
#import "SIProduct.h"
#import "SIDataManager.h"

#import <BlocksKit/BlocksKit.h>

NSString* const SIOrderChangedNotification = @"SIOrderChangedNotification";

NSString* const SIOrderErrorDomain = @"SIOrderErrorDomain";

const NSInteger SIOrderImmutableErrorCode = 1;
const NSInteger SIOrderPurchaseCountIsZeroErrorCode = 2;

@implementation SIOrder

-(id) init
{
    self = [super init];
    if (self)
    {
        self.purchaseCountDictionary = [NSMutableDictionary dictionary];
        self.state = SIOrderStatePreparing;
    }
    return self;
}

#pragma mark - NSCoding

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        NSDictionary* localPurchaseCountDictionary = [aDecoder decodeObjectForKey:@"SIOrderPurchaseCountDictionary"];
        assert([localPurchaseCountDictionary isKindOfClass:[NSDictionary class]]);
        if ([localPurchaseCountDictionary isKindOfClass:[NSDictionary class]])
        {
            self.purchaseCountDictionary = [NSMutableDictionary dictionaryWithDictionary:localPurchaseCountDictionary];
        }
        
        self.state = (SIOrderState)[aDecoder decodeIntegerForKey:@"SIOrderState"];
        
        self.payKey = [aDecoder decodeObjectForKey:@"SIOrderPayKey"];
        
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

#pragma mark - Helpers

-(BOOL) canProceed
{
    NSArray* values = [self.purchaseCountDictionary allValues];
    BOOL hasAtLeastOnePurchase = [values any:^BOOL(id obj) {
        NSNumber* number = (NSNumber*)obj;
        if ([number isKindOfClass:[NSNumber class]])
        {
            NSInteger integer = [number integerValue];
            if (integer > 0)
            {
                return YES;
            }
        }
        else assert(NO);
        return NO;
    }];
    return hasAtLeastOnePurchase;
}

#pragma mark - Totals

-(NSInteger) totalPurchaseCount
{
    __block NSInteger totalCount = 0;
    
    [self.purchaseCountDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber* countNumber = (NSNumber*)obj;
        NSInteger count = [countNumber integerValue];
        totalCount += count;
    }];
    
    return totalCount;
}

#pragma mark - Purchase Counts

-(BOOL) resetPurchaseCountsError:(NSError*__autoreleasing *)error
{
    if (self.state != SIOrderStatePreparing)
    {
        if (error) *error = [[NSError alloc] initWithDomain:SIOrderErrorDomain code:SIOrderImmutableErrorCode userInfo:nil];
        return NO;
    }
    self.purchaseCountDictionary = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SIOrderChangedNotification object:self];
    
    return YES;
}

-(BOOL) increasePurchaseCountForProduct:(SIProduct*)product error:(NSError*__autoreleasing *)error
{
    if (self.state != SIOrderStatePreparing)
    {
        if (error) *error = [[NSError alloc] initWithDomain:SIOrderErrorDomain code:SIOrderImmutableErrorCode userInfo:nil];
        return NO;
    }
    NSInteger count = [self purchaseCountForProduct:product];
    count++;
    [self.purchaseCountDictionary setObject:[NSNumber numberWithInteger:count] forKey:[product productID]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SIOrderChangedNotification object:self];
    
    return YES;
}

-(BOOL) decreasePurchaseCountForProduct:(SIProduct*)product error:(NSError*__autoreleasing *)error
{
    if (self.state != SIOrderStatePreparing)
    {
        if (error) *error = [[NSError alloc] initWithDomain:SIOrderErrorDomain code:SIOrderImmutableErrorCode userInfo:nil];
        return NO;
    }
    NSInteger count = [self purchaseCountForProduct:product];
    if (count <= 0)
    {
        [self.purchaseCountDictionary setObject:[NSNumber numberWithInteger:0] forKey:[product productID]];
        if (error) *error = [[NSError alloc] initWithDomain:SIOrderErrorDomain code:SIOrderPurchaseCountIsZeroErrorCode userInfo:nil];
        return NO;
    }
    count--;
    [self.purchaseCountDictionary setObject:[NSNumber numberWithInteger:count] forKey:[product productID]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SIOrderChangedNotification object:self];
    
    return YES;
}

-(NSInteger) purchaseCountForProduct:(SIProduct*)product
{
    NSInteger count = 0;
    NSNumber* countNumber = [self.purchaseCountDictionary objectForKey:[product productID]];
    if (countNumber)
    {
        count = [countNumber integerValue];
    }
    return count;
}

-(NSDictionary*) purchaseCounts
{
    if (self.purchaseCountDictionary)
    {
        return [NSDictionary dictionaryWithDictionary:self.purchaseCountDictionary];
    }
    return nil;
}

@end
