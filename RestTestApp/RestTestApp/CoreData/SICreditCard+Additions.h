//
//  SICreditCard+Additions.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/5/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SICreditCard.h"

@class CardIOCreditCardInfo;

@interface SICreditCard (Additions)

/**
    Use this method to turn a CardIOCreditCardInfo object to a NSDictionary which can then be converted to an encoded NSData object for storage in CoreData.
 */

+(NSDictionary*) infoDictionaryFromCreditCardInfo:(CardIOCreditCardInfo*)creditCardInfo;

/**
    Use this method to turn a NSDictionary obtained using [SICreditCard infoDictionaryFromCreditCardInfo:] into and encoded NSData object which can be stored into CoreData without being unsafe for the user.
 */

+(NSData*) encodedDataFromInfoDictionary:(NSDictionary*)infoDictionary;

/**
    Use this method to convert from an encoded NSData (stored in CoreData) to a NSDictionary containing the credit card info. 
 */

+(NSDictionary*) infoDictionaryFromEncodedData:(NSData*)encodedData;



@end
