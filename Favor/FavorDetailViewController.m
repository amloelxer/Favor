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
#import <QuartzCore/QuartzCore.h>
#import "StringModifier.h"
#import <MessageUI/MessageUI.h>


@interface FavorDetailViewController ()  <DatabaseManagerDelegate, ResponseCellDelegate, KeyboardCustomViewDelegate,
MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *selectedFavorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePassedTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *passedSelectedFavorPosterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITableView *responseTableView;
@property NSMutableArray *arrayOfResponses;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property BOOL favorHasBeenChosen;
@property BOOL isFavorMine;
@property DatabaseManager *parseManager;
@property (weak, nonatomic) IBOutlet OriginalFavorView *originalFavorPosterView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property UIRefreshControl *refreshControl;
@property NSString *responsePhoneNumber;
@property UIFont* proximaNovaRegular;
@property UIFont* proximaNovaBold;
@property UIFont* proximaNovaSoftBold;
@property KeyboardCustomView *keyboardView;
@property (weak, nonatomic) IBOutlet UIImageView *favorProfileView;
@property BOOL detailViewHasCachedReloadedForFirstTime;
//@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;

@end

@implementation FavorDetailViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  self.detailViewHasCachedReloadedForFirstTime = NO;
  
  self.proximaNovaRegular = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
  self.proximaNovaBold = [UIFont fontWithName:@"ProximaNova-Bold" size:16];
  self.proximaNovaSoftBold = [UIFont fontWithName:@"ProximaNovaSoft-Bold" size:16];
  
  self.originalFavorPosterView.backgroundColor = [ColorPalette getFavorPinkRedColor];
  
  self.view.backgroundColor = [ColorPalette getFavorPinkRedColor];
  
  
  
  [self.navigationController.navigationBar setBarTintColor:[ColorPalette getFavorPinkRedColor]];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [self.navigationController.navigationBar setTranslucent:NO];
  
  self.favorHasBeenChosen = NO;
  self.isFavorMine = NO;
  
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.responseTableView addSubview:self.refreshControl];
  self.refreshControl.backgroundColor = [ColorPalette getFavorPinkRedColor];
  self.refreshControl.tintColor = [UIColor whiteColor];
  [self.refreshControl addTarget:self
                          action:@selector(reloadOnPullDown)
                forControlEvents:UIControlEventValueChanged];

  if([self.passedFavorState intValue] == FavorStateClosed)
  {
    self.addCommentButton.hidden = YES;
    self.addCommentButton.enabled = NO;
    self.favorHasBeenChosen = YES;
  }
  

  self.parseManager = [[DatabaseManager alloc]init];
  
  self.parseManager.delegate = self;
  
  
  self.favorProfileView.image = self.profImage;

//  self.numberInputImageView.image = profImage;
  //make sure this is frame.size and not image.size
  
  
  
  /*
   self.profileImageView is giving you the wrong frame for some reason
   this is a temp fix for now. It's corner radius should be half the height
   to make it rounded. It's current value is obvs 50x50
  */
  
  self.favorProfileView.layer.cornerRadius = 25;

  self.favorProfileView.layer.masksToBounds = YES;
  
  self.selectedFavorTextLabel.text = self.passedFavorText;
  self.selectedFavorTextLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:20];
  
  self.passedSelectedFavorPosterNameLabel.text = self.passedSelectedFavorPosterName;
  self.passedSelectedFavorPosterNameLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];
  
  self.timePassedTextLabel.text = self.passedTimeText;
  self.timePassedTextLabel.font = self.proximaNovaRegular;
  
  self.distanceLabel.text = self.passedDistanceFromCurrentLocation;
  self.distanceLabel.font = self.proximaNovaRegular;
  
  
  self.responseTableView.estimatedRowHeight = 109.0;
  self.responseTableView.rowHeight = UITableViewAutomaticDimension;
  
  if([self.passedUserThatMadeTheFavor isEqual:[User currentUser]])
  {
//    NSLog(@"This is a post of mine");
    self.isFavorMine = YES;
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"badge"] = [NSNumber numberWithInt:0];
    [currentInstallation saveInBackground];
    

  }
  
  else
  {
    self.phoneNumberLabel.hidden = YES;
  }
  
  
  //code to make it circular
  
  [self.navigationController.navigationBar setBarTintColor:[ColorPalette getFavorPinkRedColor]];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [self.navigationController.navigationBar setTranslucent:NO];

    
    
    
  // KEYBOARD
    // Use your CustomView instead of the UIView that is normally attached with [super loadView][UIScreen mainScreen].bounds]
    self.keyboardView = [[KeyboardCustomView alloc]initWithFrame:CGRectMake(100, 100, 50, 300)];
    [self.keyboardView becomeFirstResponder];
  
    self.keyboardView.delegate = self;
  
    // Add a TapGestureRecognizer to dismiss the keyboard when the view is tapped
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTouchView)];
    [self.keyboardView addGestureRecognizer:recognizer];
    [self.view addSubview:self.keyboardView];
  
   [self.parseManager getResponseForSelectedFavor:self.passedFavorID];

}

