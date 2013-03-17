//
//  ProductTypeView.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 2/2/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SICategoryCell.h"

@interface SICategoryCell ()

@property (nonatomic, strong) UIColor* selectedColor;
@property (nonatomic, strong) UIColor* unselectedColor;

@end

@implementation SICategoryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.unselectedColor = [UIColor lightGrayColor];
        self.selectedColor = [UIColor darkGrayColor];
        
        self.backgroundColor = [UIColor blueColor];
        
        self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.mainLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.mainLabel.textAlignment = UITextAlignmentCenter;
        self.mainLabel.font = [UIFont boldSystemFontOfSize:14.0];
        //self.mainLabel.backgroundColor = [UIColor underPageBackgroundColor];
        self.mainLabel.backgroundColor = self.unselectedColor;
        self.mainLabel.textColor = [UIColor blackColor];
        self.mainLabel.numberOfLines = 0;
        self.mainLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.mainLabel.opaque = NO;
        
        [self.contentView addSubview:self.mainLabel];;
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.opaque = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        CGFloat cornerRadius = 10.0;
        
        self.layer.cornerRadius = cornerRadius;
        self.contentView.layer.cornerRadius = cornerRadius;
        self.mainLabel.layer.cornerRadius = cornerRadius;
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        self.mainLabel.backgroundColor = self.selectedColor;
    }
    else
    {
        self.mainLabel.backgroundColor = self.unselectedColor;
    }
}

-(void) setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
    {
        self.mainLabel.backgroundColor = self.selectedColor;
    }
    else
    {
        self.mainLabel.backgroundColor = self.unselectedColor;
    }
}

@end
