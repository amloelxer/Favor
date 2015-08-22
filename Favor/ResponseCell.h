//
//  ResponseCell.h
//  Favor
//
//  Created by Alex Moller on 8/21/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Favor.h"
#import "User.h"

@interface ResponseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *responseProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *responderName;

@end
