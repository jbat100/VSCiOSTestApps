//
//  StreatitHTTPClient.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/1/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "AFHTTPClient.h"

@interface StreatitHTTPClient : AFHTTPClient

+ (StreatitHTTPClient *)sharedClient;

- (id)initWithBaseURL:(NSURL *)url;

@end
