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


@end

@implementation FavorFeedViewController

//for dequeing the cells
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
  
  //  firstFavor[@"askOrOffer"] = (BOOL)NO;
  
  PFRelation *relation = [firstFavor relationForKey:@"CreatedBy"];
  
  [relation addObject:self.currentUser];
  
  [firstFavor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if (!error)
    {
      NSLog(@"Save sucessfully");
      
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




-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  FavorCell *cell = [self.favorTableView dequeueReusableCellWithIdentifier:cellResuseIdentifier forIndexPath:indexPath];
  
  Favor *favorAtIndexPath = self.arrayOfFavors[indexPath.row];
  
  cell.posterName.text = favorAtIndexPath.posterName;
  
//  UIImageView *imageView = [[UIImageView alloc]init];
  
//  imageView.layer.cornerRadius
  
//  cell.profilePictureImageView
  
  
  
  
//  cell.detailTextLabel.text = favorAtIndexPath.text;
  
  return cell;
}





@end
