//
//  FacebookLoginModel.h
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse.h>
#import "User.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@class FacebookLoginModel;
@protocol FacebookLoginDelegate <NSObject>   //define delegate protocol
- (void) hasLoggedInSuccessFully: (FacebookLoginModel *) sender;  //define delegate method to be implemented within ano
@end



@interface FacebookLoginModel : NSObject

@property (nonatomic, weak) id <FacebookLoginDelegate> delegate;

-(void)loginWithFacebook;



@end

