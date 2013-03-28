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
#import "SIOrderPrivate.h"
#import "SIUser.h"

#import "PayPalPayment.h"
#import "PayPalAdvancedPayment.h"
#import "PayPalAmounts.h"
#import "PayPalReceiverAmounts.h"
#import "PayPalAddress.h"
#import "PayPalInvoiceItem.h"

/*
 
 Paypal details:
 
 compte dev pr la sandbox:
 devpaypal@primase.fr
 mdp: D3vpaypal
 
 Endpoint:
 api.sandbox.paypal.com
 Client ID
 AZQmDRCZqzqJSDgbjWy7XpNlWhU_7G8_FcKrnrxDkPHXlGfekbLpiLSQfiHv
 Secret
 EDGcMhBlaBc0UH7ILVosLnqYo9glZgt2D--7331-126amR_RqxsxfM8esk0a
 
 compte marchand 1:
 martroi@primase.fr
 mdp: pressepresse
 
 compte client 1:
 client@primase.fr
 mdp pressepresse
 
 */

typedef enum SIPayPalPaymentStatus {
	SIPayPalPaymentStatusNone = 0,
	SIPayPalPaymentStatusSuccess,
	SIPayPalPaymentStatusFailed,
    SIPayPalPaymentStatusCancelled
} SIPayPalPaymentStatus;

NSString* const SIPaymentSegueIdentifier = @"Payment";

NSString* const SIPayPalClientID = @"AZQmDRCZqzqJSDgbjWy7XpNlWhU_7G8_FcKrnrxDkPHXlGfekbLpiLSQfiHv";
NSString* const SIPayPalEmail = @"devpaypal@primase.fr";

@interface SIPaymentViewController ()

@property (nonatomic, strong) SIOrder* order;

@property (nonatomic, assign) SIPayPalPaymentStatus payPalPaymentStatus;

-(void) reloadInterface;

+(NSString*) orderFilePath;
+(NSString*) payPalMessageResponseDescription;

@end

@implementation SIPaymentViewController

+(NSString*) orderFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [path stringByAppendingPathComponent:@"Order.archive"];
}

+(NSString*) payPalMessageResponseDescription
{
    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
	NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
	NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
	NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
    return [NSString stringWithFormat:@"[severity: %@, category: %@, errorId: %@, message: %@]", severity, category, errorId, message];
}

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
    
    //-- required parameters --
	//target is a class which implements the PayPalPaymentDelegate protocol.
	//action is the selector to call when the button is clicked.
	//inButtonType is the button type (desired size).
	//
	//-- optional parameter --
	//inButtonText can be either BUTTON_TEXT_PAY (default, displays "Pay with PayPal"
	//in the button) or BUTTON_TEXT_DONATE (displays "Donate with PayPal" in the
	//button). the inButtonText parameter also affects some of the library behavior
	//and the wording of some messages to the user.
    
    self.payPalPaymentStatus = SIPayPalPaymentStatusNone;
    
    /*
	UIButton *button = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:action andButtonType:type];
	CGRect frame = button.frame;
	frame.origin.x = round((self.view.frame.size.width - button.frame.size.width) / 2.);
	frame.origin.y = round(y + size.height);
	button.frame = frame;
	[self.view addSubview:button];
    */
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

-(IBAction)processPaymentXCommerceSDK:(id)sender
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
    
    NSDecimalNumber* totalPrice = [[SIDataManager sharedManager] totalPriceForOrder:order];
    
    /*
     *  PAYPAL STUFF
     */
    
	
	//optional, set shippingEnabled to TRUE if you want to display shipping
	//options to the user, default: TRUE
	[PayPal getPayPalInst].shippingEnabled = FALSE;
	
	//optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	//shipping and tax based on the user's address choice, default: FALSE
	[PayPal getPayPalInst].dynamicAmountUpdateEnabled = FALSE;
	
	//optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER 
	[PayPal getPayPalInst].feePayer = FEEPAYER_EACHRECEIVER;
	
	//for a payment with a single recipient, use a PayPalPayment object
	PayPalPayment *payment = [[PayPalPayment alloc] init];
	payment.recipient = @"martroi@primase.fr";
	payment.paymentCurrency = @"EUR";
	payment.description = @"Paiement StreatIt";
	payment.merchantName = @"StreatIt";
	
	//subtotal of all items, without tax and shipping
	payment.subTotal = totalPrice;
	
	//invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
	payment.invoiceData = [[PayPalInvoiceData alloc] init];
	payment.invoiceData.totalShipping = [NSDecimalNumber decimalNumberWithString:@"2"];
	payment.invoiceData.totalTax = [NSDecimalNumber decimalNumberWithString:@"0.35"];
	
	//invoiceItems is a list of PayPalInvoiceItem objects
	//NOTE: sum of totalPrice for all items must equal payment.subTotal
	//NOTE: example only shows a single item, but you can have more than one
	payment.invoiceData.invoiceItems = [NSMutableArray array];
	PayPalInvoiceItem *item = [[PayPalInvoiceItem alloc] init];
	item.totalPrice = payment.subTotal;
	item.name = @"Paiement StreatIt";
	[payment.invoiceData.invoiceItems addObject:item];
    
    self.order = order; // remember the order for when callback comes...
    
    self.order.paidPrice = totalPrice;
	
	[[PayPal getPayPalInst] checkoutWithPayment:payment];
    
}

