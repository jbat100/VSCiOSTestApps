//
//  AppDelegate.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIAppDelegate.h"

#import "SIHTTPClient.h"
#import "SIDataManager.h"
#import "SIAccountCreationViewController.h"
#import "SIUser.h"

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

@interface SIAppDelegate ()

/*
 Path to the current user archive
 */

-(NSString*) userPath;

@end

@implementation SIAppDelegate

+(SIAppDelegate*) delegate
{
    return (SIAppDelegate*)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Application Callbacks

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    NSString* userPath = [self userPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:userPath])
    {
        [SIHTTPClient sharedClient].currentUser = [NSKeyedUnarchiver unarchiveObjectWithFile:userPath];
        if ([SIHTTPClient sharedClient].currentUser)
        {
            DDLogVerbose(@"Unarchived user (file path is: %@)", userPath);
        }
        else
        {
            DDLogError(@"Failed to unarchive user (file path is: %@)", userPath);
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCreationEnded:)
                                                 name:SIHTTPClientEndedUserCreation
                                               object:nil];
    
#ifdef DEBUG
    // wait a bit for debug purposes
    [[SIDataManager sharedManager] performSelector:@selector(performFullDatabasUpdate) withObject:nil afterDelay:2.0];
#else
    [[SIDataManager sharedManager] performFullDatabasUpdate];
#endif
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - User

-(NSString*) userPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return [path stringByAppendingPathComponent:@"User.archive"];
}

-(void) resetUser
{
    [[NSFileManager defaultManager] removeItemAtPath:[self userPath] error:nil];
    
    [SIHTTPClient sharedClient].currentUser = nil;
}

#pragma mark - Notficiation Callbacks

-(void) userCreationEnded:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    if (userInfo)
    {
        NSString* outcome = [userInfo objectForKey:SIHTTPClientOutcomeKey];
        if (outcome)
        {
            if ([outcome isEqualToString:SIHTTPClientSuccess])
            {
                SIUser* user = [userInfo objectForKey:SIHTTPClientUserKey];
                if (user)
                {
                    [NSKeyedArchiver archiveRootObject:user toFile:[self userPath]];
                }
                else assert(NO);
            }
            else if ([outcome isEqualToString:SIHTTPClientFailure])
            {
                // errors are handled by the SIAccountCreationViewController
            }
        }
        else assert(NO);
        
    }
    else assert(NO);
}

@end
