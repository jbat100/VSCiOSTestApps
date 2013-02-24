//
//  SIProduct.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/25/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SICategory;

@interface SIProduct : NSManagedObject

@property (nonatomic, retain) NSString * productDescription;
@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) SICategory *category;

@end
