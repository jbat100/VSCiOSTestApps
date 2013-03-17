//
//  ProductListingViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIProductListingViewController.h"
#import "SIProductDescriptionViewController.h"
#import "SIShoppingCartViewController.h"

#import "SIDataManager.h"
#import "SIHTTPClient.h"
#import "SIThemeManager.h"

#import "SIProduct.h"
#import "SIProductDescriptionCell.h"
#import "SIOrder.h"

@interface SIProductListingViewController ()

@property (nonatomic, strong) UIBarButtonItem* shoppingCartButtonItem;

-(void) customInit;

-(IBAction)increasePurchaseCount:(id)sender;
-(IBAction)decreasePurchaseCount:(id)sender;

-(void) setPurchaseCount:(NSInteger)purchaseCount forCell:(SIProductDescriptionCell*)cell;

@property (nonatomic, strong) SIProduct* selectedProduct;

@end

@implementation SIProductListingViewController

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
    self.shoppingCartButtonItem = [[UIBarButtonItem alloc] initWithTitle:SIShoppingCartButtonTitle
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(showShoppingCart:)];
}

-(void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    assert(self.tableView);
    assert(self.tableView.delegate == self);
    assert(self.tableView.dataSource == self);
    
    [self.tableView reloadData];
}

-(void)viewDidUnload
{
    self.tableView = nil;
    
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.navigationItem.backBarButtonItem.title = @"Categories";
    
    [self.navigationItem setRightBarButtonItem:self.shoppingCartButtonItem animated:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:SIProductDescriptionSegueIdentifier])
    {
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Produits"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        
        SIProductDescriptionViewController* viewController = segue.destinationViewController;
        if ([viewController isKindOfClass:[SIProductDescriptionViewController class]])
        {
            viewController.product = self.selectedProduct;
        }
        else assert(NO);
    }
    
    if ([segue.identifier isEqualToString:SIShoppingCartSegueIdentifier])
    {
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        
        SIShoppingCartViewController* viewController = segue.destinationViewController;
        if ([viewController isKindOfClass:[SIShoppingCartViewController class]])
        {
            self.navigationItem.backBarButtonItem = backButton;
        }
        else assert(NO);
    }
}

#pragma mark - UI Helpers

-(void) setPurchaseCount:(NSInteger)purchaseCount forCell:(SIProductDescriptionCell*)cell
{
    if ([cell isKindOfClass:[SIProductDescriptionCell class]] == NO)
    {
        DDLogError(@"%@ setPurchaseCount:forCell: INVALID CELL: %@", self, cell);
        return;
    }
    
    if (purchaseCount >= 0)
    {
        cell.purchaseCountLabel.text = [NSString stringWithFormat:@"%d", purchaseCount];
    }
    if (purchaseCount < 0)
    {
        cell.purchaseCountLabel.text = @""; // this is an error, lets be discreet about it...
        assert(NO);
    }
}

#pragma mark - UICallbacks

-(void) showShoppingCart:(id)sender
{
    [self performSegueWithIdentifier:SIShoppingCartSegueIdentifier sender:self];
}

-(IBAction)increasePurchaseCount:(id)sender
{
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointMake(0, 0) toView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:buttonPosition];
    SIProductDescriptionCell* cell = (SIProductDescriptionCell*)[self.tableView cellForRowAtIndexPath:path];
    
    if (path)
    {
        if ([self.products count] > path.row)
        {
            SIProduct* product = [self.products objectAtIndex:path.row];
            [[SIHTTPClient sharedClient].currentOrder increasePurchaseCountForProduct:product error:nil];
            NSInteger count = [[SIHTTPClient sharedClient].currentOrder purchaseCountForProduct:product];
            [self setPurchaseCount:count forCell:cell];
        } else assert(NO);
    } else assert(NO);
}

-(IBAction)decreasePurchaseCount:(id)sender
{
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointMake(0, 0) toView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:buttonPosition];
    SIProductDescriptionCell* cell = (SIProductDescriptionCell*)[self.tableView cellForRowAtIndexPath:path];
    
    if (path)
    {
        if ([self.products count] > path.row)
        {
            SIProduct* product = [self.products objectAtIndex:path.row];
            [[SIHTTPClient sharedClient].currentOrder decreasePurchaseCountForProduct:product error:nil];
            NSInteger count = [[SIHTTPClient sharedClient].currentOrder purchaseCountForProduct:product];
            [self setPurchaseCount:count forCell:cell];
        } else assert(NO);
    } else assert(NO);
}

#pragma mark - UITableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* SIProductCellIdentifier = @"SIProductCellIdentifier";
    SIProductDescriptionCell* cell = (SIProductDescriptionCell*)[tableView dequeueReusableCellWithIdentifier:SIProductCellIdentifier];
    assert(cell); // we should always get a cell (using storyboard)
    {
        cell.productNameLabel.backgroundColor = [UIColor clearColor];
        cell.productPriceLabel.backgroundColor = [UIColor clearColor];
        cell.productDescriptionLabel.backgroundColor = [UIColor clearColor];
        cell.productNameLabel.backgroundColor = [UIColor clearColor];
        
        cell.productNameLabel.font = [SIThemeManager sharedManager].defaultProductNameFont;
        cell.productDescriptionLabel.font = [SIThemeManager sharedManager].defaultProductDescriptionFont;
        cell.productPriceLabel.font = [SIThemeManager sharedManager].defaultPriceFont;
    }
    
    if ([self.products count] > indexPath.row)
    {
        SIProduct *product = [self.products objectAtIndex:indexPath.row];
        cell.productNameLabel.text = [product name];
        NSString* priceString = [[SIThemeManager sharedManager].priceNumberFormatter stringFromNumber:[product price]];
        cell.productPriceLabel.text = priceString;
        cell.productDescriptionLabel.text = [product productDescription];
        NSInteger count = [[SIHTTPClient sharedClient].currentOrder purchaseCountForProduct:product];
        [self setPurchaseCount:count forCell:cell];
    }
    else assert(NO);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.products count] > indexPath.row)
    {
        SIProduct *product = [self.products objectAtIndex:indexPath.row];
        self.selectedProduct = product;
        [self performSegueWithIdentifier:SIProductDescriptionSegueIdentifier sender:self];
    }
    else assert(NO);
    
    SIProductDescriptionCell* productCell = (SIProductDescriptionCell*)[tableView cellForRowAtIndexPath:indexPath];
    [productCell setSelected:NO];
}

@end
