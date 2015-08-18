//
//  Favor.h
//  Favor
//
//  Created by Alex Moller on 8/17/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>
#import "User.h"


@interface Favor : PFObject<PFSubclassing>


@property NSString *text;
@property NSMutableArray *arrayOfResponses;

+ (NSString *)parseClassName;

@end
