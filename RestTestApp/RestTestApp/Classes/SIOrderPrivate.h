//
//  SIOrder.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/7/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIOrder.h"

@interface SIOrder ()

@property (nonatomic, assign) SIOrderState state;
@property (nonatomic, strong) NSMutableDictionary* purchaseCountDictionary; // keys are [SIProduct productID] values are NSNumber (NSInteger)
@property (nonatomic, strong) NSString* payKey;

@end

