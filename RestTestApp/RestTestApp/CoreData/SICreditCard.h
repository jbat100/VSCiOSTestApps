//
//  SICreditCard.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/5/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SIUser;

@interface SICreditCard : NSManagedObject

@property (nonatomic, retain) NSData * encodedInfo;
@property (nonatomic, retain) SIUser *user;

@end
