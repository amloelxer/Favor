//
//  FavorDetailViewController.m
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "FavorDetailViewController.h"
#import "FavorCell.h"
#import "DatabaseManager.h"

@interface FavorDetailViewController ()  <DatabaseManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *favorLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedFavorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePassedTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *passedSelectedFavorPosterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITableView *responseTableView;
@property NSArray *arrayOfResponses;
@property DatabaseManager *parseManager;
@end

@implementation FavorDetailViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  self.parseManager = [[DatabaseManager alloc]init];
  
  self.parseManager.delegate = self;
  
  
  
  self.favorLabel.backgroundColor = [ColorPalette getFavorRedColor];
  
  self.profileImageView.image = self.profImage;
  
  //code to make it circular 
  self.profileImageView.layer.cornerRadius = self.profileImageView.image.size.width / 2;
  self.profileImageView.layer.masksToBounds = YES;
  
  self.selectedFavorTextLabel.text = self.passedFavorText;
  self.passedSelectedFavorPosterNameLabel.text = self.passedSelectedFavorPosterName;
  self.timePassedTextLabel.text = self.passedTimeText;
  
  if([self.passedUserThatMadeTheFavor isEqual:[User currentUser]])
  {
    NSLog(@"This is a post of mine");
    //enable what needs to be done on setup to change screens
  }
  //if this is not my favor
  else
  {
    self.phoneNumberLabel.hidden = YES;
  }
  
  [self.navigationController.navigationBar setBarTintColor:[ColorPalette getFavorRedColor]];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [self.navigationController.navigationBar setTranslucent:NO];
  
}

-(void)viewDidAppear:(BOOL)animated
{
  [self.parseManager getResponseForSelectedFavor:self.passedFavorID];
  
}

#pragma DatabaseManager Delegate responses
- (void) reloadTableWithResponses: (NSArray *) queryResults;
{
  NSLog(@"delegate method in reload table with responses is being called");
  
  self.arrayOfResponses = queryResults;
  [self.responseTableView reloadData];
  
}

#pragma mark - Table View Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
   ResponseCell *cell = [self.responseTableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
  
  Response *responseForCell = self.arrayOfResponses[indexPath.row];
  
  
  if([self.passedUserThatMadeTheFavor isEqual:[User currentUser]])
  {
    //enable what needs to be done on setup to change screens
  }
  //hide and disable the buttons because they shouldn't be there
  else
  {
    cell.chosenButton.hidden = YES;
    cell.chosenButton.enabled = NO;
  }

  cell.responderName.text = responseForCell.responseCreatorName;
  
  cell.responderText.text = responseForCell.responseText;
  
  //make sure the cell image loads for the right cell by comparing index Paths
  if([[self.responseTableView indexPathForCell:cell] isEqual:indexPath])
  {
    
    
  }
     
     
     [responseForCell.profPicFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
       
       //make sure the cell image loads for the right cell by comparing index Paths
       if([[self.responseTableView indexPathForCell:cell] isEqual:indexPath])
       {
         UIImage *profImage = [UIImage imageWithData:result];
         cell.responseProfilePictureView.image = profImage;
         
         cell.responseProfilePictureView.layer.cornerRadius = cell.responseProfilePictureView.image.size.width/2;
         cell.responseProfilePictureView.layer.masksToBounds = YES;
       }
       
     }];

  
  
  
  
  
//  cell.responseProfilePictureView.layer.cornerRadius = cell.responseProfilePictureView.image.size.width/2;

  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.arrayOfResponses.count;
}

//just a temp to test before we have cassidy's view
- (IBAction)makeResponseButtonPressed:(UIButton *)sender
{
  [self saveResponse];
}

//method to be put into cassidy's view controller later
-(void)saveResponse
{
 
    Response *newResponse = [Response objectWithClassName:@"Response"];
    [newResponse setObject:@"Default Response Text" forKey:@"responseText"];
    [newResponse setObject:[User currentUser] forKey:@"userWhoMadeTheResponse"];
  
  
  PFQuery *query = [PFQuery queryWithClassName:@"Favor"];
  [query getObjectInBackgroundWithId:self.passedFavorID block:^(PFObject *someFavor, NSError *error) {
    
    [newResponse setObject:someFavor forKey:@"favorWhichResponseIsOn"];
    
    NSNumber *numOfResponses = someFavor[@"numOfResponses"];
    
    NSNumber *newNumber = [NSNumber numberWithInt:[numOfResponses intValue] + 1];
    
    someFavor[@"numOfResponses"] = newNumber;
    
    [newResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      
      if (!error)
      {
        NSLog(@"The new response was saved sucessfully");
      }
      else
      {
        NSLog(@"The error is: %@", error);
      }
      
    }];

  
  }];
  
  
  
}



@end
