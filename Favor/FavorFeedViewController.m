//
//  ViewController.m
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "FavorFeedViewController.h"
#import <Parse.h>
#import "User.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FavorFeedViewController ()

@end

@implementation FavorFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    User *someUser = [User object];
//    
//    someUser.phoneNumber = @"867-5309";
//    
//    [someUser setObject:someUser.phoneNumber forKey:@"phoneNumber"];
//    
//    someUser.username = @"testUser3";
//    someUser.password = @"passWord3";
//    someUser.email = @"testuser3@gmail.com";
//    
//    [someUser signUpInBackground];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Already logged in with facebook");
    }
    
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
