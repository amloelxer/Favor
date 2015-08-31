//
//  KeyboardBar.m
//  KeyboardInputView
//
//  Created by Brian Mancini on 10/4/14.
//  Copyright (c) 2014 iOSExamples. All rights reserved.

#import "KeyboardBar.h"
#import "ColorPalette.h"
#import <POP.h>

@implementation KeyboardBar

- (id)initWithDelegate:(id<KeyboardBarDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (id)init {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), 44);
    self = [self initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        self.placeholderText = @"How can you get involved?";
        
        // Default Values
        int cornerRadius = 3;
        float textViewWidth = (frame.size.width - 24) * 0.75;
        float buttonWidth = (frame.size.width - 24 ) * 0.25;
        
        self.backgroundColor = [ColorPalette getFavorPinkRedColor];
        
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(8, 4, textViewWidth, 36)];
        self.textView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        self.textView.layer.cornerRadius = cornerRadius;
        
        self.textView.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];
        self.textView.delegate = self;
        self.textView.text = self.placeholderText;
        self.textView.textColor = [UIColor lightGrayColor];
        
        self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.postButton.frame = CGRectMake((16 + textViewWidth), 4, buttonWidth, 36);
        
        self.postButton.layer.cornerRadius = cornerRadius;
        self.postButton.backgroundColor = [ColorPalette getFavorGreenColor];
        [self.postButton setTitle:@"RESPOND" forState:UIControlStateNormal];
        
        self.postButton.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:14];;
        
        [self.postButton addTarget:self action:@selector(postButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
        // Setup indicator in button
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.indicator = indicator;
        self.indicator.hidesWhenStopped = YES;
        [self.indicator stopAnimating];
        self.indicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.postButton addSubview:self.indicator];
        [self.postButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[indicator]-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(indicator)]
         ];
        [self.postButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[indicator]-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(indicator)]
         ];

        [self addSubview:self.textView];
        [self addSubview:self.postButton];
    }
    return self;
}

-(void)postButtonPressed {
    if (self.textView.text.length > 0) {
        [self submitResponse];
    } else {
        [self declineResponse];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:self.placeholderText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

#pragma mark - Submit Favor
-(void)submitResponse {
    
    // Disable other interactive elements
    self.textView.editable = NO;
    self.textView.selectable = NO;
    
    // Make API Call with following values.
    
    //  Favor *firstFavor = [Favor objectWithClassName:@"Favor"];
    
    // Indicate loading - this should go in a block.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.indicator startAnimating];
    [self animateColorChangeForButton:self.postButton toColor:[UIColor colorWithRed:253.0/255 green:196.0/255 blue:60.0/255 alpha:1.0]];
    self.postButton.enabled = NO;
    [self.postButton setTitle:@"" forState:UIControlStateDisabled];

    [self.delegate keyboardBar:self sendText:self.textView.text];
    NSLog(@"Being sent from KeyboardBar View");
  
}

-(void)animateColorChangeForButton:(UIButton *)button toColor:(UIColor *)newColor {
    POPSpringAnimation *colorAnimation = [POPSpringAnimation animation];
    colorAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewBackgroundColor];
    colorAnimation.springSpeed = 20.0;
    colorAnimation.toValue = (id)newColor.CGColor;
    [button pop_addAnimation:colorAnimation forKey:@"colorAnimation"];
}

-(void)declineResponse {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)declinePost {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = self.placeholderText;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
  
}

@end
