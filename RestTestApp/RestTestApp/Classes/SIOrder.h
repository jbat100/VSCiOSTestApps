//
//  SIOrder.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/7/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SIProduct;

/**
 Error domains and codes.
 */

extern NSString * const SIOrderErrorDomain;

extern const NSInteger SIOrderImmutableErrorCode;
extern const NSInteger SIOrderPurchaseCountIsZeroErrorCode;

/**
 Order State.
 */
typedef enum _SIOrderState {
    SIOrderStateNone = 0,   // should never happen, order can NOT be mutated
    SIOrderStatePreparing,  // order CAN be mutated
    SIOrderStateOngoing,    // order can NOT be mutated
    SIOrderStateDone        // order can NOT be mutated
} SIOrderState;


/**
 SIOrder used to manage an order, keeps track of purchase counts for each product
 */

@interface SIOrder : NSObject

@property (nonatomic, assign, readonly) SIOrderState state;
@property (nonatomic, strong, readonly) NSDictionary* outcomeInfo; // Info on order outcome (nil if state is not SIOrderStateDone)

/**
 Order management, operations can fail if:
 - State is not SIOrderStatePreparing, error code SIOrderImmutableErrorCode
 - Additionally decreasePurchaseCountForProduct: can fail if the current purchase count is 0, see SIOrderPurchaseCountIsZeroErrorCode
 */

-(BOOL) resetPurchaseCountsError:(NSError**)error;
-(BOOL) increasePurchaseCountForProduct:(SIProduct*)product error:(NSError**)error;
-(BOOL) decreasePurchaseCountForProduct:(SIProduct*)product error:(NSError**)error;

/**
 Order access methods, can be accesses in any state
 */

-(NSInteger) purchaseCountForProduct:(SIProduct*)product;
-(NSDictionary*) purchaseCounts; // [SIProduct productID] as Key, NSNumber (NSInteger) as Value


@end
