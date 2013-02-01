//
//  Product.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProductType;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * detailedDescription;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) NSString * briefDescription;
@property (nonatomic, retain) ProductType *productType;

@end
