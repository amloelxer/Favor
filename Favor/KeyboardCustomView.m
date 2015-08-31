//
//  CustomView.m
//  KeyboardInput
//
//  Created by Brian Mancini on 10/4/14.
//  Copyright (c) 2014 iOSExamples. All rights reserved.
//

#import "KeyboardCustomView.h"
#import "KeyboardBar.h"

@interface KeyboardCustomView() <KeyboardBarDelegate>

// Override inputAccessoryView to readWrite
@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;
    
@end

@implementation KeyboardCustomView

// Override canBecomeFirstResponder
// to allow this view to be a responder
- (bool) canBecomeFirstResponder {
    return true;
}

// Override inputAccessoryView to use
// an instance of KeyboardBar
- (UIView *)inputAccessoryView {
    if(!_inputAccessoryView) {
        _inputAccessoryView = [[KeyboardBar alloc] initWithDelegate:self];
    }
    return _inputAccessoryView;
}

-(void)keyboardBar:(KeyboardBar *)keyboardBar sendText:(NSString *)text
{
  NSLog(@"Being sent from Keyboard Custom View");
  [self.delegate sendTextToRootController:text];
}

@end
