//
//  ResponseCell.m
//  Favor
//
//  Created by Alex Moller on 8/21/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import "ResponseCell.h"

@implementation ResponseCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)chosenButtonWasPressed:(UIButton *)sender {
  
  NSLog(@"Button Was Chosen");
  [self.delegate chosenButtonOnCellWasPressed:self];
  
}




@end
