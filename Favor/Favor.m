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
@dynamic imageFile;
@dynamic askOrFavor;
//if you have a problem check this
@dynamic userThatCreatedThisFavor;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Favor";
}



@end
