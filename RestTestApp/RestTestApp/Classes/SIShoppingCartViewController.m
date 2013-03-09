//
//  ShoppingCartViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIShoppingCartViewController.h"
#import "SIDataManager.h"
#import "SIProductCartCell.h"
#import "SIProduct.h"
#import "SIOrder.h"

#import "DDLog.h"

NSString* const SIShoppingCartButtonTitle = @"Panier";
NSString* const SIShoppingCartSegueIdentifier = @"ShoppingCart";

@interface SIShoppingCartViewController ()

@property (nonatomic, strong) IBOutlet UIView* lowerView;

@property (nonatomic, strong) NSNumberFormatter* priceNumberFormatter;
@property (nonatomic, strong) NSArray* products;

-(void) customInit;

@end

@implementation SIShoppingCartViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderChanged:)
                                                 name:SIOrderChangedNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SIOrder* order = [SIDataManager sharedManager].currentOrder;
    
    self.products = [[SIDataManager sharedManager] productsWithPositivePurchaseCountForOrder:order];
    
    DDLogVerbose(@"Products is %@", self.products);
    
    [self.tableView reloadData];
    [self updateTotals];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Helpers

-(void) updateTotals
{
    SIOrder* order = [SIDataManager sharedManager].currentOrder;
    
    NSDecimalNumber* totalPrice = [NSDecimalNumber zero];
    NSInteger totalPurchaseCount = 0;
    
    if (order)
    {
        totalPrice = [[SIDataManager sharedManager] totalPriceForOrder:order];
        totalPurchaseCount = [order totalPurchaseCount];
    }
    
    self.totalPriceLabel.text = [self.priceNumberFormatter stringFromNumber:totalPrice];
    self.totalPurchaseCountLabel.text = [NSString stringWithFormat:@"%d", totalPurchaseCount];
}

-(void) setPurchaseCount:(NSInteger)purchaseCount forCell:(SIProductCartCell*)cell
{
    if ([cell isKindOfClass:[SIProductCartCell class]] == NO)
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

#pragma mark - Notification Callbacks

-(void) orderChanged:(NSNotification*)notification
{
    if ([notification object] == [SIDataManager sharedManager].currentOrder)
    {
        [self updateTotals];
    }
    else
    {
        DDLogError(@"%@ received notification from unexpected object %@", self, [notification object]);
        assert(NO);
    }
}

#pragma mark - UICallbacks

-(IBAction)increasePurchaseCount:(id)sender
{
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointMake(0, 0) toView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:buttonPosition];
    SIProductCartCell* cell = (SIProductCartCell*)[self.tableView cellForRowAtIndexPath:path];
    
    if (path)
    {
        if ([self.products count] > path.row)
        {
            SIProduct* product = [self.products objectAtIndex:path.row];
            [[SIDataManager sharedManager].currentOrder increasePurchaseCountForProduct:product error:nil];
            NSInteger count = [[SIDataManager sharedManager].currentOrder purchaseCountForProduct:product];
            [self setPurchaseCount:count forCell:cell];
        } else assert(NO);
    } else assert(NO);
    
}

-(IBAction)decreasePurchaseCount:(id)sender
{
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointMake(0, 0) toView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:buttonPosition];
    SIProductCartCell* cell = (SIProductCartCell*)[self.tableView cellForRowAtIndexPath:path];
    
    if (path)
    {
        if ([self.products count] > path.row)
        {
            SIProduct* product = [self.products objectAtIndex:path.row];
            [[SIDataManager sharedManager].currentOrder decreasePurchaseCountForProduct:product error:nil];
            NSInteger count = [[SIDataManager sharedManager].currentOrder purchaseCountForProduct:product];
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
    SIProductCartCell* cell = (SIProductCartCell*)[tableView dequeueReusableCellWithIdentifier:SIProductCellIdentifier];
    assert(cell); // we should always get a cell (using storyboard)
    
    if ([self.products count] > indexPath.row)
    {
        SIProduct *product = [self.products objectAtIndex:indexPath.row];
        
        if ([product isKindOfClass:[SIProduct class]])
        {
            cell.productNameLabel.text = [product name];
            NSInteger count = [[SIDataManager sharedManager].currentOrder purchaseCountForProduct:product];
            [self setPurchaseCount:count forCell:cell];
        }
        else
        {
            DDLogError(@"Unexpected product %@", product);
            assert(NO);
        }
    }
    else assert(NO);
    
    return cell;
}

@end
