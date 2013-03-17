//
//  AppDelegate.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIAppDelegate : UIResponder <UIApplicationDelegate>

+(SIAppDelegate*) delegate;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController* navigationController;

-(void) resetUser;

@end
