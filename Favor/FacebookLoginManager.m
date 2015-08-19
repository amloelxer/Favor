//
//  FacebookLoginModel.m
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "FacebookLoginManager.h"

@implementation FacebookLoginManager


-(void)loginWithFacebook
{
    NSArray* permissions =  [NSArray arrayWithObjects:
                             @"email", @"public_profile",@"user_friends", nil];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user)
        {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [self.delegate logInFailedWithError:self];

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
                     NSString *name = [result objectForKey:@"name"];
                     NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", idNumber];
                     //sets the image from the path
                     UIImage *userImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
                     //convert the image into data
                     NSData *profilePictureData = UIImagePNGRepresentation(userImage);
 
                     PFFile *imageFile = [PFFile fileWithName:@"placeholder.png" data:profilePictureData];

                     //set the profile picture Column in parse to the data
                     user[@"ProfilePicture"] = imageFile;
                     user[@"name"] = name;
                     //save that bad boy
                   [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     // user will automatically save its files & only call this once the
                     // entire operation succeeds.
                     if(!error)
                     {
                       NSLog(@"The save went sucessfully");
                     }
                     else
                     {
                       NSLog(@"The error message is %@", error);
                     }
                     
                   }];
                     //login succesfully
//                    [self performSegueWithIdentifier:@"loginSuccessful" sender:self];
                     [self.delegate hasLoggedInSuccessFully:self];
                 }
                 
             }];
        }
        
        else
        {
            NSLog(@"User logged in through Facebook!");
        }
      
    }];
}

- (void)checkIfLoggedIn:(User *)passedUser
{
  //call delegate method accordingly if User has signed up
  if([PFFacebookUtils isLinkedWithUser:passedUser])
  {
    [self.delegate hasLoggedInSuccessFully:self];
  }
  
  else
  {
    [self.delegate logInFailedWithError:self];
  }
  
}
@end
