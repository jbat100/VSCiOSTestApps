//
//  SINoAnimationSegue.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/16/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SINoAnimationPushSegue.h"

@implementation SINoAnimationPushSegue

- (void) perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    assert(src.navigationController);
    [src.navigationController pushViewController:dst animated:NO];
}

@end
