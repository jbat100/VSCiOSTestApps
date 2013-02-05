//
//  SIUser.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/5/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SICreditCard;

@interface SIUser : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSData * encodedPassword;
@property (nonatomic, retain) NSString * serverIdentifier;
@property (nonatomic, retain) NSSet *creditCards;
@end

@interface SIUser (CoreDataGeneratedAccessors)

- (void)addCreditCardsObject:(SICreditCard *)value;
- (void)removeCreditCardsObject:(SICreditCard *)value;
- (void)addCreditCards:(NSSet *)values;
- (void)removeCreditCards:(NSSet *)values;

@end