/*
    This is not used because EUR is not supported

- (IBAction)processPaymentPaypalSDK:(id)sender
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
    
    NSDecimalNumber* totalPrice = [[SIDataManager sharedManager] totalPriceForOrder:order];
    
    DDLogVerbose(@"%@ processing payment for total: %@", self, totalPrice);
    
    // Create a PayPalPayment
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = totalPrice;
    //payment.currencyCode = @"EUR"; // EUR not supported...
    payment.currencyCode = @"USD";
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
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
}
 
  */

#pragma mark - PayPalPaymentDelegate (XCommerce)

- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus
{
    assert(self.order);
    if (!self.order)
    {
        DDLogError(@"Got PayPalPaymentDelegate paymentSuccessWithKey: callback with no order");
        return;
    }
    
    DDLogVerbose(@"%@ paymentSuccessWithKey: %@ andStatus: %d %@", self, payKey, paymentStatus, [[self class] payPalMessageResponseDescription]);
    
    self.order.payKey = payKey;
    
    /*
     Save order to disk so that we have a record of it if things go wrong when authenticating with StreatIt server
     */
    
    NSString* orderFilePath = [[self class] orderFilePath];
    //assert(orderFilePath);
    if (orderFilePath)
    {
        BOOL success = [NSKeyedArchiver archiveRootObject:self.order toFile:orderFilePath];
        assert(success);
    }

    self.payPalPaymentStatus = SIPayPalPaymentStatusSuccess;
    
}

- (void)paymentFailedWithCorrelationID:(NSString *)correlationID
{
    DDLogVerbose(@"%@ paymentFailedWithCorrelationID: %@ %@", self, correlationID, [[self class] payPalMessageResponseDescription]);
    
    self.payPalPaymentStatus = SIPayPalPaymentStatusFailed;
}

- (void)paymentCanceled
{    
    DDLogVerbose(@"%@ paymentCanceled %@", self, [[self class] payPalMessageResponseDescription]);
    
    self.payPalPaymentStatus = SIPayPalPaymentStatusCancelled;
}

- (void)paymentLibraryExit
{
    
    DDLogVerbose(@"%@ paymentLibraryExit payPalPaymentStatus : %d", self, [[self class] payPalMessageResponseDescription], self.payPalPaymentStatus);
    
    switch (self.payPalPaymentStatus)
    {
        case SIPayPalPaymentStatusSuccess:
        {
            /*
             Now validate with streat it server!
             */
        }
            break;
            
        case SIPayPalPaymentStatusCancelled:
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                                message:@"Le Paiement a été annulé"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
            break;
            
        case SIPayPalPaymentStatusFailed:
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                                message:@"Le Paiement a échoué"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
            break;
            
        default:
            DDLogError(@"%@ paymentLibraryExit unexpected payPalPaymentStatus %d", self, self.payPalPaymentStatus);
            break;
    }
    
}


#pragma mark - PayPalPaymentDelegate Methods (Obselete)

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment
{
    //DDLogVerbose(@"%@ payPalPaymentDidComplete: %@, confirmation: %@", self, completedPayment, completedPayment.confirmation);
    
    /*
     
     confirmation: {
        client =     {
            environment = mock;
            "paypal_sdk_version" = "1.0.2";
            platform = iOS;
            "product_name" = "PayPal iOS SDK";
        };
        payment =     {
            amount = "12.00";
            "currency_code" = USD;
            "short_description" = StreatIt;
        };
        "proof_of_payment" =     {
            "adaptive_payment" =         {
            "app_id" = "APP-1234567890";
            "pay_key" = "AP-70M68096ML426802W";
            "payment_exec_status" = COMPLETED;
            timestamp = "2013-03-24T14:27:25Z";
        };
     };

     
     */
    
    // Payment was processed successfully; send to server for verification and fulfillment.
    //[self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel
{
    DDLogVerbose(@"%@ payPalPaymentDidCancel", self);
    
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
