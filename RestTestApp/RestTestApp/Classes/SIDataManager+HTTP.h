//
//  SIDataManager+HTTP.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/28/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIDataManager.h"

@class SIUser;
@class SIOrder;

@interface SIDataManager (HTTP)

/**
 Error conversion
 */

+(NSError*) translateRequestError:(NSError*)error;

/**
 JSON Helper: Transform an Order into its StreatIt compatible JSON representation
 */

+(NSArray*) productJSONArrayForOrder:(SIOrder*)order;

/**
 Price Helper: Transform a NSDecimalNumber price in euros into a string representing the number of centimes 
 */

+(NSString*) stringInCentimesForPriceInEuros:(NSDecimalNumber*)euros;

/**
 Updates SIShops to the ones encoded in a JSON array
 */

-(void) updateDatabaseShopsWithJSONArray:(NSArray*)jsonArray;

-(void) updateDatabaseShopsWithJSONArray:(NSArray*)jsonArray;

@end
