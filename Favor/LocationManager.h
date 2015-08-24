//
//  LocationManager.h
//  Favor
//
//  Created by Alex Moller on 8/24/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject 
@property (strong, nonatomic) CLLocationManager *locationManager;
@property CLLocation *currentLocation;

+ (instancetype)sharedManager;

@end
