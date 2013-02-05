//
//  SIProductType.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/5/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SIProduct;

@interface SIProductType : NSManagedObject

@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *products;
@end

@interface SIProductType (CoreDataGeneratedAccessors)

- (void)addProductsObject:(SIProduct *)value;
- (void)removeProductsObject:(SIProduct *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
