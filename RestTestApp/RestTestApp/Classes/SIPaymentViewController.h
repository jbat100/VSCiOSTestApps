//
//  PaymentViewController.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CardIO.h"

@interface SIPaymentViewController : UIViewController <CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) CardIOCreditCardInfo* creditCardInfo;

- (IBAction)scanCard:(id)sender;

@end
