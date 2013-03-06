//
//  ProductListingViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIProductListingViewController.h"

#import "SIProduct.h"
#import "SIProductCell.h"

#import "SIDataManager.h"

@interface SIProductListingViewController ()

-(void) customInit;

-(IBAction)increasePurchaseCount:(id)sender;
-(IBAction)decreasePurchaseCount:(id)sender;

-(void) setPurchaseCount:(NSInteger)purchaseCount forCell:(SIProductCell*)cell;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Helpers

-(void) setPurchaseCount:(NSInteger)purchaseCount forCell:(SIProductCell*)cell
{
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

-(IBAction)increasePurchaseCount:(id)sender
{
    if ([sender isKindOfClass:[SIProductCell class]])
    {
        SIProductCell* cell = (SIProductCell*)sender;
        NSIndexPath* path = [self.tableView indexPathForCell:cell];
        if ([self.products count] > path.row)
        {
            SIProduct* product = [self.products objectAtIndex:path.row];
            [[SIDataManager sharedManager] increasePurchaseCountForProduct:product error:nil];
            NSInteger count = [[SIDataManager sharedManager] purchaseCountForProduct:product error:nil];
            [self setPurchaseCount:count forCell:cell];
        }
        else assert(NO);
    }
}

-(IBAction)decreasePurchaseCount:(id)sender
{
    if ([sender isKindOfClass:[SIProductCell class]])
    {
        SIProductCell* cell = (SIProductCell*)sender;
        NSIndexPath* path = [self.tableView indexPathForCell:cell];
        if ([self.products count] > path.row)
        {
            SIProduct* product = [self.products objectAtIndex:path.row];
            // SIDataManager handles error cases (zero count for example) no need to check
            [[SIDataManager sharedManager] decreasePurchaseCountForProduct:product error:nil];
            NSInteger count = [[SIDataManager sharedManager] purchaseCountForProduct:product error:nil];
            [self setPurchaseCount:count forCell:cell];
        }
        else assert(NO);
    }
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
    SIProductCell* cell = (SIProductCell*)[tableView dequeueReusableCellWithIdentifier:SIProductCellIdentifier];
    assert(cell); // we should always get a cell (using storyboard)
    
    if ([self.products count] > indexPath.row)
    {
        SIProduct *product = [self.products objectAtIndex:indexPath.section];
        cell.productNameLabel.text = [product name];
        NSString* priceString = [NSNumberFormatter localizedStringFromNumber:[product price] numberStyle:NSNumberFormatterCurrencyStyle];
        cell.productPriceLabel.text = priceString;
        cell.productDescriptionLabel.text = [product productDescription];
        NSInteger count = [[SIDataManager sharedManager] purchaseCountForProduct:product error:nil];
        [self setPurchaseCount:count forCell:cell];
    }
    else assert(NO);
    
    return cell;
}

@end
