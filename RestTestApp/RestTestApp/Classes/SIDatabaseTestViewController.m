//
//  SIDatabaseTestViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/24/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIDatabaseTestViewController.h"

#import "SIDataManager.h"

@interface SIDatabaseTestViewController ()

@end

@implementation SIDatabaseTestViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateShops:(id)sender
{
    NSError* error = nil;
    BOOL success = [[SIDataManager sharedManager] updateShopsError:&error];
    NSLog(@"Updated shops %@", (success ? @"successfully" : @"unsuccessfully"));
}

- (IBAction)updateCategories:(id)sender
{
    NSError* error = nil;
    BOOL success = [[SIDataManager sharedManager] updateCategoriesError:&error];
    NSLog(@"Updated categories %@", (success ? @"successfully" : @"unsuccessfully"));
}

- (IBAction)updateProducts:(id)sender
{
    NSError* error = nil;
    BOOL success = [[SIDataManager sharedManager] updateProductsError:&error];
    NSLog(@"Updated products %@", (success ? @"successfully" : @"unsuccessfully"));
}

- (IBAction)fetchShops:(id)sender
{
    NSArray* shops = [[SIDataManager sharedManager] fetchAllShops];
    NSLog(@"FetchShops: %@", shops);
}

- (IBAction)fetchCategories:(id)sender
{
    NSArray* categories = [[SIDataManager sharedManager] fetchAllCategories];
    NSLog(@"FetchCategories: %@", categories);
}

- (IBAction)fetchProducts:(id)sender
{
    NSArray* products = [[SIDataManager sharedManager] fetchAllProducts];
    NSLog(@"FetchProducts: %@", products);
}

- (void)viewDidUnload
{
    [self setFetchShops:nil];
    [self setFetchCategories:nil];
    [super viewDidUnload];
}

@end
