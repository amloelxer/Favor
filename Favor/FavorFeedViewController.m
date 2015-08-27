//
//  ViewController.m
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "FavorFeedViewController.h"
#import "ModalViewController.h"
#import "FavorDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"
#import "RadiusViewController.h"


@interface FavorFeedViewController () <UITableViewDataSource, UITableViewDelegate, DatabaseManagerDelegate, ModalViewControllerDelegate, LocationManagerDelegate, RadiusViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *favorTableView;
@property NSArray *arrayOfFavors;
@property DatabaseManager *parseDataManager;
@property ModalViewController *vc;
@property (weak, nonatomic) IBOutlet UISegmentedControl *favorSegmentedControl;
@property double radius;
@property UIFont* proximaNovaRegular;
@property UIFont* proximaNovaBold;
@property UIFont* proximaNovaSoftBold;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *radiusButton;


@end

@implementation FavorFeedViewController

 //constants for Favor Feed declared here
 NSInteger const offers = 0;
 NSInteger const asks = 1;

 NSString *const cellResuseIdentifier = @"CellID";

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.favorTableView.estimatedRowHeight = 155.0;
  self.favorTableView.rowHeight = UITableViewAutomaticDimension;
  
  self.proximaNovaRegular = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
  
  self.proximaNovaBold = [UIFont fontWithName:@"ProximaNova-Bold" size:16];
  
  self.proximaNovaSoftBold = [UIFont fontWithName:@"ProximaNovaSoft-Bold" size:16];
  
  
  [[UINavigationBar appearance] setTitleTextAttributes:
  [NSDictionary dictionaryWithObjectsAndKeys:
   [UIColor whiteColor], NSForegroundColorAttributeName,
   [UIFont fontWithName:@"ProximaNovaSoft-Bold" size:24.0], NSFontAttributeName,nil]];
  
  //sets the favor segemtn control text
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:self.proximaNovaRegular
                                                         forKey:NSFontAttributeName];
  [self.favorSegmentedControl setTitleTextAttributes:attributes
                                  forState:UIControlStateNormal];
  
  [self.radiusButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:@"ProximaNovaSoft-Bold" size:20], NSFontAttributeName,
                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                      nil] 
                            forState:UIControlStateNormal];

  
//  self.navigationController.tit
  //sets the default radius at 10
  self.radius = 10;
  
  LocationManager *someLocationManger = [LocationManager sharedManager];
  
  someLocationManger.delegate = self;
  
  //code for making the cells pop to the top of the table view on laod
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  [self.navigationController.navigationBar setBarTintColor:[ColorPalette getFavorPinkRedColor]];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [self.navigationController.navigationBar setTranslucent:NO];
  
  self.favorSegmentedControl.tintColor = [ColorPalette getFavorPinkRedColor];
  
  //deletes everything in the cache on load
  PFQuery *query = [PFQuery queryWithClassName:@"Favor"];
  [query fromLocalDatastore];
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [PFObject unpinAllInBackground:objects];
    
  }];
  
  self.currentUser = [User currentUser];
  
  self.arrayOfFavors = [NSArray new];
  
  self.parseDataManager = [[DatabaseManager alloc]init];
  
  self.parseDataManager.delegate = self;
  
}

- (IBAction)onRadiusButtonPressed:(UIBarButtonItem *)sender
{
  NSNumber *radius = [NSNumber numberWithDouble:self.radius];
  RadiusViewController *vc = [[RadiusViewController alloc] initWithBackgroundViewController:self currentRadius:radius];
  [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
  
  [self presentViewController:vc animated:NO completion:nil];
}

- (void)radiusSelected:(NSNumber *)radius radiusViewController:(RadiusViewController *)radiusVC
{
  NSLog(@"The radius is %@", radius);
  
  PFQuery *query = [PFQuery queryWithClassName:@"Favor"];
  [query fromLocalDatastore];
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    //when you're saving to the cache make sure to unpin (work around for now)
    [PFObject unpinAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
      
      self.radius = [radius doubleValue];
      [self.parseDataManager getAllFavorsFromParse:self.radius];
      NSString *distanceLabelText = [NSString stringWithFormat:@"%@ miles", radius];
      
      self.radiusButton.title = distanceLabelText;
      
      
    }];
    
  }];

  
  
}

#pragma mark - ModalViewController

-(void)ModalViewControllerDidCancel:(ModalViewController *)modalViewController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
  
}

- (void)ModalViewControllerDidSubmitFavor:(ModalViewController *)modalViewController askOrOffer:(NSInteger)someAskOrOffer
{
  
  PFQuery *query = [PFQuery queryWithClassName:@"Favor"];
  [query fromLocalDatastore];
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    //when you're saving to the cache make sure to unpin (work around for now)
    [PFObject unpinAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
      
        [self.parseDataManager getAllFavorsFromParse:self.radius];
      
    }];
    
  }];
  
}

#pragma mark - DatabaseManager Delegate Methods

