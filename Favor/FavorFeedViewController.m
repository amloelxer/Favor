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


@interface FavorFeedViewController () <UITableViewDataSource, UITableViewDelegate, DatabaseManagerDelegate, ModalViewControllerDelegate, LocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *favorTableView;
@property NSArray *arrayOfFavors;
@property DatabaseManager *parseDataManager;
@property ModalViewController *vc;
@property (weak, nonatomic) IBOutlet UISegmentedControl *favorSegmentedControl;

@end

@implementation FavorFeedViewController

 //constants for Favor Feed declared here
 NSInteger const offers = 0;
 NSInteger const asks = 1;

 NSString *const cellResuseIdentifier = @"CellID";

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  LocationManager *someLocationManger = [LocationManager sharedManager];
  
  someLocationManger.delegate = self;
  
  //code for making the cells pop to the top of the table view on laod
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  //do nav bar stuff
  [self.navigationController.navigationBar setBarTintColor:[ColorPalette getFavorRedColor]];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [self.navigationController.navigationBar setTranslucent:NO];
  
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
      
        [self.parseDataManager getAllFavorsFromParse:10];
      
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
  [self.parseDataManager getAllFavorsFromParse:10];
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
                     
  Favor *favorAtIndexPath = self.arrayOfFavors[indexPath.row];
  
  cell.posterName.text = favorAtIndexPath.posterName;
  
  cell.timePassedSinceFavorWasPosted.text = favorAtIndexPath.timePosted;
  
  cell.favorText.text = favorAtIndexPath.text;
  
  NSNumber *numOfResponses = favorAtIndexPath.numberOfResponses;
    
  [cell.responseLabelOnFavor setOnNumber:numOfResponses];
  
  [favorAtIndexPath.imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
    
    //make sure the cell image loads for the right cell by comparing index Paths
    if([[self.favorTableView indexPathForCell:cell] isEqual:indexPath])
    {
      UIImage *profImage = [UIImage imageWithData:result];
      cell.profilePictureImageView.image = profImage;
      
      cell.profilePictureImageView.layer.cornerRadius = cell.profilePictureImageView.image.size.width/2;
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

}





@end
