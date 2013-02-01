//
//  StreatitDataManager.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "StreatitDataManager.h"

@implementation StreatitDataManager

+(StreatitDataManager*) sharedManager
{
    static StreatitDataManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[StreatitDataManager alloc] init];
    });
    return _sharedClient;
}

@end
