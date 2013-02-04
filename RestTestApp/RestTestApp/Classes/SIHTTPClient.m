//
//  StreatitHTTPClient.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIHTTPClient.h"

#import "AFJSONRequestOperation.h"

static NSString * const kStreatitAPIBaseURLString = @"https://api.twitter.com/1.1/";

@implementation SIHTTPClient

+ (SIHTTPClient *)sharedClient
{
    static SIHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SIHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kStreatitAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    //self.parameterEncoding = AFFormURLParameterEncoding;
    
    self.parameterEncoding = AFJSONParameterEncoding;
    
    return self;
}

@end
