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
#import <Bolts.h>

@class DatabaseManager;
@protocol DatabaseManagerDelegate <NSObject>
- (void) reloadTableWithQueryResults: (NSArray *) queryResults;
- (void) reloadTableWithCachedQueryResults: (NSArray *) queryResults;
//- (void) logInFailedWithError: (ParseManager *) sender;
@end

@interface DatabaseManager : NSObject

@property (nonatomic, weak) id <DatabaseManagerDelegate> delegate;

typedef NS_ENUM(NSInteger, AskOrOfferFavor) {
  OfferFavor=0,
  AskFavor,
};

- (void)getAllFavorsFromLocalParseStore:(NSInteger)selectedSegment user:(User *)currentUser;

-(void)getAllFavorsFromParse;

+ (NSString *)dateConverter:(NSDate *)passedDate;

@end
