//
//  SIRootViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 3/16/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIRootViewController.h"

#import "SIHTTPClient.h"
#import "SIAccountCreationViewController.h"
#import "SIHomeViewController.h"

@interface SIRootViewController ()

@end

@implementation SIRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([SIHTTPClient sharedClient].currentUser)
    {
        [self performSegueWithIdentifier:SIHomeSegueIdentifier sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:SIAccountCreationSegueIdentifier sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
