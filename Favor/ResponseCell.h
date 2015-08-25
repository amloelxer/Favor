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

@class ResponseCell;
@protocol ResponseCellDelegate <NSObject>
- (void) chosenButtonOnCellWasPressed:(ResponseCell *)chosenResponseCell;
@end

@interface ResponseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *responseProfilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *responderName;
@property (weak, nonatomic) IBOutlet UIButton *chosenButton;
@property (weak, nonatomic) IBOutlet UILabel *responderText;

@property (nonatomic, weak) id <ResponseCellDelegate> delegate;
@end
