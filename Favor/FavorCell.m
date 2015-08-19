//
//  FavorCells.m
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "FavorCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FavorCell

-(void)makeImageViewCircular
{
  self.imageView.layer.cornerRadius = self.imageView.image.size.width / 2;
  self.imageView.layer.masksToBounds = YES;
}

@end
