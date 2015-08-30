//
//  LoginViewController.m
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "LoginViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "FacebookLoginManager.h"
#import "ColorPalette.h"


@interface LoginViewController () <FacebookLoginDelegate>
@property FacebookLoginManager *facebookLoginOperations;
@property User *currentUser;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;


@end

@implementation LoginViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
  
    self.facebookLoginOperations = [[FacebookLoginManager alloc]init];
  
    self.facebookLoginOperations.delegate = self;
  
    self.currentUser = [User currentUser];
  
    self.view.backgroundColor = [ColorPalette getFavorPinkRedColor];
  
  self.facebookLoginButton.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:16];

  
  
}

-(void)viewDidAppear:(BOOL)animated
{
  
  NSLog(@"Check Login Did Pop UP");
  [self.facebookLoginOperations checkIfLoggedIn:self.currentUser];
  
}

- (IBAction)onLoginWithFacebookButtonPressed:(UIButton *)sender
{
    //call the login with facbeook operation
    [self.facebookLoginOperations loginWithFacebook];
}


#pragma mark - Facebook Login Delegate Methods
- (void) hasLoggedInSuccessFully:(FacebookLoginManager *)sender
{
    NSLog(@"Logged in sucessfully. Aka this delegate method should be called");
    [self performSegueWithIdentifier:@"loginSuccessful" sender:self];
}

- (void) hasLoggedInSucessFullyAndIsNewUser: (FacebookLoginManager *) sender
{
  [self performSegueWithIdentifier:@"isNewUserSegue" sender:self];
  
}

-(void) logInFailedWithError:(FacebookLoginManager *)sender
{
  UIAlertView *alertView = [[UIAlertView alloc]
                            initWithTitle:@"Error"
                            message:@"There was an error or you have not logged in with Facebook. Please try again"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            otherButtonTitles:@"OK", nil];
  [alertView show];
  
}





@end
