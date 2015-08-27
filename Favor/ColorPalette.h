//
//  ColorPalette.h
//  Favor
//
//  Created by Alex Moller on 8/19/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorPalette : NSObject

+ (UIColor *)getFavorRedColor;

+ (UIColor *)getFavorYellowColor;

+ (UIColor *)getFavorGreenColor;

+ (UIColor *)getGreyTextColor;

+ (UIColor *)getGreyTextLessOpaqueColor;

@end
