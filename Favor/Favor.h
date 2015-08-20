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
@property NSMutableArray *arrayOfResponses;

@property NSString *timePosted;

@property UIImage *userImage;

@property NSString *posterName;

@property PFFile *imageFile;

@property BOOL askOrFavor;

@property User *userThatCreatedThisFavor;



+ (NSString *)parseClassName;

@end
