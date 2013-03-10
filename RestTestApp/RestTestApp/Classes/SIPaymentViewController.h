//
//  PaymentViewController.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const SIPaymentSegueIdentifier;

@interface SIPaymentViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UILabel *totalTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) IBOutlet UIButton *payButton;

- (IBAction)showMap:(id)sender;
- (IBAction)processPayment:(id)sender;

@end
