//
//  AccountCreationViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIAccountCreationViewController.h"

@interface SIAccountCreationViewController ()

@property (nonatomic, strong) UIBarButtonItem* cancelButtonItem;
@property (nonatomic, strong) UIBarButtonItem* createButtonItem;

-(BOOL) isAccountCreationPossible;
-(void) createAccount:(id)sender;

-(void) enterEditMode:(NSNotification*)notification;
-(void) exitEditMode:(NSNotification*)notification;

@end

@implementation SIAccountCreationViewController

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
    
    assert([self.lastNameTextField isKindOfClass:[UITextField class]]);
    assert([self.firstNameTextField isKindOfClass:[UITextField class]]);
    assert([self.emailTextField isKindOfClass:[UITextField class]]);
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Créer"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(createAccount:)];
    
    self.createButtonItem.enabled = [self isAccountCreationPossible];
    
    self.navigationItem.rightBarButtonItem = self.createButtonItem;
    
    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Annuler"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(createAccount:)];
    
    self.navigationItem.leftBarButtonItem = self.cancelButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTitlteLabel:nil];
    [self setLastNameTextField:nil];
    [self setFirstNameTextField:nil];
    [self setEmailTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Helpers

-(BOOL) isAccountCreationPossible
{
    
    NSString* firstName = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* lastName = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* email = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([firstName length] > 0 && [lastName length] > 0 && [email length] > 0)
    {
        DDLogVerbose(@"Tested account creation fields: Good to go");
        return YES;
    }
    
    DDLogVerbose(@"Tested account creation fields: No go");
    
    return NO;
}

#pragma mark - UI Callbacks

-(void) cancel:(id)sender
{
    if([self.lastNameTextField isEditing]) [self.lastNameTextField endEditing:YES];
    if([self.firstNameTextField isEditing]) [self.firstNameTextField endEditing:YES];
    if([self.emailTextField isEditing]) [self.emailTextField endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) createAccount:(id)sender
{
    if([self.lastNameTextField isEditing]) [self.lastNameTextField endEditing:YES];
    if([self.firstNameTextField isEditing]) [self.firstNameTextField endEditing:YES];
    if([self.emailTextField isEditing]) [self.emailTextField endEditing:YES];
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidChange:(id)sender
{
    if (sender == self.lastNameTextField || sender == self.firstNameTextField || sender == self.emailTextField)
    {
        self.createButtonItem.enabled = [self isAccountCreationPossible];
    }
}

#pragma mark - Keyboard Notifications

-(void) enterEditMode:(NSNotification*)notification
{
    DDLogVerbose(@"%@ enterEditMode: %@", self, notification);
    
}

-(void) exitEditMode:(NSNotification*)notification
{
    DDLogVerbose(@"%@ exitEditMode: %@", self, notification);
    
}


@end
