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

-(void) performAppearanceSetup;

-(void) applyThemeToPriceLabel:(UILabel*)label;
-(void) applyThemeToBigPriceLabel:(UILabel*)label;

-(void) applyThemeToCategoryNameLabel:(UILabel*)label;

-(void) applyThemeToProductNameLabel:(UILabel*)label;
-(void) applyThemeToProductDescriptionLabel:(UILabel*)label;
-(void) applyThemeToProductDescriptionTextView:(UITextView*)textView;

@end
