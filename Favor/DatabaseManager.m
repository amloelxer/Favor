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

/*This method sorts all the cached Favors based on the segment
 controller value in FavorFeedView and calls the delegate method
 reloadTableWithCachedQueryResults with the sorted array of comments */

#pragma Favor Methods
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
    [query whereKey:@"askOrOffer" equalTo:[NSNumber numberWithBool:NO]];
  }
  
  //it's an ask so it's 1 for yes
  else if(selectedSegment == 1)
  {
    [query whereKey:@"askOrOffer" equalTo:[NSNumber numberWithBool:YES]];
  }
  
  else
  {
    [query whereKey:@"CreatedBy" equalTo:currentUser];
  }
  
  
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    for(Favor *favor in objects)
    {
      
      [queryResults addObject:favor];
      
    }
            
    [self.delegate reloadTableWithCachedQueryResults:queryResults];
    
  }];

}

-(void)submitFavorToParse:(NSString *)text askOrOffer:(NSInteger)askOrOffer vc:(FavorFeedViewController *)favorFeedVC
{
  Favor *firstFavor = [Favor objectWithClassName:@"Favor"];
  Favor *favorToPin = [[Favor alloc]init];
  
  [firstFavor setObject:text forKey:@"text"];
  favorToPin.text = text;
  
  //offer is 0 so it is false
  if(askOrOffer == 0)
  {
    [firstFavor setObject:@(NO) forKey:@"askOrOffer"];
    favorToPin.askOrOffer = NO;
    
  }
  //else it's an ask which is true so 1
  else
  {
    [firstFavor setObject:@(YES) forKey:@"askOrOffer"];
    favorToPin.askOrOffer = YES;
    
  }
  
  firstFavor[@"CreatedBy"] = favorFeedVC.currentUser;
  firstFavor[@"numOfResponses"] = @(0);
  firstFavor[@"currentState"] = @(0);
  
  //  firstFavor[@"timePosted"] = [DatabaseManager dateConverter:firstFavor.createdAt];
  firstFavor[@"posterName"] = [favorFeedVC.currentUser objectForKey:@"name"];
  firstFavor[@"imageFile"] =  favorToPin.imageFile = [favorFeedVC.currentUser objectForKey:@"ProfilePicture"];
  
  
  LocationManager *currentLocationManager = [LocationManager sharedManager];
  
  PFGeoPoint *currentLocation = [PFGeoPoint geoPointWithLocation:currentLocationManager.currentLocation];
  
  firstFavor[@"locationOfFavor"] = currentLocation;
  
  favorToPin.CreatedBy = favorFeedVC.currentUser;
  favorToPin.imageFile = [favorFeedVC.currentUser objectForKey:@"ProfilePicture"];
  favorToPin.posterName = [favorFeedVC.currentUser objectForKey:@"name"];
  favorToPin.timePosted = [DatabaseManager dateConverter:firstFavor.createdAt];
  favorToPin.currentState = @(0);
  
  [favorToPin pinInBackground];
  
  [firstFavor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if (!error)
    {
//      PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//      [currentInstallation addObject:firstFavor.uniqueID forKey:@"channels"];
//      [currentInstallation saveInBackground];
//      
      [self.delegate isDoneWithSavingFavor];
    }
    else
    {
      NSLog(@"The error is: %@", error);
    }
    
  }];

  
  
  
  
}

/* Gets all the favors from the parse servers and pins
 them locally to the cache */
