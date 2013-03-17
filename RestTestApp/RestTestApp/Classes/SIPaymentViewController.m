//
//  PaymentViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIPaymentViewController.h"

#import "SIDataManager.h"
#import "SIHTTPClient.h"
#import "SIThemeManager.h"

#import "SIOrder.h"
#import "SIUser.h"

NSString* const SIPaymentSegueIdentifier = @"Payment";

NSString* const SIPayPalClientID = @"SIPayPalClientID";
NSString* const SIPayPalEmail = @"pay@pal.com";

@interface SIPaymentViewController ()

-(void) reloadInterface;

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadInterface];
}

- (void)viewDidUnload {
    
    [self setTotalTitleLabel:nil];
    [self setTotalPriceLabel:nil];
    [self setMapButton:nil];
    [self setPayButton:nil];
    
    [super viewDidUnload];
}

-(void) reloadInterface
{
    SIOrder* order = [SIHTTPClient sharedClient].currentOrder;
    NSDecimalNumber* totalPriceNumber = [[SIDataManager sharedManager] totalPriceForOrder:order];
    
    self.totalPriceLabel.text = [[SIThemeManager sharedManager].priceNumberFormatter stringFromNumber:totalPriceNumber];
}

#pragma mark - UI Callbacks

- (IBAction)showMap:(id)sender
{
    
}

- (IBAction)processPayment:(id)sender
{
    
    SIUser* user = [SIHTTPClient sharedClient].currentUser;
    SIOrder* order = [SIHTTPClient sharedClient].currentOrder;
    
    assert(user);
    assert(user.email);
    assert(order);
    
    if (!user || !order || !user.email)
    {
        return;
    }
    
    // Create a PayPalPayment
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:@"0.00"];
    payment.currencyCode = @"EUR";
    payment.shortDescription = @"StreatIt";
    
    // Check whether payment is processable.
    
    if (!payment.processable)
    {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
        assert(NO);
        return;
    }
    
    // Start out working with the test environment! When you are ready, remove this line to switch to live.
    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentNoNetwork];
    
    // Provide a payerId that uniquely identifies a user within the scope of your system,
    // such as an email address or user ID.
    
    NSString *aPayerId = user.email;
    
    // Create a PayPalPaymentViewController with the credentials and payerId, the PayPalPayment
    // from the previous step, and a PayPalPaymentDelegate to handle the results.
    
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:SIPayPalClientID
                                                                    receiverEmail:SIPayPalEmail
                                                                          payerId:aPayerId
                                                                          payment:payment
                                                                         delegate:self];
    
    // Present the PayPalPaymentViewController.
    
    [self presentViewController:paymentViewController animated:YES completion:nil];
    
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment
{
    // Send the entire confirmation dictionary
    
    /*
    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
                                                           options:0
                                                             error:nil];
     */
    
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
}

#pragma mark - PayPalPaymentDelegate Methods

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment
{
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel
{
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CardIO (Obsolete)

/*

- (IBAction)scanCard:(id)sender {
    
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
 
 */


@end
