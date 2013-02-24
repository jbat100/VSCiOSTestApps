//
//  SIShop.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/25/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SIShop : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;

@end
