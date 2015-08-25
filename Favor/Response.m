//
//  Response.m
//  Favor
//
//  Created by Alex Moller on 8/22/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import "Response.h"

@implementation Response

@dynamic responseCreatorName;
@dynamic responseCreatorProfileImage;
@dynamic timeAgo;
@dynamic phoneNumber;
@dynamic responseText;
@dynamic profPicFile;
@dynamic userWhoMadeThisResponse;
@dynamic favorThisResponseIsOn;


+ (NSString *)parseClassName
{
  return @"Response";
}

+ (void)load
{
  [self registerSubclass];
}

@end
