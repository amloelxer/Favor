//
//  StringModifier.m
//  Favor
//
//  Created by Alex Moller on 8/31/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import "StringModifier.h"

@implementation StringModifier

+ (NSString *)getFirstNameFromFullName:(NSString *)fullName
{
  NSArray *arrayOfFirstAndLastName = [fullName componentsSeparatedByString:@" "];
  
  NSString *firstName = [arrayOfFirstAndLastName firstObject];
  
  return firstName;
}


@end