-(void)getAllFavorsFromParse:(double)withSelectedRadius;
{
  
  NSMutableArray *queryResults = [[NSMutableArray alloc]init];
  
  PFQuery *postQueryForUser = [PFQuery queryWithClassName:@"Favor"];
  
  LocationManager *singletonManager = [LocationManager sharedManager];
  
  [postQueryForUser addDescendingOrder:@"updatedAt"];
  PFGeoPoint *currentGeoPoint = [PFGeoPoint geoPointWithLocation:singletonManager.currentLocation];
  //gotta have this line. So So So So So So important
  [postQueryForUser includeKey:@"CreatedBy"];
  [postQueryForUser includeKey:@"objectID"];
  [postQueryForUser whereKey:@"locationOfFavor" nearGeoPoint:currentGeoPoint withinMiles:withSelectedRadius];
  [postQueryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    if(!error)
    {
      for(Favor *someFavor in objects)
      {
        
        Favor *tempFavor = [Favor new];
        PFGeoPoint *locationOfFavor = someFavor[@"locationOfFavor"];
        
        double distanceInMilesFromCurrentLocation = [locationOfFavor distanceInMilesTo:currentGeoPoint];
        
        NSInteger distanceInMilesWithNoDecimals = (NSInteger)distanceInMilesFromCurrentLocation;
        
        NSString *distanceAwayFromCurrentLocation = [NSString stringWithFormat:@"%ld miles away", (long)distanceInMilesWithNoDecimals];
        
        tempFavor.distanceAwayFromCL = distanceAwayFromCurrentLocation;
  
        tempFavor.text = [someFavor objectForKey:@"text"];
        tempFavor.uniqueID = someFavor.objectId;
        //must cast on the other side from type ID to boolValue
        //I was getting the pointer to the object and not the actual value
        //this is very very important
        BOOL thisAskOrOffer = [someFavor[@"askOrOffer"]boolValue];
        
        tempFavor.askOrOffer = thisAskOrOffer;
        
        NSDate *favorTimeUpdatedAt = someFavor.updatedAt;
        
        NSString *stringFavorWasPosted = [DatabaseManager dateConverter:favorTimeUpdatedAt];
        
        tempFavor.timePosted = stringFavorWasPosted;
        
        tempFavor.numberOfResponses = someFavor[@"numOfResponses"];
        
        tempFavor.currentState = someFavor[@"currentState"];
        
        tempFavor.CreatedBy = [someFavor objectForKey:@"CreatedBy"];
        
        User *user = [someFavor objectForKey:@"CreatedBy"];
        
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


#pragma mark - Response Methods

-(void)saveResponse:(NSString *)responseText passedFavorID:(NSString*)passedFavorID
{
  
  Response *newResponse = [Response objectWithClassName:@"Response"];
  [newResponse setObject:responseText forKey:@"responseText"];
  [newResponse setObject:[User currentUser] forKey:@"userWhoMadeTheResponse"];
  
  NSNumber *defaultWasChosenIsNo = [NSNumber numberWithInt:0];
  [newResponse setObject:defaultWasChosenIsNo forKey:@"wasChosen"];
  
  PFQuery *query = [PFQuery queryWithClassName:@"Favor"];
  [query getObjectInBackgroundWithId:passedFavorID block:^(PFObject *someFavor, NSError *error) {
    
    [newResponse setObject:someFavor forKey:@"favorWhichResponseIsOn"];
    
    NSNumber *numOfResponses = someFavor[@"numOfResponses"];
    
    NSNumber *newNumber = [NSNumber numberWithInt:[numOfResponses intValue] + 1];
    
    someFavor[@"numOfResponses"] = newNumber;
    
    [newResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      
      if (!error)
      {
        NSLog(@"The new response was saved sucessfully");
        [self.delegate isDoneSavingResponse];
      }
      else
      {
        NSLog(@"The error is: %@", error);
      }
      
    }];
    
    
  }];

}




-(void)getResponseForSelectedFavor:(NSString *)selectedFavorID
{
  
  NSMutableArray *queryResults = [[NSMutableArray alloc]init];
  
  PFQuery *responseQueryForFavor = [PFQuery queryWithClassName:@"Response"];
  
  PFQuery *query = [PFQuery queryWithClassName:@"Favor"];
  
  [query getObjectInBackgroundWithId:selectedFavorID block:^(PFObject *someFavor, NSError *error) {
    
    [responseQueryForFavor whereKey:@"favorWhichResponseIsOn" equalTo:(Favor *)someFavor];
    
    [responseQueryForFavor findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      if (!error)
      {
        //change for consistency later?
        for (int i=0; i<objects.count; i++)
        {
          Response *someResponse = objects[i];
          
          Response *responseToBeAdded = [Response new];
          responseToBeAdded.responseText = someResponse.responseText;
          User *responseCreator = [someResponse objectForKey:@"userWhoMadeTheResponse"];
          responseToBeAdded.responseCreatorName = [responseCreator objectForKey:@"name"];
          responseToBeAdded.userWhoMadeThisResponse = [someResponse objectForKey:@"userWhoMadeTheResponse"];
          responseToBeAdded.favorThisResponseIsOn = [someResponse objectForKey:@"favorWhichResponseIsOn"];
          responseToBeAdded.uniqueID = someResponse.objectId;
          responseToBeAdded.wasChosen = [someResponse objectForKey:@"wasChosen"];
          PFFile *imageFile = [responseCreator objectForKey:@"ProfilePicture"];
          responseToBeAdded.profPicFile = imageFile;
          
          [queryResults addObject:responseToBeAdded];
          
        }
        
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        NSInteger j;
        //to put the comments we want at the stop
        Response *chosenResponse;
        for(int i=0; i<queryResults.count; i++)
        {
          Response *tempResponse  = queryResults[i];
          if([tempResponse.wasChosen intValue] ==1)
          {
            chosenResponse = queryResults[i];
            j=i;
          }
        }
        
        if(chosenResponse != nil)
        {
          [queryResults removeObjectAtIndex:j];
          [queryResults insertObject:chosenResponse atIndex:0];
        }
        
        [self.delegate reloadTableWithResponses:queryResults];
        
      }
      else
      {
        // Log details of the failure
        NSLog(@"Error: %@ %@", error, [error userInfo]);
      }
    }];

    
  }];
  
}




@end
