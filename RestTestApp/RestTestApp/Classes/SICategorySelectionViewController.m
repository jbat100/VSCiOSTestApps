//
//  ProductTypeSelectionViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SICategorySelectionViewController.h"
#import "SIProductListingViewController.h"
#import "SIShoppingCartViewController.h"
#import "PSTCollectionView.h"

#import "SIOrder.h"
#import "SICategory.h"
#import "SIProduct.h"
#import "SICategoryCell.h"
#import "SIDataManager.h"

NSString* const SICategoryCellIdentifier = @"SICategoryCellIdentifier";
NSString* const SIProductSegueIdentifier = @"Products";

@interface SICategorySelectionViewController ()

@property (nonatomic, strong) NSArray* categories;
@property (nonatomic, strong) PSUICollectionViewFlowLayout* collectionViewLayout;
@property (nonatomic, strong) UILabel* noCategoriesLabel;
@property (nonatomic, strong) SICategory* selectedCategory;

@property (nonatomic, strong) UIBarButtonItem* shoppingCartButtonItem;

-(void) customInit;


@end

@implementation SICategorySelectionViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderChanged:) name:SIOrderChangedNotification object:nil];
    
    self.shoppingCartButtonItem = [[UIBarButtonItem alloc] initWithTitle:SIShoppingCartButtonTitle
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(showShoppingCart:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //UICollectionViewFlowLayout
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.collectionViewLayout = [[PSUICollectionViewFlowLayout alloc] init];
    
    self.collectionViewLayout.itemSize = CGSizeMake(120.0, 120.0);
    self.collectionViewLayout.minimumInteritemSpacing = 20.0;
    self.collectionViewLayout.minimumLineSpacing = 20.0;
    
    self.collectionView.clipsToBounds = YES;
    
    self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(20.0, 20.0, 30.0, 30.0);
    
    //UIEdgeInsets
    
    //self.collectionView = [[PSUICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewLayout];
    
    self.collectionView.collectionViewLayout = self.collectionViewLayout;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[SICategoryCell class] forCellWithReuseIdentifier:SICategoryCellIdentifier];
    
    [self.view addSubview:self.collectionView];
}

-(void) viewWillUnload
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    
    self.collectionView = nil;
    self.collectionViewLayout = nil;
    
    [super viewWillUnload];
}

-(void) dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    
    self.collectionView = nil;
    self.collectionViewLayout = nil;
    
    self.shoppingCartButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.categories = [[SIDataManager sharedManager] fetchAllCategories];
    
    [self.navigationItem setRightBarButtonItem:self.shoppingCartButtonItem animated:animated];
    
    [self.collectionView reloadData];

    // deselect everything...
    for (int i=0; i < self.categories.count; i++)
    {
        [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] animated:NO];
    }
    
    self.selectedCategory = nil;
    

    
    //self.navigationItem.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Callbacks

-(void) orderChanged:(NSNotification*)notification
{
    
}

#pragma mark - Shopping Cart Button

-(void) showShoppingCartButton
{
    //self.navigationItem.rightBarButtonItem = self.shoppingCartButtonItem;
}

-(void) hideShoppingCartButton
{
    
}

-(void) showShoppingCart:(id)sender
{
    [self performSegueWithIdentifier:SIShoppingCartSegueIdentifier sender:self];
}


#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SIProductSegueIdentifier])
    {
        SIProductListingViewController* destinationViewController = [segue destinationViewController];
        if ([destinationViewController isKindOfClass:[SIProductListingViewController class]])
        {
            if (self.selectedCategory)
            {
                NSArray* products = [[SIDataManager sharedManager] fetchAllProductsForCategory:self.selectedCategory];
                
                DDLogVerbose(@"%@ showing product listing for category: %@ (id %@) -->",
                             self, [self.selectedCategory name], [self.selectedCategory categoryID]);
                for (SIProduct* product in products)
                {
                    DDLogVerbose(@"%@ category: %@", [product name], [product categoryID]);
                }
                
                destinationViewController.products = products;
                
                return;
            }
            else assert(NO);
        }
        else assert(NO);
        
        DDLogError(@"%@ prepareForSegue:sender: ERROR unexpected state segue %@ selectedCategory %@",
                   self, segue, self.selectedCategory);
    }
    
    else if ([[segue identifier] isEqualToString:SIShoppingCartSegueIdentifier])
    {
        // the SIDataManager singleton has the SIOrder which describes the cart
    }
}

#pragma mark - PSUICollectionView Delegate/DataSource

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.categories count];
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SICategoryCell *cell = (SICategoryCell*)[cv dequeueReusableCellWithReuseIdentifier:SICategoryCellIdentifier forIndexPath:indexPath];
    if ([self.categories count] > indexPath.item)
    {
        SICategory* category = [self.categories objectAtIndex:indexPath.item];
        if ([category isKindOfClass:[SICategory class]])
        {
            cell.mainLabel.text = [category name];
            return cell;
        }
        else assert(NO);
    }
    else assert(NO);
    
    DDLogError(@"%@ collectionView:cellForItemAtIndexPath: ERROR unexpected state indexPath %@, categories: %@",
               self, indexPath, self.categories);
    
    return nil;
}

-(void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.categories count] > indexPath.item)
    {
        SICategory* category = [self.categories objectAtIndex:indexPath.item];
        if ([category isKindOfClass:[SICategory class]])
        {
            self.selectedCategory = [self.categories objectAtIndex:indexPath.item];
            [self performSegueWithIdentifier:SIProductSegueIdentifier sender:self];
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            return;
        }
        else assert(NO);
    }
    else assert(NO);
    
    DDLogError(@"%@ collectionView:didSelectItemAtIndexPath: ERROR unexpected state indexPath %@, categories: %@",
               self, indexPath, self.categories);
    
    //[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
