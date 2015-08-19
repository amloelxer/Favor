//
//  ColorPalette.m
//  Favor
//
//  Created by Alex Moller on 8/19/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "ColorPalette.h"

@implementation ColorPalette

+ (UIColor *)getFavorRedColor
{
  UIColor *favorRedColor = [UIColor colorWithRed:251.0f/255.0f
                                         green:67.0f/255.0f
                                          blue:48.0f/255.0f
                                         alpha:1.0f];
  
  return favorRedColor;
}

+ (UIColor *)getFavorYellowColor
{
  UIColor *favorYellowColor = [UIColor colorWithRed:252.0f/255.0f
                                           green:198.0f/255.0f
                                            blue:2.0f/255.0f
                                           alpha:1.0f];
  return favorYellowColor;

}

+ (UIColor *)getFavorGreenColor
{
  UIColor *favorGreenColor = [UIColor colorWithRed:86.0f/255.0f
                                              green:209.0f/255.0f
                                               blue:142.0f/255.0f
                                              alpha:1.0f];
  return favorGreenColor;
}


@end
