//
//  ProductTypeView.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/2/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "PSTCollectionViewCell.h"

@interface SICategoryCell : PSUICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel* mainLabel;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;

@end
