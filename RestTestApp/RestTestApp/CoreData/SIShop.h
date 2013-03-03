//
//  SIShop.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/3/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SIShop : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * shopID;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * openingTimes;
@property (nonatomic, retain) NSString * imageURLString;

@end
