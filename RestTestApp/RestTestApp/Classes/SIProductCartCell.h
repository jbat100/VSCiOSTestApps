//
//  SIProductCartCell.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/9/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIProductCartCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIButton *removeButton;
@property (strong, nonatomic) IBOutlet UILabel *purchaseCountLabel;

@end
