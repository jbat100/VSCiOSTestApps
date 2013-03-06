//
//  ProductListingViewController.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIProductListingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray* products;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end
