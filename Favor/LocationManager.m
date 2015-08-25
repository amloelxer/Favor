//
//  LocationManager.m
//  Favor
//
//  Created by Alex Moller on 8/24/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate>
//written so you don't get multiple locations from multiple threads
@property BOOL hasGottenOneLocation;
@end

@implementation LocationManager

//make this bad boy a singleton
+ (instancetype)sharedManager {
  static LocationManager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}


-(instancetype)init
{
  if (self)
  {
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.hasGottenOneLocation = NO;
    [self.locationManager startUpdatingLocation];
  }
  
  return self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  
  if(self.hasGottenOneLocation == NO)
  {
    [self.locationManager stopUpdatingLocation];
    self.currentLocation = [locations lastObject];
    NSLog(@"The First Location has been updated");
    [self.delegate initialLocationHasBeenRecieved];
    self.hasGottenOneLocation = YES;
  }
  else
  {
    NSLog(@"Sending more stuff but I don't want it ");
  }

  
}

@end
