//
//  CustomView.h
//  KeyboardInput
//
//  Created by Brian Mancini on 10/4/14.
//  Copyright (c) 2014 iOSExamples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardBar.h"

@class KeyboardCustomView;

@protocol KeyboardCustomViewDelegate <NSObject>


-(void)sendTextToRootController:(NSString *)text;

@end


@interface KeyboardCustomView : UIView

@property (weak, nonatomic) id<KeyboardCustomViewDelegate> delegate;
//this delegate is being stored to preserve the relationship between keyboard Custom View and Keyboard Bar
@property (weak, nonatomic) id<KeyboardBarDelegate> keyboardBarDelegate;

@end
