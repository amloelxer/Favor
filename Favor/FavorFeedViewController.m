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
#import "Favor.h"

@interface FavorFeedViewController ()
@property User *currentUser;

@end

@implementation FavorFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.currentUser = [User currentUser];
  
  UIColor *favorRedColor = [UIColor colorWithRed:251.0f/255.0f
                                           green:67.0f/255.0f
                                            blue:48.0f/255.0f
                                           alpha:1.0f];
  
  [self.navigationController.navigationBar setBarTintColor:favorRedColor];
  
   [self.navigationController.navigationBar setTranslucent:NO];
  
  [[UINavigationBar appearance] setTitleTextAttributes:
  [NSDictionary dictionaryWithObjectsAndKeys:
   [UIColor whiteColor],
   NSForegroundColorAttributeName,
   [UIColor whiteColor],
   NSForegroundColorAttributeName,
   [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
   NSForegroundColorAttributeName,
   [UIFont fontWithName:@"Arial-Bold" size:0.0],
   NSFontAttributeName,
   nil]];
  
}

//- (IBAction)addPost:(UIButton *)sender
//{

  
  //getting all the post by specific user
  
//  PFQuery *postQueryForUser = [PFQuery queryWithClassName:@"Favor"];
//  [postQueryForUser whereKey:@"CreatedBy" equalTo:self.currentUser];
//  
//  [postQueryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//    if(!error)
//    {
//      for(PFObject *o in objects) {
//        // o is an entry in the Follow table
//        // to get the user, we get the object with the to key
//        NSString *tempString = [o objectForKey:@"text"];
//        
//        NSLog(@"The text for the post is %@", tempString);
//        
//        // to get the time when we followed this user, get the date key
//      }
//    }
//  }];
  
  
  
//}
- (IBAction)addFavorPressed:(UIBarButtonItem *)sender {
  
  Favor *firstFavor = [Favor objectWithClassName:@"Favor"];
  
  firstFavor[@"text"] = @"Test Post with stuff";
  
  //  firstFavor[@"askOrOffer"] = (BOOL)NO;
  
  PFRelation *relation = [firstFavor relationForKey:@"CreatedBy"];
  
  [relation addObject:self.currentUser];
  
  [firstFavor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if (!error) {
      NSLog(@"Save sucessfully");
      
    }
    
    else
    {
      NSLog(@"The error is: %@", error);
      
    }
    
  }];
  
  
}





@end
