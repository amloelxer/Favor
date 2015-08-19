//
//  ViewController.m
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "FavorFeedViewController.h"
#import "User.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Favor.h"
#import "DatabaseManager.h"
#import "FavorCell.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import <ParseUI.h>


@interface FavorFeedViewController () <UITableViewDataSource, UITableViewDelegate, DatabaseManagerDelegate>

@property User *currentUser;
@property (weak, nonatomic) IBOutlet UITableView *favorTableView;
@property NSArray *arrayOfFavors;
@property DatabaseManager *parseDataManager;

@property (weak, nonatomic) IBOutlet UISegmentedControl *favorSegmentedControl;

@end

@implementation FavorFeedViewController

 //constants for Favor Feed declared here
 NSInteger const asks = 0;
 NSInteger const offer = 1;
 NSString *const cellResuseIdentifier = @"CellID";

- (void)viewDidLoad
{
  
  [super viewDidLoad];
  
  self.currentUser = [User currentUser];
  
  self.arrayOfFavors = [NSArray new];
  
  self.parseDataManager = [[DatabaseManager alloc]init];
  
  self.parseDataManager.delegate = self;
  
  [self.parseDataManager getMyFavors:self.currentUser];
  
  UIColor *favorRedColor = [UIColor colorWithRed:251.0f/255.0f
                                           green:67.0f/255.0f
                                            blue:48.0f/255.0f
                                           alpha:1.0f];
  
  [self.navigationController.navigationBar setBarTintColor:favorRedColor];
  
  
}


#pragma mark - DatabaseManager Delegate Methods

-(void)reloadTableWithQueryResults:(NSArray *)queryResults
{
  
  NSLog(@"reloadTableWithQueryResults is being called");
  self.arrayOfFavors = queryResults;
  
  [self.favorTableView reloadData];
  
}


- (IBAction)addFavorPressed:(UIBarButtonItem *)sender {
  
  Favor *firstFavor = [Favor objectWithClassName:@"Favor"];
  
  firstFavor[@"text"] = @"Test Post with stuff";
  
  [firstFavor setObject:@"Test Post with text and stuff. Doesn't it look pretty?" forKey:@"text"];
  
  [firstFavor setObject:@(YES) forKey:@"askOrOffer"];
  
  PFRelation *relation = [firstFavor relationForKey:@"CreatedBy"];
  
  [relation addObject:self.currentUser];
  
  [firstFavor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if (!error)
    {
      NSLog(@"Save sucessfully");
      [self.favorTableView reloadData];
      
    }
    
    else
    {
      NSLog(@"The error is: %@", error);
    }
    
  }];
  
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.arrayOfFavors.count;
}


- (void)callMethodForSegment
{
  if(self.favorSegmentedControl.selectedSegmentIndex == asks)
  {
    NSLog(@"asks");
  }
  
  else if(self.favorSegmentedControl.selectedSegmentIndex == offer)
  {
    NSLog(@"Offers");
  }
  
  else
  {
    NSLog(@"My Favors");
  }
  

}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
  
  if(sender.selectedSegmentIndex == asks)
  {
    [self callMethodForSegment];
  }
  
  else if(sender.selectedSegmentIndex == offer)
  {
    [self callMethodForSegment];
  }
  
  else
  {
    [self callMethodForSegment];
  }
  
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  FavorCell *cell = [self.favorTableView dequeueReusableCellWithIdentifier:cellResuseIdentifier forIndexPath:indexPath];
  
  Favor *favorAtIndexPath = self.arrayOfFavors[indexPath.row];
  
  cell.posterName.text = favorAtIndexPath.posterName;
  
  UIImage *profImage = [UIImage imageWithData:[favorAtIndexPath.imageFile getData]];
  
  cell.profilePictureImageView.image = profImage;
  
  cell.timePassedSinceFavorWasPosted.text = favorAtIndexPath.timePosted;
  
//  UIImageView *imageView = [[UIImageView alloc]init];
  
//  imageView.layer.cornerRadius
  
//  cell.profilePictureImageView
  
//  cell.detailTextLabel.text = favorAtIndexPath.text;
  
  return cell;
}





@end
