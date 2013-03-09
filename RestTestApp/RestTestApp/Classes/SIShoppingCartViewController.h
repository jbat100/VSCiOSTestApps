//
//  ShoppingCartViewController.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const SIShoppingCartButtonTitle;
extern NSString* const SIShoppingCartSegueIdentifier;

@interface SIShoppingCartViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) IBOutlet UILabel* totalPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel* totalPurchaseCountLabel;

@end
