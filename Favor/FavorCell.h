//
//  FavorCells.h
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavorCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *posterName;
@property (weak, nonatomic) IBOutlet UILabel *timePassedSinceFavorWasPosted;
@property (weak, nonatomic) IBOutlet UILabel *numberOfResponses;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromPoster;


@end
