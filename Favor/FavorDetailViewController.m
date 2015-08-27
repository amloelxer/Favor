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
#import "OriginalFavorView.h"

@interface FavorDetailViewController ()  <DatabaseManagerDelegate, ResponseCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *selectedFavorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePassedTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *passedSelectedFavorPosterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITableView *responseTableView;
@property NSMutableArray *arrayOfResponses;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property BOOL favorHasBeenChosen;
@property DatabaseManager *parseManager;
@property (weak, nonatomic) IBOutlet OriginalFavorView *originalFavorPosterView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property UIFont* proximaNovaRegular;
@property UIFont* proximaNovaBold;
@property UIFont* proximaNovaSoftBold;

@end

@implementation FavorDetailViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  self.proximaNovaRegular = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
  self.proximaNovaBold = [UIFont fontWithName:@"ProximaNova-Bold" size:16];
  self.proximaNovaSoftBold = [UIFont fontWithName:@"ProximaNovaSoft-Bold" size:16];
  
  self.originalFavorPosterView.backgroundColor = [ColorPalette getFavorPinkRedColor];
  
  [self.navigationController.navigationBar setBarTintColor:[ColorPalette getFavorPinkRedColor]];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [self.navigationController.navigationBar setTranslucent:NO];
  
  self.favorHasBeenChosen = NO;

  if([self.passedFavorState intValue] == FavorStateClosed)
  {
    self.addCommentButton.hidden = YES;
    self.addCommentButton.enabled = NO;
    self.favorHasBeenChosen = YES;
  }
  

  self.parseManager = [[DatabaseManager alloc]init];
  
  self.parseManager.delegate = self;
  
  
  self.profileImageView.image = self.profImage;
  
  //code to make it circular 
  self.profileImageView.layer.cornerRadius = self.profileImageView.image.size.width / 2;
  self.profileImageView.layer.masksToBounds = YES;
  
  self.selectedFavorTextLabel.text = self.passedFavorText;
  self.selectedFavorTextLabel.font = self.proximaNovaRegular;
  
  self.passedSelectedFavorPosterNameLabel.text = self.passedSelectedFavorPosterName;
  self.passedSelectedFavorPosterNameLabel.font = self.proximaNovaSoftBold;
  
  self.timePassedTextLabel.text = self.passedTimeText;
  self.timePassedTextLabel.font = self.proximaNovaRegular;
  
  self.distanceLabel.text = self.passedDistanceFromCurrentLocation;
  self.distanceLabel.font = self.proximaNovaRegular;
  
  
  self.responseTableView.estimatedRowHeight = 109.0;
  self.responseTableView.rowHeight = UITableViewAutomaticDimension;
  
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
  
  [self.navigationController.navigationBar setBarTintColor:[ColorPalette getFavorPinkRedColor]];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [self.navigationController.navigationBar setTranslucent:NO];
  
}

-(void)viewDidAppear:(BOOL)animated
{
  [self.parseManager getResponseForSelectedFavor:self.passedFavorID];
}

#pragma Response Cell Delegate was Chosen

-(void)chosenButtonOnCellWasPressed:(ResponseCell *)chosenResponseCell
{
  NSLog(@"Button on cell was pressed");
  
  self.favorHasBeenChosen = YES;
  
  self.addCommentButton.hidden = YES;
  self.addCommentButton.enabled = NO;
  
  NSIndexPath *indexPath = [self.responseTableView indexPathForCell:chosenResponseCell];
  
  Response *responseForCell = self.arrayOfResponses[indexPath.row];
  
  //now send push notifications to that badboy
  //waiting to set up for cassidy's code
  User* userWhoseResponseWasSelected = [responseForCell objectForKey:@"userWhoMadeThisResponse"];
  
  Favor *favorWhichResponseIsOn = [responseForCell objectForKey:@"favorThisResponseIsOn"];
  
  NSNumber *responseHasBeenSelectedForFavor = [NSNumber numberWithInt:FavorStateClosed];
  
  [favorWhichResponseIsOn setObject:responseHasBeenSelectedForFavor forKey:@"currentState"];
  
  [favorWhichResponseIsOn saveInBackground];
  
  
  PFQuery *query = [PFQuery queryWithClassName:@"Response"];
  [query getObjectInBackgroundWithId:responseForCell.uniqueID
                               block:^(PFObject *response, NSError *error) {
                                 [response setObject:responseHasBeenSelectedForFavor forKey:@"wasChosen"];
                                 
                                 [response saveInBackground];
                                 
                               }];
  
  [self.arrayOfResponses removeObjectAtIndex:indexPath.row];
  
  [self.arrayOfResponses insertObject:responseForCell atIndex:0];
  
  [self.responseTableView reloadData];
  
  chosenResponseCell.backgroundColor = [ColorPalette getFavorGreenColor];
  
}


#pragma DatabaseManager Delegate responses
- (void) reloadTableWithResponses: (NSArray *) queryResults;
{
  NSLog(@"delegate method in reload table with responses is being called");
  
  self.arrayOfResponses = [queryResults mutableCopy];
  [self.responseTableView reloadData];
  
}

//method to be put into cassidy's view controller/Database later

-(void)isDoneSavingResponse
{
  NSLog(@"Is done saving the response");
  [self.parseManager getResponseForSelectedFavor:self.passedFavorID];
}


#pragma mark - Table View Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
   ResponseCell *cell = [self.responseTableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
  
  Response *responseForCell = self.arrayOfResponses[indexPath.row];
  
  cell.delegate = self;
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
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
  
  ;
  if ([responseForCell.wasChosen intValue] == FavorStateClosed)
  {
    cell.backgroundColor = [ColorPalette getFavorGreenColor];
  }
  
  if(self.favorHasBeenChosen == YES)
  {
    cell.chosenButton.hidden = YES;
    cell.chosenButton.enabled = NO;
  }



  cell.responderName.text = responseForCell.responseCreatorName;
  cell.responderName.font = self.proximaNovaSoftBold;
  
  cell.responderText.text = responseForCell.responseText;
  cell.responderText.font = self.proximaNovaRegular;
  
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

  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.arrayOfResponses.count;
}

//just a temp to test before we have cassidy's view
- (IBAction)makeResponseButtonPressed:(UIButton *)sender
{
  NSString *longString = @"This is a giant string which should take up a lot of room and hopefully the cell will have the space and everything will be fine";
  [self.parseManager saveResponse:longString passedFavorID:self.passedFavorID];
}





@end
