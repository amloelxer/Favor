//
//  LocationManager.h
//  Favor
//
//  Created by Alex Moller on 8/24/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class LocationManager;
@protocol LocationManagerDelegate <NSObject>

@optional
- (void) initialLocationHasBeenRecieved;
//- (void) logInFailedWithError: (ParseManager *) sender;
@end

@interface LocationManager : NSObject 
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, weak) id <LocationManagerDelegate> delegate;
@property CLLocation *currentLocation;

- (void)updateLocation;

+ (instancetype)sharedManager;

@end
