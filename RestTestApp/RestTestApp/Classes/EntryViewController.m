//
//  ViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "EntryViewController.h"

#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "StreatitHTTPClient.h"

@interface EntryViewController ()



@end

@implementation EntryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setLoginTextField:nil];
    [self setPasswordTextField:nil];
    [self setCreateAccountButton:nil];
    
    [super viewDidUnload];
}

-(IBAction)createAccountButtonTouched:(id)sender
{
    /*
     *  Testing with the twitter API for now 
     */
    
    NSDictionary* parameters = @{@"q" : @"Potato"};
    
    NSMutableURLRequest *request = [[StreatitHTTPClient sharedClient] requestWithMethod:@"GET"
                                                                                   path:@"search/tweets.json"
                                                                             parameters:parameters];
    
    AFJSONRequestOperation *operation = nil;
    
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    NSLog(@"Operation succeeded: %@", JSON);
                    [SVProgressHUD showSuccessWithStatus:@"Connection établie"];
                }
                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    NSLog(@"Operation failed: %@ (error: %@)", JSON, error);
                    [SVProgressHUD showErrorWithStatus:@"La connection a échouée"];
                }];
    
    [operation start];

}

@end
