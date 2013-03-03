//
//  SIShopAnnotation.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/3/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIShopAnnotation.h"
#import <MapKit/MapKit.h>

@implementation SIShopAnnotation

-(void)setShop:(SIShop *)shop
{
    _shop = shop;
    
    assert(shop);
    
    if ([shop name])
    {
        self.title = [shop name];
    }
    else
    {
        self.title = @"";
        assert(NO);
    }
    
    if ([shop latitude] && [shop longitude])
    {
        self.coordinate = CLLocationCoordinate2DMake([[shop latitude] doubleValue], [[shop longitude] doubleValue]);
    }
    else
    {
        self.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        assert(NO);
    }
}

@end
