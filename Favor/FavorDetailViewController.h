//
//  FavorDetailViewController.h
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPalette.h"
#import "User.h"
#import "Response.h"
#import "Favor.h"
#import "User.h"
#import "ResponseCell.h"
#import "KeyboardCustomView.h"
#import "KeyboardBar.h"

typedef NS_ENUM(NSInteger, FavorStates) {
  FavorStateOpen =0,
  FavorStateClosed,
};

@interface FavorDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property NSString *passedFavorText;
@property NSString *passedTimeText;
@property NSString *passedSelectedFavorPosterName;
@property User *passedUserThatMadeTheFavor;
@property NSString *passedFavorID;
@property NSNumber *passedFavorState;
@property NSString *passedDistanceFromCurrentLocation;

@property UIImage *profImage;
@end
