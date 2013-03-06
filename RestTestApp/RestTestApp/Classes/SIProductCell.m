//
//  ProductListingCell.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/5/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIProductCell.h"

@implementation SIProductCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
