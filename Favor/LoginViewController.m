//
//  LoginViewController.m
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "LoginViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>



@interface LoginViewController ()


@end

@implementation LoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
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
    //sets the permissions for what we want
    NSArray* permissions =  [NSArray arrayWithObjects:
                             @"email", @"public_profile",@"user_friends", nil];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user)
        {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        }
        
        //if it's a new user
        else if (user.isNew)
        {
            NSLog(@"User signed up and logged in through Facebook!");
            
                //code for getting the profile picture and current user and saving it
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error)
                     {
                         //returns an array of results in a dictionary
                         NSDictionary *results = result;
                         //get an IDNumber for the profile from the result dictionary
                         NSString *idNumber = [result objectForKey:@"id"];
                         //set a string with the path to the image
                         NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", idNumber];
                         //sets the image from the path
                         UIImage *userImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
                         //convert the image into data
                         NSData *profilePictureData = UIImagePNGRepresentation(userImage);
                         //make a file from the data
                         PFFile *imageFile = [PFFile fileWithData:profilePictureData];
                         //set the profile picture Column in parse to the data
                         user[@"ProfilePicture"] = imageFile;
                         //save that bad boy
                         [user saveInBackground];
                         //login succesfully
                        [self performSegueWithIdentifier:@"loginSuccessful" sender:self];
                     }
                     
                 }];
        }
        
        else
        {
            NSLog(@"User logged in through Facebook!");
           [self performSegueWithIdentifier:@"loginSuccessful" sender:self];
          
        }
    }];

}








@end
