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
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  
  NSString *stringFromDate = [formatter stringFromDate:passedDate];
  
  
  return stringFromDate;
  
}

- (void)getAskedFavors
{
  
  
}

- (void)getOfferedFavors
{
  
}



- (void)getMyFavors:(User *)passedUser
{
  
    NSMutableArray *queryResults = [[NSMutableArray alloc]init];
  
    PFQuery *postQueryForUser = [PFQuery queryWithClassName:@"Favor"];
  
    [postQueryForUser whereKey:@"CreatedBy" equalTo:passedUser];
  
    [postQueryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      if(!error)
      {
        for(PFObject *o in objects)
        {
        
          Favor *tempFavor = [[Favor alloc]init];
          
          tempFavor.text = [o objectForKey:@"text"];
          
          NSDate *favorTimeUpdatedAt = o.updatedAt;
          
          NSString *stringFavorWasPosted = [self dateConverter:favorTimeUpdatedAt];
        
          tempFavor.timePosted = stringFavorWasPosted;

          tempFavor.posterName = passedUser[@"name"];
          
          PFFile *profPictureFile = passedUser[@"ProfilePicture"];
          
          tempFavor.imageFile = profPictureFile;
//          [profPictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            if (!error) {
//              UIImage *image = [UIImage imageWithData:data];
//              tempFavor.userImage = image;
          
//            }
//          }];
          
          [queryResults addObject:tempFavor];
          
          
        }
        
        [self.delegate reloadTableWithQueryResults:queryResults];
        
      }
    }];
}


@end
