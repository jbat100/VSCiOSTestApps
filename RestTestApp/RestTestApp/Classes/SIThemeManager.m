//
//  SIThemeManager.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/10/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIThemeManager.h"

@implementation SIThemeManager

+(SIThemeManager*) sharedManager
{
    static SIThemeManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SIThemeManager alloc] init];
        assert(_sharedManager);
    });
    return _sharedManager;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        self.priceNumberFormatter = [[NSNumberFormatter alloc] init];
        [self.priceNumberFormatter setCurrencySymbol:@"€"];
        [self.priceNumberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    }
    return self;
}

-(void) performAppearanceSetup
{
    
}

-(void) applyThemeToPriceLabel:(UILabel*)label
{
    
}

-(void) applyThemeToBigPriceLabel:(UILabel*)label
{
    
}


-(void) applyThemeToCategoryNameLabel:(UILabel*)label
{
    
}

-(void) applyThemeToProductNameLabel:(UILabel*)label
{
    
}

-(void) applyThemeToProductDescriptionLabel:(UILabel*)label
{
    
}

-(void) applyThemeToProductDescriptionTextView:(UITextView*)textView
{
    
}


@end