// Dissmiss the keyboard on view touches by making
// the view the first responder
- (void)didTouchView {
    [self.view becomeFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
//  [self.parseManager getResponseForSelectedFavor:self.passedFavorID];
}

-(void)reloadOnPullDown
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
  
   chosenResponseCell.hidden = NO;
  
  NSIndexPath *indexPath = [self.responseTableView indexPathForCell:chosenResponseCell];
  
  Response *responseForCell = self.arrayOfResponses[indexPath.row];
  
  //now send push notifications to that badboy
  User* userWhoseResponseWasSelected = [responseForCell objectForKey:@"userWhoMadeThisResponse"];
  
  self.responsePhoneNumber = userWhoseResponseWasSelected[@"phoneNumber"];
  
  PFQuery *queryForUser = [PFInstallation query];
  [queryForUser whereKey:@"user" equalTo:userWhoseResponseWasSelected];
  
  //sends push to person whose response was accepted
  User *currentUser = [User currentUser];
  NSString *fullName = currentUser[@"name"];
  
  NSDictionary *dict = @{
                         @"alert" : [NSString stringWithFormat:@"%@ has accepted your response!", [StringModifier getFirstNameFromFullName:fullName]]
                         
                         };
  
  PFPush *push = [PFPush new];
  
  [push setData:dict];
  
  [push setQuery:queryForUser];
  
  [push sendPushInBackgroundWithBlock:^(BOOL succededPush, NSError *error)
   {
     
   }];

  
  chosenResponseCell.phoneNumberLabel.hidden = NO;
  chosenResponseCell.phoneNumberLabel.enabled = YES;
  chosenResponseCell.phoneNumberLabel.textColor = [UIColor whiteColor];

  chosenResponseCell.phoneNumberLabel.text = self.responsePhoneNumber;
  
  chosenResponseCell.chosenButton.hidden = YES;
  chosenResponseCell.chosenButton.enabled = NO;

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
//  NSLog(@"delegate method in reload table with responses is being called");
//  
  NSLog(@"delegate method in reload table with responses is being called");
  self.arrayOfResponses = [queryResults mutableCopy];
  [self.responseTableView reloadData];
  [self.responseTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.001];
  [self.refreshControl endRefreshing];
  
}

//method to be put into cassidy's view controller/Database later

