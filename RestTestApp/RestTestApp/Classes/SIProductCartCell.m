//
//  SIProductCartCell.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/9/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIProductCartCell.h"

@interface SIProductCartCell ()

-(void) customInit;

@end

@implementation SIProductCartCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)awakeFromNib
{
    self.productNameLabel.textColor = [UIColor whiteColor];
    self.purchaseCountLabel.textColor = [UIColor whiteColor];
    
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView.opaque = NO;
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
