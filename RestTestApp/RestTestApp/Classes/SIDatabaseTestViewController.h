//
//  SIDatabaseTestViewController.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/24/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIDatabaseTestViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *fetchCategories;
@property (strong, nonatomic) IBOutlet UIButton *fetchShops;

- (IBAction)updateShops:(id)sender;
- (IBAction)updateCategories:(id)sender;
- (IBAction)updateProducts:(id)sender;

- (IBAction)fetchShops:(id)sender;
- (IBAction)fetchCategories:(id)sender;
- (IBAction)fetchProducts:(id)sender;

@end
