//
//  ProductType.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ProductType : NSManagedObject

@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *products;
@end

@interface ProductType (CoreDataGeneratedAccessors)

- (void)addProductsObject:(NSManagedObject *)value;
- (void)removeProductsObject:(NSManagedObject *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
