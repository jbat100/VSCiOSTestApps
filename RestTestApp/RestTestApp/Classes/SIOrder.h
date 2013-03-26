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
 Notifications
 */

extern NSString* const SIOrderChangedNotification;

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
    SIOrderStateOngoing,    // order can NOT be mutated (back to SIOrderStatePreparing if fails, to SIOrderStateOngoing if succeeds)
    SIOrderStateValidated,  // validated by paypal order can NOT be mutated, once the order is done, there is no going back
    SIOrderStatePerformed   // verified with StreatIt, order can NOT be mutated, once the order is verified, there is no going back
} SIOrderState;


/**
 SIOrder used to manage an order, keeps track of purchase counts for each product
 */

@interface SIOrder : NSObject <NSCoding>

@property (nonatomic, assign, readonly) SIOrderState state;
@property (nonatomic, strong, readonly) NSString* payKey; // Paypal Key (nil if state is not SIOrderStateValidated or SIOrderStatePerformed)
@property (nonatomic, strong) NSString* shopId; // this must be a valid shop id for the order to be performed
@property (nonatomic, strong) NSDecimalNumber* paidPrice; // the price which the user paid to paypal

/**
 Order management, operations can fail if:
 - State is not SIOrderStatePreparing, error code SIOrderImmutableErrorCode
 - Additionally decreasePurchaseCountForProduct: can fail if the current purchase count is 0, see SIOrderPurchaseCountIsZeroErrorCode
 */

-(BOOL) resetPurchaseCountsError:(NSError**)error;
-(BOOL) increasePurchaseCountForProduct:(SIProduct*)product error:(NSError**)error;
-(BOOL) decreasePurchaseCountForProduct:(SIProduct*)product error:(NSError**)error;

/**
 Will return YES if there is any point in performing the order (basically if there is at least one product with a purchase count greater than 0)
 */

-(BOOL) canProceed;

/**
 Total purchase count
 */

-(NSInteger) totalPurchaseCount;
 

/**
 Order access methods, can be accesses in any state
 */

-(NSInteger) purchaseCountForProduct:(SIProduct*)product;
-(NSDictionary*) purchaseCounts; // [SIProduct productID] as Key, NSNumber (NSInteger) as Value

@end
