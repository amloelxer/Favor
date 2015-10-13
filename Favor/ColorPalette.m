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
  UIColor *favorYellowColor = [UIColor colorWithRed:249.0f/255.0f
                                           green:219.0f/255.0f
                                            blue:14.0f/255.0f
                                           alpha:1.0f];
  return favorYellowColor;

}

+ (UIColor *)getFavorGreenColor
{
  UIColor *favorGreenColor = [UIColor colorWithRed:86.0f/255.0f
                                              green:215.0f/255.0f
                                               blue:142.0f/255.0f
                                              alpha:1.0f];
  return favorGreenColor;
}

+ (UIColor *)getGreyTextColor
{
  UIColor *greyTextColor = [UIColor colorWithRed:30.0f/255.0f
                                             green:30.0f/255.0f
                                              blue:30.0f/255.0f
                                             alpha:1.0f];
  return greyTextColor;

}

+ (UIColor *)getGreyTextLessOpaqueColor
{
  UIColor *greyTextColor = [UIColor colorWithRed:30.0f/255.0f
                                           green:30.0f/255.0f
                                            blue:30.0f/255.0f
                                           alpha:0.5f];
  return greyTextColor;
  
}

+ (UIColor *)getFavorPinkRedColor
{
  UIColor *favorPinkRed = [UIColor colorWithRed:243.0f/255.0f
                                           green:44.0f/255.0f
                                            blue:104.0f/255.0f
                                           alpha:1.0f];
  return favorPinkRed;

}


@end
