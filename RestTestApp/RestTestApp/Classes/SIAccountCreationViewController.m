//
//  AccountCreationViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIAccountCreationViewController.h"
#import "SIHomeViewController.h"

#import "SIHTTPClient.h"
#import "SIDataManager.h"
#import "SIUser.h"

#import "DDLog.h"
#import "SVProgressHUD.h"

NSString* const SIAccountCreationSegueIdentifier = @"AccountCreation";

const NSInteger SIAccountCreationSucceededAlertViewTag  = 1001;
const NSInteger SIAccountCreationFailedAlertViewTag     = 1002;

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
    
    [self.lastNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.firstNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
#ifdef DEBUG
//#error "Test Error"
    self.lastNameTextField.text = @"Thorpe";
    self.firstNameTextField.text = @"Jonathan";
    self.emailTextField.text = @"jth@jth.com";
#endif
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCreationEnded:)
                                                 name:SIHTTPClientEndedUserCreation
                                               object:nil];
    
    self.createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Créer un Compte"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(createAccount:)];
    
    self.createButtonItem.enabled = [self isAccountCreationPossible];
    
    self.navigationItem.rightBarButtonItem = self.createButtonItem;
    
    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Annuler"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(createAccount:)];
    
    //self.navigationItem.leftBarButtonItem = self.cancelButtonItem;
    
    [self.lastNameTextField becomeFirstResponder];
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    SIUser* user = [[SIUser alloc] init];
    user.lastName = self.lastNameTextField.text;
    user.firstName = self.firstNameTextField.text;
    user.email = self.emailTextField.text;
    
    NSError* error = nil;
    
    BOOL success = [[SIHTTPClient sharedClient] createNewUser:user error:&error];
    if (success)
    {
        // show progress and wait for notification
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }
    else
    {
        // show alert view with error message
    }
}

#pragma mark - Notification Callbacks

-(void) userCreationEnded:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    [SVProgressHUD dismiss];
    
    NSString* outcome = [userInfo objectForKey:SIHTTPClientOutcomeKey];
    assert(outcome);
    
    if (outcome)
    {
        if ([outcome isEqualToString:SIHTTPClientSuccess])
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Création Réussie"
                                                                message:@"Votre compte a été créé"
                                                               delegate:self cancelButtonTitle:@"Continuer"
                                                      otherButtonTitles:nil];
            
            alertView.tag = SIAccountCreationSucceededAlertViewTag;
            [alertView show];
        }
        else if ([outcome isEqualToString:SIHTTPClientFailure])
        {
            /*
             TODO: Give error message giving info on what went wrong
             */
            
            NSError* error = [userInfo objectForKey:SIHTTPClientErrorKey];
            
            NSString* message = @"Votre compte n'a pas été créé";
            
            if ([[error domain] isEqualToString:SIHTTPClientErrorDomain])
            {
                if ([error code] == SIHTTPClientUserAlreadyExistsErrorCode)
                {
                    message = @"Ce compte existe déja";
                }
            }
            else assert(NO);
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"La Création a échouée"
                                                                message:message
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            
            alertView.tag = SIAccountCreationFailedAlertViewTag;
            [alertView show];
        }
    }

    DDLogError(@"");
}

#pragma mark - UIAlertViewDelegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SIAccountCreationSucceededAlertViewTag)
    {
        [self performSegueWithIdentifier:SIHomeSegueIdentifier sender:self];
    }
    else if (alertView.tag == SIAccountCreationFailedAlertViewTag)
    {
        [self.firstNameTextField becomeFirstResponder];
    }
    else
    {
        assert(NO);
    }
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
