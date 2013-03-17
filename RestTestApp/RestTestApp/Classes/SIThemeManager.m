//
//  SIThemeManager.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/10/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIThemeManager.h"

@interface SIThemeManager ()

@end

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
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6"))
        {
            // I think this one looks better but only available on iOS 6+
            self.defaultPriceFont = [UIFont fontWithName:@"AvenirNext-Heavy" size:24];
            self.defaultProductNameFont = [UIFont fontWithName:@"AvenirNext-Heavy" size:18];
        }
        else
        {
            self.defaultPriceFont = [UIFont fontWithName:@"GillSans-Bold" size:24];
            self.defaultProductNameFont = [UIFont fontWithName:@"GillSans-Bold" size:18];
        }
        
        self.defaultBigPriceFont = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];
        
        self.defaultButtonLabelFont = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
        self.defaultTitleFont = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
        
        self.defaultCategoryNameFont = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
        
        self.defaultProductDescriptionFont = [UIFont fontWithName:@"Futura-CondensedMedium" size:14];
        
        self.defaultButtonLabelTextColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - Global

-(void) performGlobalAppearanceSetup
{
    NSDictionary* titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor],
                                          UITextAttributeFont : self.defaultTitleFont};
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
    
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
}



@end
