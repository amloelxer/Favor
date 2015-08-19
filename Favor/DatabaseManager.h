//
//  DatabaseManager.h
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DatabaseManager;
@protocol DatabaseManagerDelegate <NSObject>
- (void) reloadTableWithQueryResults: (DatabaseManager *) sender;
//- (void) logInFailedWithError: (ParseManager *) sender;
@end

@interface DatabaseManager : NSObject

@property (nonatomic, weak) id <DatabaseManagerDelegate> delegate;

@end
