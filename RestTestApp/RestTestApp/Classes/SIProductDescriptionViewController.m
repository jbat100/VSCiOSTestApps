//
//  ProductDescriptionViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIProductDescriptionViewController.h"
#import "SIShoppingCartViewController.h"

#import "SIProduct.h"
#import "SIDataManager.h"
#import "SIOrder.h"

NSString* const SIProductDescriptionSegueIdentifier = @"ProductDescription";

@interface SIProductDescriptionViewController ()

@property (nonatomic, strong) IBOutlet UIView* lowerView;
@property (nonatomic, strong) NSNumberFormatter* priceNumberFormatter;
@property (nonatomic, strong) UIBarButtonItem* shoppingCartButtonItem;

-(void) customInit;
-(void) reloadInterface;

-(void) updateCountLabel;

@end

@implementation SIProductDescriptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self customInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self customInit];
    }
    return self;
}

-(void) customInit
{
    self.priceNumberFormatter = [[NSNumberFormatter alloc] init];
    [self.priceNumberFormatter setCurrencySymbol:@"€"];
    [self.priceNumberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    self.shoppingCartButtonItem = [[UIBarButtonItem alloc] initWithTitle:SIShoppingCartButtonTitle
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(showShoppingCart:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self reloadInterface];
}

-(void) viewDidUnload
{
    [super viewDidUnload];
    
    self.productImageView = nil;
    self.productNameLabel = nil;
    self.productPriceLabel = nil;
    self.productDescriptionTextView = nil;
    self.addButton = nil;
    self.removeButton = nil;
    self.purchaseCountLabel = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.backBarButtonItem.title = @"Produits";
    
    [self.navigationItem setRightBarButtonItem:self.shoppingCartButtonItem animated:animated];
    
    [self reloadInterface];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) reloadInterface
{
    BOOL hide = YES;
    
    if (self.product)
    {
        self.productImageView = nil;
        self.productNameLabel.text = [self.product name];
        self.productPriceLabel.text = [self.priceNumberFormatter stringFromNumber:[self.product price]];
        self.productDescriptionTextView.text = [self.product productDescription];
        
        [self updateCountLabel];
        
        hide = NO;
    }

    self.productImageView.hidden = hide;
    self.productNameLabel.hidden = hide;
    self.productPriceLabel.hidden = hide;
    self.productDescriptionTextView.hidden = hide;
    self.addButton.hidden = hide;
    self.removeButton.hidden = hide;
    self.purchaseCountLabel.hidden = hide;
}

#pragma mark - Custom Setters

-(void) setProduct:(SIProduct *)product
{
    _product = product;
    [self reloadInterface];
}

#pragma mark - UIHelpers

-(void) updateCountLabel
{
    NSInteger count = [[SIDataManager sharedManager].currentOrder purchaseCountForProduct:self.product];
    self.purchaseCountLabel.text = [NSString stringWithFormat:@"Quantité: %d", count];
}

#pragma mark - UICallbacks

-(void) showShoppingCart:(id)sender
{
    [self performSegueWithIdentifier:SIShoppingCartSegueIdentifier sender:self];
}

-(IBAction)increasePurchaseCount:(id)sender
{
    if (self.product)
    {
        [[SIDataManager sharedManager].currentOrder increasePurchaseCountForProduct:self.product error:nil];
        [self updateCountLabel];
    }
}

-(IBAction)decreasePurchaseCount:(id)sender
{
    if (self.product)
    {
        [[SIDataManager sharedManager].currentOrder decreasePurchaseCountForProduct:self.product error:nil];
        [self updateCountLabel];
    }
}

@end
