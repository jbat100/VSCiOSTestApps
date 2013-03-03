//
//  HomeViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIHomeViewController.h"

@interface SIHomeViewController ()

@end

@implementation SIHomeViewController

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
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    
    [self setCreditCardButton:nil];
    [self setMapButton:nil];
    [self setOrderButton:nil];
    [self setDisconnectButton:nil];

    [super viewDidUnload];
}

- (IBAction)showCreditCards:(id)sender
{
    [self performSegueWithIdentifier:@"CreditCards" sender:self];
}

- (IBAction)showMap:(id)sender
{
    [self performSegueWithIdentifier:@"Map" sender:self];
}

- (IBAction)showOrder:(id)sender
{
    [self performSegueWithIdentifier:@"Categories" sender:self];
}

- (IBAction)disconnect:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
@end
