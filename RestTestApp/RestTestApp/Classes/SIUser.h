//
//  SIUser.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/14/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIUser : NSObject <NSCoding>

@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;

@property (nonatomic, assign) BOOL authenticated;

@end
