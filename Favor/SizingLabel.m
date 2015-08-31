//
//  SizingLabel.m
//  Favor
//
//  Created by Alex Moller on 8/31/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "SizingLabel.h"

@implementation SizingLabel

- (void)setBounds:(CGRect)bounds {
  if (bounds.size.width != self.bounds.size.width) {
    [self setNeedsUpdateConstraints];
  }
  [super setBounds:bounds];
}

- (void)updateConstraints {
  if (self.preferredMaxLayoutWidth != self.bounds.size.width) {
    self.preferredMaxLayoutWidth = self.bounds.size.width;
  }
  [super updateConstraints];
}

- (void)layoutSubviews
{
  self.preferredMaxLayoutWidth = self.frame.size.width;
  [super layoutSubviews];
}

@end
