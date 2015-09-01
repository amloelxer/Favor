//
//  Response.h
//  Favor
//
//  Created by Alex Moller on 8/22/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Favor.h"
#import <Parse.h>

@interface Response : PFObject<PFSubclassing>

@property NSString *responseCreatorName;
@property NSString *responseCreatorProfileImage;
@property NSString *timeAgo;
@property NSString *phoneNumber;
@property NSString *responseText;
@property PFFile *profPicFile;
@property User *userWhoMadeThisResponse;
@property Favor *favorThisResponseIsOn;
@property NSString *uniqueID;
@property NSString *distanceAway;

@property NSNumber *wasChosen;



+ (NSString *)parseClassName;

@end
