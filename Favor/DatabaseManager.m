//
//  DatabaseManager.m
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "DatabaseManager.h"


@implementation DatabaseManager

-(NSString *)dateConverter:(NSDate *)passedDate
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


- (void)getFavorsFromParseDataBase:(User *)passedUser asksOrOffer:(NSInteger)asksOrOffers
{
  
  NSMutableArray *queryResults = [[NSMutableArray alloc]init];
  
  PFQuery *postQueryForUser = [PFQuery queryWithClassName:@"Favor"];
  
  [postQueryForUser includeKey:@"CreatedBy"];
  
  
  if(passedUser!= nil)
  {
    [postQueryForUser whereKey:@"CreatedBy" equalTo:passedUser];
    
  }
  
  else if(asksOrOffers == 0)
  {
    //query for asks
    [postQueryForUser whereKey:@"askOrOffer" equalTo:@(NO)];
  }
  
  else
  {
    //query for offers
    [postQueryForUser whereKey:@"askOrOffer" equalTo:@(YES)];
  }
  
  
  [postQueryForUser addDescendingOrder:@"updatedAt"];
  
  
  [postQueryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    if(!error)
    {
      for(PFObject *favor in objects)
      {
        
        Favor *tempFavor = [[Favor alloc]init];
        
        tempFavor.text = [favor objectForKey:@"text"];
        
        NSDate *favorTimeUpdatedAt = favor.updatedAt;
        
        NSString *stringFavorWasPosted = [self dateConverter:favorTimeUpdatedAt];
        
        tempFavor.timePosted = stringFavorWasPosted;
        
        PFObject *user = [favor objectForKey:@"CreatedBy"];
        
          if(passedUser!= nil)
          {
            tempFavor.posterName = passedUser[@"name"];
            PFFile *profPictureFile = passedUser[@"ProfilePicture"];
            tempFavor.imageFile = profPictureFile;
          }
        
          else
          {
            tempFavor.posterName = [user objectForKey:@"name"];
            PFFile *imageFile = [user objectForKey:@"ProfilePicture"];
            tempFavor.imageFile = imageFile;
          }
        
        [queryResults addObject:tempFavor];
        
       }
      
      [self.delegate reloadTableWithQueryResults:queryResults];
      
    }
    
  }];
  

}




@end
