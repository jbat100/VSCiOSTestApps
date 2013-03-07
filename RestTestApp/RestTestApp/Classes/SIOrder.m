//
//  SIOrder.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/7/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIOrder.h"

#import "SIProduct.h"

NSString * const SIOrderErrorDomain = @"SIOrderErrorDomain";

const NSInteger SIOrderImmutableErrorCode = 1;
const NSInteger SIOrderPurchaseCountIsZeroErrorCode = 2;

@interface SIOrder ()

@property (nonatomic, assign) SIOrderState state;

@property (nonatomic, strong) NSMutableDictionary* purchaseCountDictionary; // keys are [SIProduct productID] values are NSNumber (NSInteger)

@end

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

-(BOOL) resetPurchaseCountsError:(NSError*__autoreleasing *)error
{
    if (self.state != SIOrderStatePreparing)
    {
        if (error) *error = [[NSError alloc] initWithDomain:SIOrderErrorDomain code:SIOrderImmutableErrorCode userInfo:nil];
        return NO;
    }
    self.purchaseCountDictionary = [NSMutableDictionary dictionary];
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
