//
//  DatabaseManager.h
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
#import <Parse.h>
#import "User.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Favor.h"

@class DatabaseManager;
@protocol DatabaseManagerDelegate <NSObject>
- (void) reloadTableWithQueryResults: (NSArray *) queryResults;
//- (void) logInFailedWithError: (ParseManager *) sender;
@end

@interface DatabaseManager : NSObject

@property (nonatomic, weak) id <DatabaseManagerDelegate> delegate;

- (void)getFavorsFromParseDataBase:(User *)passedUser asksOrOffer:(NSInteger)asksOrOffers;




@end
