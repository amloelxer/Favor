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

@interface FavorFeedViewController () <UITableViewDataSource, UITableViewDelegate, DatabaseManagerDelegate, ModalViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *favorTableView;
@property NSArray *arrayOfFavors;
@property DatabaseManager *parseDataManager;
@property ModalViewController *vc;


@property (weak, nonatomic) IBOutlet UISegmentedControl *favorSegmentedControl;

@end

@implementation FavorFeedViewController

 //constants for Favor Feed declared here
 NSInteger const asks = 0;
 NSInteger const offers = 1;
 NSString *const cellResuseIdentifier = @"CellID";

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  
//  [self.favorTableView registerClass:[FavorCell class] forCellReuseIdentifier:@"CellID"];
  
  PFQuery *query = [PFQuery queryWithClassName:@"Favor"];
  [query fromLocalDatastore];
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [PFObject unpinAllInBackground:objects];
    
  }];
  
  self.currentUser = [User currentUser];
  
  self.arrayOfFavors = [NSArray new];
  
  self.parseDataManager = [[DatabaseManager alloc]init];
  
  self.parseDataManager.delegate = self;
  
  NSLog(@"Selected Segment %lu", self.favorSegmentedControl.selectedSegmentIndex);
  
  
  [self.parseDataManager getAllFavorsFromParse];
  
  [self.navigationController.navigationBar setBarTintColor:[ColorPalette getFavorRedColor]];
    
}

#pragma mark - ModalViewController

-(void)ModalViewControllerDidCancel:(ModalViewController *)modalViewController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
  
}

- (void)ModalViewControllerDidSubmitFavor:(ModalViewController *)modalViewController askOrOffer:(NSInteger)someAskOrOffer
{
    NSLog(@"Delegate Method ask or offer called");
  
    [self callMethodForSegment];
}

#pragma mark - DatabaseManager Delegate Methods

-(void)reloadTableWithQueryResults:(NSArray *)queryResults
{
  [self callMethodForSegment];
}

- (void) reloadTableWithCachedQueryResults: (NSArray *) queryResults
{
  NSLog(@"It's reloading the data with the cached query");
  self.arrayOfFavors = queryResults;
  [self.favorTableView reloadData];
}


- (IBAction)addFavorPressed:(UIBarButtonItem *)sender
{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    ModalViewController *vc = [[ModalViewController alloc] initWithBackgroundViewController:self];
    [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.arrayOfFavors.count;
}


- (void)callMethodForSegment
{
  //0 is offer 1 is ask 
  if(self.favorSegmentedControl.selectedSegmentIndex == 0 || self.favorSegmentedControl.selectedSegmentIndex == 1 )
  {
    NSLog(@"The selected segment is %ld", (long)self.favorSegmentedControl.selectedSegmentIndex);
    
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
  [self callMethodForSegment];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  FavorCell *cell = [self.favorTableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
                     
  Favor *favorAtIndexPath = self.arrayOfFavors[indexPath.row];
  
  cell.posterName.text = favorAtIndexPath.posterName;
  
  cell.timePassedSinceFavorWasPosted.text = favorAtIndexPath.timePosted;
  
  UIImage *profImage = [UIImage imageWithData:[favorAtIndexPath.imageFile getData]];

  cell.profilePictureImageView.image = profImage;
  
  cell.profilePictureImageView.layer.cornerRadius = cell.profilePictureImageView.image.size.width/2;
  cell.profilePictureImageView.layer.masksToBounds = YES;
  cell.favorText.text = favorAtIndexPath.text;
  
//  [cell layoutSubviews];
  
  return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  
  NSIndexPath *path = [self.favorTableView indexPathForSelectedRow];
  
  Favor *favorAtIndexPath = self.arrayOfFavors[path.row];
  
  FavorDetailViewController *vc = segue.destinationViewController;
  
  UIImage *profImage = [UIImage imageWithData:[favorAtIndexPath.imageFile getData]];
  
  vc.profImage = profImage;
  
  vc.passedFavorText = favorAtIndexPath.text;

  vc.passedSelectedFavorPosterName = favorAtIndexPath.posterName;
  
  vc.passedTimeText = favorAtIndexPath.timePosted;
}





@end
