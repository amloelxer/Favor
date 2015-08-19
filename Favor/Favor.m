//
//  Favor.m
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "Favor.h"

@implementation Favor

@dynamic favorType;
@dynamic text;
@dynamic arrayOfResponses;
@dynamic timePosted;
@dynamic posterName;
@dynamic userImage;


+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Favor";
}



@end
