//
//  LoginViewController.m
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "LoginViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "FacebookLoginModel.h"


@interface LoginViewController () <FacebookLoginDelegate>
@property FacebookLoginModel *facebookLoginOperations;

@end

@implementation LoginViewController



-(void)viewDidLoad
{
    [super viewDidLoad];
    self.facebookLoginOperations = [[FacebookLoginModel alloc]init];
    
    self.facebookLoginOperations.delegate = self;
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        [self performSegueWithIdentifier:@"loginSuccessful" sender:self];
    }

}

- (IBAction)onLoginWithFacebookButtonPressed:(UIButton *)sender
{
    
    [self.facebookLoginOperations loginWithFacebook];
    
}


#pragma mark - Facebook Login Delegate Methods
- (void) hasLoggedInSuccessFully:(FacebookLoginModel *)sender
{
    NSLog(@"Delegate Method called");
    [self performSegueWithIdentifier:@"loginSuccessful" sender:self];
}





@end
