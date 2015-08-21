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

@interface FavorDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property NSString *passedFavorText;
@property NSString *passedTimeText;
@property NSString *passedSelectedFavorPosterName;
@property User *passedUserThatMadeTheFavor;

@property UIImage *profImage;
@end
