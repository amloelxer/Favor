//
//  DatabaseManager.m
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "DatabaseManager.h"


@implementation DatabaseManager

+ (NSString *)dateConverter:(NSDate *)passedDate
{
//  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//  [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//  
//  NSString *stringFromDate = [formatter stringFromDate:passedDate];
//  
//  
//  return stringFromDate;
  
  NSTimeInterval timeInterval = fabs([passedDate timeIntervalSinceNow]);
  
  int minutes = timeInterval / 60;
  int hours = minutes / 60;
  int days = hours / 24;
  
  if(minutes < 1)
  {
    return @"now";
  }
  
  else if (hours <1 )
  {
    return [NSString stringWithFormat:@"%im ago", minutes];
  }
  
  else if (days <1 )
  {
    return [NSString stringWithFormat:@"%ih ago", hours];
  }
  
  else
  {
    return [NSString stringWithFormat:@"%id ago", days];
  }
  
}

- (void)getAllFavorsFromLocalParseStore:(NSInteger)selectedSegment user:(User *)currentUser
{
  NSMutableArray *queryResults = [[NSMutableArray alloc]init];
  
  PFQuery *query = [PFQuery queryWithClassName:@"Favor"];
//  [query includeKey:@"updatedAt"];
//  
  [query addDescendingOrder:@"updatedAt"];
  
  [query fromLocalDatastore];
  
  //it's an offer so it's 0 for no
  if(selectedSegment == 0)
  {
    [query whereKey:@"askOrFavor" equalTo:[NSNumber numberWithBool:NO]];
    NSLog(@"The selected segment from the getAllFavors Method is %ld",(long)selectedSegment);
    
  }
  
  //it's an ask so it's 1 for yes
  else if(selectedSegment == 1)
  {
    [query whereKey:@"askOrFavor" equalTo:[NSNumber numberWithBool:YES]];
     NSLog(@"The selected segment from the getAllFavors Method is %ld",(long)selectedSegment);
  }
  
  else
  {
    NSLog(@"My Own Favors should print");
    [query whereKey:@"userThatCreatedThisFavor" equalTo:currentUser];
     NSLog(@"The selected segment from the getAllFavors Method is %ld",(long)selectedSegment);
  }
  
  
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    for(Favor *favor in objects)
    {
      
      Favor *someFav = favor;
      [queryResults addObject:favor];
      
    }
            
    [self.delegate reloadTableWithCachedQueryResults:queryResults];
    
  }];

}


-(void)getAllFavorsFromParse
{
  
  NSMutableArray *queryResults = [[NSMutableArray alloc]init];
  
  PFQuery *postQueryForUser = [PFQuery queryWithClassName:@"Favor"];
  
  
//  [postQueryForUser addDescendingOrder:@"updatedAt"];
  
  //gotta have this line. So So So So So So important
  [postQueryForUser includeKey:@"CreatedBy"];
  [postQueryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    if(!error)
    {
      for(Favor *someFavor in objects)
      {
        
        Favor *tempFavor = [Favor new];
        
        tempFavor.text = [someFavor objectForKey:@"text"];
        
        //must cast on the other side from type ID to boolValue
        //I was getting the pointer to the object and not the actual value
        //this is very very important
        BOOL thisAskOrOffer = [someFavor[@"askOrOffer"]boolValue];
        
        tempFavor.askOrFavor = thisAskOrOffer;
        
        NSDate *favorTimeUpdatedAt = someFavor.updatedAt;
        
        NSString *stringFavorWasPosted = [DatabaseManager dateConverter:favorTimeUpdatedAt];
        
        tempFavor.timePosted = stringFavorWasPosted;
        
        User *user = [someFavor objectForKey:@"CreatedBy"];
        
        tempFavor.userThatCreatedThisFavor = [someFavor objectForKey:@"CreatedBy"];
        
        tempFavor.posterName = [user objectForKey:@"name"];
        
        PFFile *imageFile = [user objectForKey:@"ProfilePicture"];
        
        tempFavor.imageFile = imageFile;
        
        [queryResults addObject:tempFavor];
      }
      
     
      [PFObject pinAllInBackground:queryResults block:^(BOOL succeeded, NSError *error) {
      
        if(error)
        {
          NSLog(@"The error in pining all the stuff in the get all the favors method is: %@", error);
        }
        else
        {
          NSLog(@"The data pinned sucessfully in the background %d", succeeded);
          [self.delegate reloadTableWithQueryResults:queryResults];
          
        }
        
      }];
      
    }
    
    else
    {
      NSLog(@"The error is %@", error);
    }

    
  }];
  
 

  
}



@end
