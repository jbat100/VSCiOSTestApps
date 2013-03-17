//
//  SIUser.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/14/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIUser.h"

@implementation SIUser

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.firstName = [aDecoder decodeObjectForKey:@"SIUserFirstName"];
        self.lastName = [aDecoder decodeObjectForKey:@"SIUserLastName"];
        self.email = [aDecoder decodeObjectForKey:@"SIUserEmail"];
        self.authenticated = [aDecoder decodeBoolForKey:@"SIUserAuthenticated"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.firstName forKey:@"SIUserFirstName"];
    [aCoder encodeObject:self.lastName forKey:@"SIUserLastName"];
    [aCoder encodeObject:self.email forKey:@"SIUserEmail"];
    [aCoder encodeBool:self.authenticated forKey:@"SIUserAuthenticated"];
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"<%@ %p> firstName: %@, lastName: %@, email: %@",
            [[self class] description], self, self.firstName, self.lastName, self.email];
}

@end
