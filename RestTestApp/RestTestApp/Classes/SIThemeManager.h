//
//  SIThemeManager.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/10/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIThemeManager : NSObject

+(SIThemeManager*) sharedManager;

@property (nonatomic, strong) NSNumberFormatter* priceNumberFormatter;

-(void) performGlobalAppearanceSetup;

@property (nonatomic, copy) UIFont* defaultTitleFont;
@property (nonatomic, copy) UIFont* defaultButtonLabelFont;
@property (nonatomic, copy) UIFont* defaultPriceFont;
@property (nonatomic, copy) UIFont* defaultBigPriceFont;
@property (nonatomic, copy) UIFont* defaultCategoryNameFont;
@property (nonatomic, copy) UIFont* defaultProductNameFont;
@property (nonatomic, copy) UIFont* defaultProductDescriptionFont;

@property (nonatomic, copy) UIColor* defaultButtonLabelTextColor;

@end