- (void)reloadTableWithQueryResults:(NSArray *)queryResults
{
  [self getCachedFavorsWithSegmentFilterApplied];
}

- (void) reloadTableWithCachedQueryResults: (NSArray *) queryResults
{
  self.arrayOfFavors = queryResults;
  [self.favorTableView reloadData];
}

#pragma mark - LocationManager Delegate Methods
- (void)initialLocationHasBeenRecieved
{
  NSLog(@"Inital Location has been recieved");
  //within a default raidus let's say 10 miles
  [self.parseDataManager getAllFavorsFromParse:self.radius];
}

- (IBAction)addFavorPressed:(UIBarButtonItem *)sender
{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    ModalViewController *vc = [[ModalViewController alloc] initWithBackgroundViewController:self];
    [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:vc animated:NO completion:nil];
}



- (void)getCachedFavorsWithSegmentFilterApplied
{
  //0 is offer 1 is ask 
  if(self.favorSegmentedControl.selectedSegmentIndex == 0 || self.favorSegmentedControl.selectedSegmentIndex == 1 )
  {
    //gets all the favors from parse depending what was selected on the UISegment controller
    [self.parseDataManager getAllFavorsFromLocalParseStore:self.favorSegmentedControl.selectedSegmentIndex user:self.currentUser];
  }
  
  else
  {
    //can't send nil or it will default to 0
     [self.parseDataManager getAllFavorsFromLocalParseStore:2 user:self.currentUser];
  }
  
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
  [self getCachedFavorsWithSegmentFilterApplied];
}

#pragma mark - Table View Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  FavorCell *cell = [self.favorTableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
                     
  Favor *favorAtIndexPath = self.arrayOfFavors[indexPath.row];
  
  //name of favor poster
  cell.posterName.text = favorAtIndexPath.posterName;
  cell.posterName.font = self.proximaNovaBold;
  
   //actual text in the favor
  cell.favorText.text = favorAtIndexPath.text;
  cell.favorText.font = self.proximaNovaRegular;
  cell.favorText.textColor = [ColorPalette getGreyTextColor];
  
  //time since favor has passed
  cell.timePassedSinceFavorWasPosted.text = favorAtIndexPath.timePosted;
  cell.timePassedSinceFavorWasPosted.font = self.proximaNovaRegular;
  cell.timePassedSinceFavorWasPosted.textColor = [ColorPalette getGreyTextLessOpaqueColor];
  
  //need to calculate distance from currentUser
  //distance from actual favor to persons
  cell.distanceFromPoster.text = favorAtIndexPath.distanceAwayFromCL;
  cell.distanceFromPoster.font = self.proximaNovaRegular;
  cell.distanceFromPoster.textColor = [ColorPalette getGreyTextLessOpaqueColor];
  
  
  NSNumber *numOfResponses = favorAtIndexPath.numberOfResponses;
  NSNumber *hasResponseBeenAccepeted = favorAtIndexPath.currentState;
  
  //checks responses first
  [cell.responseLabelOnFavor setOnNumber:numOfResponses];
  
  //then checks the state and changes accordingly 
  [cell.responseLabelOnFavor checkIfFavorHasBeenAcceped:hasResponseBeenAccepeted];
  
  UIFont *proximaNovaRegSmaller = [UIFont fontWithName:@"ProximaNova-Regular" size:16];

  cell.responseLabelOnFavor.font = proximaNovaRegSmaller;
  
  [favorAtIndexPath.imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
    
    //make sure the cell image loads for the right cell by comparing index Paths
    if([[self.favorTableView indexPathForCell:cell] isEqual:indexPath])
    {
      UIImage *profImage = [UIImage imageWithData:result];
      cell.profilePictureImageView.image = profImage;
                                                      //make sure this is frame.size and not image.size
      cell.profilePictureImageView.layer.cornerRadius = cell.profilePictureImageView.frame.size.width/2;
      cell.profilePictureImageView.layer.masksToBounds = YES;

    }
    
  }];
  
  
  return cell;
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.arrayOfFavors.count;
}

#pragma mark - Prepare for Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  NSIndexPath *path = [self.favorTableView indexPathForSelectedRow];
  
  Favor *favorAtIndexPath = self.arrayOfFavors[path.row];
  
  FavorDetailViewController *vc = segue.destinationViewController;
  
  FavorCell *cell = [self.favorTableView cellForRowAtIndexPath:path];
  
  UIImage *profImage = cell.profilePictureImageView.image;
  
  vc.profImage = profImage;
  
  vc.passedFavorText = favorAtIndexPath.text;
  
  vc.passedSelectedFavorPosterName = favorAtIndexPath.posterName;
  
  vc.passedTimeText = favorAtIndexPath.timePosted;
  
  vc.passedUserThatMadeTheFavor = favorAtIndexPath.CreatedBy;
  
  vc.passedFavorID = favorAtIndexPath.uniqueID;

  vc.passedFavorState = favorAtIndexPath.currentState;
  
  vc.passedDistanceFromCurrentLocation = favorAtIndexPath.distanceAwayFromCL;
  
}





@end