-(void)isDoneSavingResponse
{
  NSLog(@"Is done saving the response");
  [self.parseManager getResponseForSelectedFavor:self.passedFavorID];
  [self.keyboardView resignFirstResponder];
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
  

  
  if ([responseForCell.wasChosen intValue] == FavorStateClosed)
  {
    cell.backgroundColor = [ColorPalette getFavorGreenColor];
    
    if(self.isFavorMine)
    {
      
      User *userOnSelectedResponse = responseForCell.userWhoMadeThisResponse;
      
      [userOnSelectedResponse fetchInBackground];
      
      NSString *responderNumber = userOnSelectedResponse[@"phoneNumber"];
      
      cell.phoneNumberLabel.text = responderNumber;
      
      cell.phoneNumberLabel.hidden = NO;
      
    }
    
  }
  
  if(self.favorHasBeenChosen == YES)
  {
    cell.chosenButton.hidden = YES;
    cell.chosenButton.enabled = NO;
    
    cell.responderName.textColor = [UIColor whiteColor];
    cell.responderText.textColor= [UIColor whiteColor];
    cell.timeAgoLabel.textColor = [UIColor whiteColor];
    cell.distanceFromCurrentLocationLabel.textColor = [UIColor whiteColor];
    cell.phoneNumberLabel.textColor = [UIColor whiteColor];
    
  }
  
  cell.responderName.text = responseForCell.responseCreatorName;
  cell.responderName.font = self.proximaNovaSoftBold;
  
  cell.responderText.text = responseForCell.responseText;
  cell.responderText.font = self.proximaNovaRegular;
  
  cell.timeAgoLabel.text = responseForCell.timeAgo;
  cell.responderText.font = self.proximaNovaRegular;
  
  cell.distanceFromCurrentLocationLabel.text = responseForCell.distanceAway;
  cell.distanceFromCurrentLocationLabel.font = self.proximaNovaRegular;
  
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
         
         cell.responseProfilePictureView.layer.cornerRadius = cell.responseProfilePictureView.frame.size.width/2;
         cell.responseProfilePictureView.layer.masksToBounds = YES;
       }
       
     }];

  return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  NSInteger numOfSections = 0;
  if (self.arrayOfResponses.count > 0)
  {
    self.responseTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    numOfSections = 1;
    //    self.favorTableView.backgroundColor = [UIColor whiteColor];
    self.responseTableView.backgroundView = nil;
  }
  else
  {
    UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.responseTableView.bounds.size.width, self.responseTableView.bounds.size.height)];
    
    noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noDataLabel.numberOfLines = 0;
    noDataLabel.text = @"Currently there are no responses\nAdd a response!";
    noDataLabel.textColor = [ColorPalette getFavorPinkRedColor];
    noDataLabel.font = [UIFont fontWithName:@"ProximaNovaSoft-Bold" size:18];
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.responseTableView.backgroundView = noDataLabel;
    //    self.favorTableView.backgroundColor = [ColorPalette getFavorPinkRedColor];
    self.responseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  }
  
  return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.arrayOfResponses.count;
}

-(void)sendTextToRootController:(NSString *)text
{
  self.detailViewHasCachedReloadedForFirstTime = NO;
  [self.parseManager saveResponse:text passedFavorID:self.passedFavorID];
  
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:self.passedUserThatMadeTheFavor];
  
  User *currentUser = [User currentUser];
  NSString *fullName = currentUser[@"name"];
  
  NSDictionary *dict = @{
                         @"alert" : [NSString stringWithFormat:@"%@ commented on your favor!", [StringModifier getFirstNameFromFullName:fullName]],
                          @"badge" : @"Increment"
                         
                          };
  
  PFPush *push = [PFPush new];
  
  [push setData:dict];
  
  [push setQuery:query];
  
  [push sendPushInBackgroundWithBlock:^(BOOL succededPush, NSError *error)
   {
     
   }];
  
}



- (IBAction)reportButtonTapped:(UIBarButtonItem *)sender {
    NSString *emailTitle = [NSString stringWithFormat: @"Report Favor ID:%@", self.passedFavorID];
    // Email Content
    NSString *messageBody = @"Thanks for reporting questionable content. We'll investigate this favor and its responses. Please add any additional concerns."; //
    NSArray *toRecipents = [NSArray arrayWithObject:@"favordevteam@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"\n\n Email Sent");
    }
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self dismissModalViewControllerAnimated:YES];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
