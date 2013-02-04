//
//  PaymentViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIPaymentViewController.h"

@interface SIPaymentViewController ()

//@property (nonatomic, strong) CardIOPaymentViewController *scanViewController;

@end

@implementation SIPaymentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanCard:(id)sender {
    
    /*
     *  Create a new one every time just to be sure nothing funny happens...
     */
    
    CardIOPaymentViewController *scanViewController = nil;
    
    scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    //scanViewController.appToken = @"116519433a614dd8bd56b0f3fd6c6c95"; // get your app token from the card.io website
    
    [self presentModalViewController:scanViewController animated:YES];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissModalViewControllerAnimated:YES];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo*)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %02i/%i, cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv);
    self.creditCardInfo = info;
    // Use the card info...
    [scanViewController dismissModalViewControllerAnimated:YES];
}

@end
