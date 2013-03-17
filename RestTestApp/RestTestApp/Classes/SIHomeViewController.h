//
//  HomeViewController.h
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const SIHomeSegueIdentifier;

@interface SIHomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *creditCardButton;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) IBOutlet UIButton *orderButton;
@property (strong, nonatomic) IBOutlet UIButton *disconnectButton;
@property (strong, nonatomic) IBOutlet UIButton *testDatabaseButton;

- (IBAction)showCreditCards:(id)sender;
- (IBAction)showMap:(id)sender;
- (IBAction)showOrder:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)testDatabase:(id)sender;


@end
