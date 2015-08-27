//
//  Favor.h
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>
#import "User.h"




@interface Favor : PFObject<PFSubclassing>

typedef NS_ENUM(NSInteger, FavorType) {
  FavorTypeOffer = 0,
  FavorTypeAsk,
};

@property FavorType favorType;


@property NSString *text;

@property NSNumber *numberOfResponses;

@property NSString *timePosted;

@property NSString *posterName;

@property PFFile *imageFile;

@property BOOL askOrOffer;

@property User *CreatedBy;

@property NSString *uniqueID;

@property NSNumber *currentState;

@property NSString *distanceAwayFromCL;



+ (NSString *)parseClassName;

@end
