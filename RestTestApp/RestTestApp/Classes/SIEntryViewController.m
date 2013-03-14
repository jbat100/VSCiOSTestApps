//
//  ViewController.m
//  RestTestApp
//
//  Created by Jonathan Thorpe on 1/31/13.
//  Copyright (c) 2013 Jonathan Thorpe. All rights reserved.
//

#import "SIEntryViewController.h"
#import "SIHTTPClient.h"

#import "DDLog.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface SIEntryViewController ()

@property (nonatomic, assign) CGFloat restLoginTopConstraintConstant;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint* loginTopContraint;

@property (nonatomic, strong) UIBarButtonItem* loginBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* cancelBarButtonItem;

-(void) performLogin:(id)sender;

-(BOOL) isLoginPossible;

@end

@implementation SIEntryViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    assert(self.loginTextField);
    assert(self.passwordTextField);
    assert(self.createAccountButton);
    
    
    //assert(self.loginTopContraint); // cannot use autolayout with iOS 5 which must be supported
    
    self.restLoginTopConstraintConstant = self.loginTopContraint.constant;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterEditMode:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exitEditMode:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.loginTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.loginTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.navigationItem.title = @"Login";
    //self.navigationController.navigationBar.hidden = YES;
    //self.loginTextField.text = @"";
    
    self.passwordTextField.text = @"";
    
    self.loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Connexion"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(performLogin:)];
    
    self.navigationItem.rightBarButtonItem = self.loginBarButtonItem;
    
    self.loginBarButtonItem.enabled = [self isLoginPossible];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Annuler"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(cancelLogin:)];
    
    //self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    
    
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DDLogVerbose(@"%@ viewDidAppear loginTextField.frame %@, passwordTextField.frame %@",
                 self, NSStringFromCGRect(self.loginTextField.frame), NSStringFromCGRect(self.passwordTextField.frame));
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.passwordTextField = nil;
    self.loginBarButtonItem = nil;
    self.createAccountButton = nil;
    self.databaseTestButton = nil;
}

#pragma mark - Storyboarding

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Home"])
    {
        DDLogVerbose(@"%@ perparing for home segue %@", self, segue);
    }
}

#pragma mark - Helpers

-(BOOL) isLoginPossible
{
    assert([self.loginTextField isKindOfClass:[UITextField class]]);
    assert([self.passwordTextField isKindOfClass:[UITextField class]]);
    
    NSString* loginString = [self.loginTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* passwordString = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([loginString length] > 0 && [passwordString length] > 0)
    {
        DDLogVerbose(@"Tested login: Good to go");
        return YES;
    }
    
    DDLogVerbose(@"Tested login: No go");
    
    return NO;
}

#pragma mark - UI Actions

-(IBAction)databaseTest:(id)sender
{
    [self performSegueWithIdentifier:@"DatabaseTest" sender:self];
}

-(void) loginButtonTouched:(id)sender
{
    if([self.loginTextField isEditing]) [self.loginTextField endEditing:YES];
    if([self.passwordTextField isEditing]) [self.passwordTextField endEditing:YES];
}

-(IBAction)createAccount:(id)sender
{
    
}

-(void) performLogin:(id)sender
{
    if([self.loginTextField isEditing]) [self.loginTextField endEditing:YES];
    if([self.passwordTextField isEditing]) [self.passwordTextField endEditing:YES];
    
    /*
     *  Testing with the twitter API for now 
     */
    
    NSDictionary* parameters = @{@"q" : @"Potato"};
    
    NSMutableURLRequest *request = [[SIHTTPClient sharedClient] requestWithMethod:@"GET"
                                                                                   path:@"search/tweets.json"
                                                                             parameters:parameters];
    
    DDLogVerbose(@"%@ request %@", self, request);
    
    AFJSONRequestOperation *operation = nil;
    
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    DDLogVerbose(@"Operation succeeded: %@", JSON);
                    [SVProgressHUD showSuccessWithStatus:@"Connection établie"];
                }
                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    DDLogError(@"Operation failed: %@ (error: %@)", JSON, error);
                    [SVProgressHUD showErrorWithStatus:@"La connection a échouée"];
                    [self performSegueWithIdentifier:@"Home" sender:self];
                }];
    
    [SVProgressHUD showWithStatus:@"Connexion en cours" maskType:SVProgressHUDMaskTypeGradient];
    
    [operation start];

}

-(void) cancelLogin:(id)sender
{
    if([self.loginTextField isEditing]) [self.loginTextField endEditing:YES];
    if([self.passwordTextField isEditing]) [self.passwordTextField endEditing:YES];
    
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidChange:(id)sender
{
    if (sender == self.loginTextField || sender == self.passwordTextField)
    {
        self.loginBarButtonItem.enabled = [self isLoginPossible];
    }
}

#pragma mark - Keyboard Notifications

-(void) enterEditMode:(NSNotification*)notification
{
    DDLogVerbose(@"%@ enterEditMode: %@", self, notification);
    
    NSValue* keyboardFrameEnd = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber* durationNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    assert(keyboardFrameEnd);
    assert(durationNumber);
    
    if (keyboardFrameEnd)
    {
        CGRect endFrame = [keyboardFrameEnd CGRectValue];
        CGRect viewFrame = self.view.frame;
        double duration = [durationNumber doubleValue];
        CGRect passwordFieldFrame = self.passwordTextField.frame;
        CGFloat passFieldBottom = passwordFieldFrame.origin.y + passwordFieldFrame.size.height;
        CGFloat keyboardTop = viewFrame.size.height - endFrame.size.height;
        int offset = (int)(keyboardTop - passFieldBottom) - 10;
        
        DDLogVerbose(@"keyboardTop %.2f, passFieldBottom %.2f, offset %d, duration %.2f",
                     keyboardTop, passFieldBottom, offset, duration);
        
        {
            /*
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.loginTopContraint.constant = self.restLoginTopConstraintConstant + offset;
                                 [self.view layoutIfNeeded];
                             }];
             */
        }
        
    }
    
    //[[self navigationItem] setRightBarButtonItem:self.loginBarButtonItem animated:YES];
    
    [[self navigationItem] setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
}

-(void) exitEditMode:(NSNotification*)notification
{
    DDLogVerbose(@"%@ exitEditMode: %@", self, notification);
    
    NSNumber* durationNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    assert(durationNumber);
    
    if (durationNumber)
    {
        /*
        [UIView animateWithDuration:[durationNumber doubleValue]
                         animations:^{
                             self.loginTopContraint.constant = self.restLoginTopConstraintConstant;
                             [self.view layoutIfNeeded];
                         }];
         */
    }
    
    else
    {
        /*
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.loginTopContraint.constant = 0;
                             [self.view layoutIfNeeded];
                         }];
         */
    }
    
    [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
    
}

@end
