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
  self.chosenButton.backgroundColor = [ColorPalette getFavorGreenColor];
  self.chosenButton.titleLabel.text = @" Choose ";
  self.chosenButton.tintColor = [UIColor whiteColor];
  self.chosenButton.layer.cornerRadius = 2.0;
  self.chosenButton.layer.masksToBounds = YES;
  
  [self.chosenButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:16]];

 
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
