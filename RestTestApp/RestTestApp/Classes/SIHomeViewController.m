//
//  HomeViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIHomeViewController.h"

#import "SIThemeManager.h"

NSString* const SIHomeSegueIdentifier = @"Home";

@interface SIHomeViewController ()

@end

@implementation SIHomeViewController

+(void) load
{
    //[[UIButton appearanceWhenContainedIn:[self class], nil] setTintColor:[UIColor lightGrayColor]];
}

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
    
    NSMutableArray* buttons = [NSMutableArray array];
    if (self.creditCardButton) [buttons addObject:self.creditCardButton];
    if (self.mapButton) [buttons addObject:self.mapButton];
    if (self.orderButton) [buttons addObject:self.orderButton];
    if (self.disconnectButton) [buttons addObject:self.disconnectButton];
    if (self.testDatabaseButton) [buttons addObject:self.testDatabaseButton];
    
    for (UIButton* button in buttons)
    {
        if ([button isKindOfClass:[UIButton class]])
        {
            button.titleLabel.textColor = [SIThemeManager sharedManager].defaultButtonLabelTextColor;
            button.titleLabel.font = [SIThemeManager sharedManager].defaultButtonLabelFont;
            [button setTintColor:[UIColor lightGrayColor]];
            
            //button.backgroundColor = [UIColor lightGrayColor];
        }
    }
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

- (IBAction)testDatabase:(id)sender
{
    [self performSegueWithIdentifier:@"DatabaseTest" sender:self];
}

@end
