//
//  SIShopAnnotation.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/3/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SIShop.h"

@interface SIShopAnnotation : MKPointAnnotation

@property (nonatomic, weak) SIShop* shop;

@end
