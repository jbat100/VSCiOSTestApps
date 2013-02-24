//
//  SICategory.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/25/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SIProduct;

@interface SICategory : NSManagedObject

@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * categoryDescription;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSSet *products;
@end

@interface SICategory (CoreDataGeneratedAccessors)

- (void)addProductsObject:(SIProduct *)value;
- (void)removeProductsObject:(SIProduct *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
