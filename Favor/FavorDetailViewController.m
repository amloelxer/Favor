//
//  FavorDetailViewController.m
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "FavorDetailViewController.h"
#import "FavorCell.h"

@interface FavorDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *favorLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedFavorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePassedTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *passedSelectedFavorPosterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITableView *responseTableView;
@property NSMutableArray *arrayOfResponses;

@end

@implementation FavorDetailViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
  
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

#pragma mark - Table View Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
   FavorCell *cell = [self.responseTableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
  
  //make sure the cell image loads for the right cell by comparing index Paths
  if([[self.responseTableView indexPathForCell:cell] isEqual:indexPath])
  {

  }
//
//  Favor *favorAtIndexPath = self.arrayOfFavors[indexPath.row];
//  
//  cell.posterName.text = favorAtIndexPath.posterName;
//  
//  cell.timePassedSinceFavorWasPosted.text = favorAtIndexPath.timePosted;
//  
//  cell.favorText.text = favorAtIndexPath.text;
//  
  
//  [favorAtIndexPath.imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
//    
//    //make sure the cell image loads for the right cell by comparing index Paths
//    if([[self.favorTableView indexPathForCell:cell] isEqual:indexPath])
//    {
//      UIImage *profImage = [UIImage imageWithData:result];
//      cell.profilePictureImageView.image = profImage;
//      
//      cell.profilePictureImageView.layer.cornerRadius = cell.profilePictureImageView.image.size.width/2;
//      cell.profilePictureImageView.layer.masksToBounds = YES;
//      
//    }
//    
//  }];
//  
//  
  return cell;
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
  [newResponse setObject:self.passedFavor forKey:@"favorWhichResponseIsOn"];
  

  
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
  


}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//  return self.arrayOfResponses.count;
  
    return 1;
}

@end
