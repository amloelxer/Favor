//
//  ModalViewController.m
//  favorModalCreatePost
//
//  Created by Cassidy Clawson on 8/17/15.
//  Copyright (c) 2015 Cassidy Clawson. All rights reserved.
//

#import "ModalViewController.h"

@interface ModalViewController()

@property (nonatomic, strong) FavorFeedViewController *backgroundVC;
@property (nonatomic, strong) UIView *backgroundBlurView;
@property (nonatomic, strong) UIView *modalView;
@property (nonatomic) CGPoint modalViewOffscreenCenter;
@property (nonatomic) CGPoint modalViewOnscreenCenter;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *postFavorButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UITextView *favorTextView;
@property (nonatomic, strong) UILabel *favorPlaceholderLabel;

@property (nonatomic, strong) UILabel *offerLabel;
@property (nonatomic, strong) UILabel *askLabel;

@property (nonatomic, strong) UIView *magicLine;
@property (nonatomic) CGPoint offerMagicLineCenter;
@property (nonatomic) CGPoint askMagicLineCenter;
@property (nonatomic) NSInteger offerOrAsk; //Offer = 0, ask = 1
@property DatabaseManager *parseManager;

@end


@implementation ModalViewController


-(instancetype)initWithBackgroundViewController:(FavorFeedViewController *)backgroundVC {
    self = [super init];
    if (self) {
        _backgroundVC = backgroundVC;
        _delegate = backgroundVC;
    }
    return self;
}

#pragma mark - Database Manager Delegate Method


-(void)viewWillAppear:(BOOL)animated {
    [self captureBackgroundBlurImage];
    [self showCoordinator];
    self.parseManager = [[DatabaseManager alloc]init];
//    self.parseManager.delegate = self;
  
   self.offerOrAsk = 0;
}

-(void)viewDidLoad {
    [self setupModalView];
    // Defaults to offer on load.

    
    // Preload the keyboard
    [self.favorTextView becomeFirstResponder];
    [self.favorTextView resignFirstResponder];
  
}

-(void)showCoordinator {
    [self showBackgroundBlurImage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self moveModalViewTo:self.modalViewOnscreenCenter];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self moveModalViewTo:self.modalViewOnscreenCenter];
        [self.favorTextView becomeFirstResponder];
    });

}

-(void)hideCoordinator {
    // Ensure network status not left on from post
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self moveModalViewTo:self.modalViewOffscreenCenter];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [self hideBackgroundBlurImage];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destroySelf];
    });
}

-(void)setupModalView {
    // Modal View Initializer
    CGRect modalRect = CGRectMake(0, 0, self.view.frame.size.width - 32, self.view.frame.size.height / 2.5);
    UIView *modalView = [[UIView alloc] initWithFrame:modalRect];
    
    // Modal View Basic Styling
    modalView.backgroundColor = [UIColor whiteColor];
    modalView.layer.cornerRadius = 3;
    
    // Drop Shadow
    [modalView.layer setShadowColor:[UIColor blackColor].CGColor];
    modalView.layer.shadowOffset = CGSizeMake(0,0);
    modalView.layer.shadowRadius = 16;
    modalView.layer.shadowOpacity = 0.1;
    
    // Modal View Positions
    self.modalViewOffscreenCenter = CGPointMake(self.view.center.x, modalView.frame.size.height * -1);
    self.modalViewOnscreenCenter = CGPointMake(self.view.center.x, self.view.center.y - 100);
    modalView.center = self.modalViewOffscreenCenter;
    
    // Setup Close Button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitle:@"" forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"close_button"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(modalView.frame.size.width - 36, 16, 20, 20);
    [closeButton sizeToFit];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [modalView addSubview:closeButton];
    self.closeButton = closeButton;
    
    // Setup Text Field
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:20];
    int textFieldY = modalRect.size.height / 4;
    CGRect textFieldRect = CGRectMake(16, textFieldY, modalView.frame.size.width - 32, modalRect.size.height / 2);
    UITextView *textView = [[UITextView alloc] initWithFrame:textFieldRect];
    textView.font = font;
    [textView setTextColor:[UIColor colorWithRed:75.0/255 green:82.0/255 blue:88.0/255 alpha:1.0]];
    textView.delegate = self;
    [textView setScrollEnabled:NO];
    
    self.favorTextView = textView;
    [modalView addSubview:self.favorTextView];

    // Create placeholder text label
    CGRect placeholderFieldRect = CGRectMake(16, textFieldY, modalView.frame.size.width - 32, modalRect.size.height / 7);
    UILabel *favorPlaceholderLabel = [[UILabel alloc] initWithFrame:placeholderFieldRect];
    favorPlaceholderLabel.font = font;
    favorPlaceholderLabel.alpha = 0.3f;
    favorPlaceholderLabel.text = @" How can you help?";
    favorPlaceholderLabel.font = font;
    
    self.favorPlaceholderLabel = favorPlaceholderLabel;
    [modalView addSubview:self.favorPlaceholderLabel];
    
    // Create Favor Type Labels
    UIFont *labelFont = [UIFont fontWithName:@"Helvetica-Bold" size:24];

    UILabel *offerLabel = [[UILabel alloc] init];
    UILabel *askLabel = [[UILabel alloc] init];

    offerLabel.text = @"Offer";
    askLabel.text = @"Ask";
    
    UIColor *dark = [UIColor colorWithRed:75.0/255 green:82.0/255 blue:88.0/255 alpha:1.0];
    
    offerLabel.textColor = dark;
    askLabel.textColor = dark;
    
    offerLabel.font = labelFont;
    askLabel.font = labelFont;
    
    [offerLabel sizeToFit];
    [askLabel sizeToFit];
    
    offerLabel.center = CGPointMake(modalView.frame.size.width / 3, 28);
    askLabel.center = CGPointMake((modalView.frame.size.width / 3) * 2, 28);
    
    self.offerLabel = offerLabel;
    self.askLabel = askLabel;
    
    [modalView addSubview:offerLabel];
    [modalView addSubview:askLabel];
    
    // Add Touch Gestures to Favor Labels
    
    UITapGestureRecognizer *offerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(offerTapped)];
    offerTapGesture.numberOfTapsRequired = 1;
    [self.offerLabel addGestureRecognizer:offerTapGesture];
    self.offerLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *askTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(askTapped)];
    offerTapGesture.numberOfTapsRequired = 1;
    [self.askLabel addGestureRecognizer:askTapGesture];
    self.askLabel.userInteractionEnabled = YES;
    
    // Create Favor Type Magic Line
    UIView *magicLine  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.offerLabel.frame.size.width, 4)];
    magicLine.backgroundColor = [UIColor colorWithRed:253.0/255 green:65.0/255 blue:58.0/255 alpha:1.0];
    magicLine.layer.cornerRadius = 2;

    self.offerMagicLineCenter = CGPointMake(self.offerLabel.center.x, self.offerLabel.center.y + 14);
    self.askMagicLineCenter = CGPointMake(self.askLabel.center.x, self.offerLabel.center.y + 14);

    self.magicLine = magicLine;
    [modalView addSubview:self.magicLine];
    [self.magicLine setCenter:self.offerMagicLineCenter];

    // Post Favor Button
    [self setupPostFavorButton:self.postFavorButton forView:modalView];
    
    // Setup Modal View
    self.modalView = modalView;
    [self.view addSubview:modalView];
}

-(void)setupPostFavorButton:(UIButton *)button forView:(UIView *)view {
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"POST FAVOR" forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor colorWithRed:80.0/255 green:211.0/255 blue:161.0/255 alpha:1.0];
    UIFont *buttonFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    button.titleLabel.font = buttonFont;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(postButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    
    [view addSubview:button];
    self.postFavorButton = button;
    
    // Setup constraints
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(105)-[button]-(105)-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(button)]
    ];
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[button(44)]-(16)-|"
                                                                 options:0
                                                                 metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(button)]
    ];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [button addSubview:indicator];
    
    [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[indicator]-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(indicator)]
     ];
    
    [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[indicator]-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(indicator)]
     ];
    self.indicator = indicator;
}


#pragma mark - Hide Placeholder Label (favorTextView Delegate Methods)

- (void)textViewDidChange:(UITextView *)txtView
{
    self.favorPlaceholderLabel.hidden = ([txtView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)txtView
{
    self.favorPlaceholderLabel.hidden = ([txtView.text length] > 0);
}

#pragma mark - Magic Line Methods 

-(void)askTapped {
    self.offerOrAsk = 1;
    [self animateMagicLineToCenterPoint:self.askMagicLineCenter toWidth:self.askLabel.frame.size];
    [self animateFavorPlaceholderText:@" What do you need?"];
}

-(void)offerTapped {
    self.offerOrAsk = 0;
    [self animateMagicLineToCenterPoint:self.offerMagicLineCenter toWidth:self.offerLabel.frame.size];
    [self animateFavorPlaceholderText:@" How can you help?"];
}

-(void)animateMagicLineToCenterPoint:(CGPoint)point toWidth:(CGSize)size {
    POPSpringAnimation *centerMove = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    centerMove.toValue = [NSValue valueWithCGPoint:point];
    [self.magicLine pop_addAnimation:centerMove forKey:@"centerMove"];
    
    POPBasicAnimation *lengthResize = [POPBasicAnimation animationWithPropertyNamed:@"size"];
    CGSize newSize = CGSizeMake(size.width, 4);
    lengthResize.toValue = [NSValue valueWithCGSize:newSize];
    [self.magicLine pop_addAnimation:lengthResize forKey:@"lengthResize"];
}

-(void)animateFavorPlaceholderText:(NSString *)newString {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.1;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.favorPlaceholderLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    self.favorPlaceholderLabel.text = newString;
}


-(void)moveModalViewTo:(CGPoint)location {
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    animation.toValue = [NSValue valueWithCGPoint:location];
    [self.modalView pop_addAnimation:animation forKey:@"moveOnScreen"];
}

#pragma mark - User Input

- (void)closeButtonPressed:(UIButton *)button {
    [self hideCoordinator];
    [self.delegate ModalViewControllerDidCancel:self];
}

-(void)postButtonPressed:(UIButton *)button {
    if (self.favorTextView.text.length > 0) {
        [self submitFavor];
    } else {
        [self declinePost];
    }
}


-(void)saveDataToParseAndDismiss
{
  Favor *firstFavor = [Favor objectWithClassName:@"Favor"];
  Favor *favorToPin = [[Favor alloc]init];
  
  [firstFavor setObject:self.favorTextView.text forKey:@"text"];
  favorToPin.text = self.favorTextView.text;
  
  //offer is 0 so it is false
  if(self.offerOrAsk == 0)
  {
    [firstFavor setObject:@(NO) forKey:@"askOrOffer"];
     favorToPin.askOrFavor = NO;
    
  }
  //else it's an ask which is true so 1
  else
  {
    [firstFavor setObject:@(YES) forKey:@"askOrOffer"];
    favorToPin.askOrFavor = YES;
    
  }
      
  firstFavor[@"CreatedBy"] = self.backgroundVC.currentUser;
  favorToPin.userThatCreatedThisFavor = self.backgroundVC.currentUser;
  favorToPin.imageFile = [self.backgroundVC.currentUser objectForKey:@"ProfilePicture"];
  favorToPin.posterName = [self.backgroundVC.currentUser objectForKey:@"name"];
  favorToPin.timePosted = [DatabaseManager dateConverter:firstFavor.createdAt];
  
  
  [favorToPin pinInBackground];
  
  [firstFavor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
        if (!error)
        {
          [self.delegate ModalViewControllerDidSubmitFavor:self askOrOffer:self.offerOrAsk];
          
          [self hideCoordinator];
        }
        else
        {
          NSLog(@"The error is: %@", error);
        }
        
      }];

}

#pragma mark - Submit Favor
-(void)submitFavor {
    
    // Disable other interactive elements
    self.favorTextView.editable = NO;
    self.favorTextView.selectable = NO;
    self.offerLabel.userInteractionEnabled = NO;
    self.askLabel.userInteractionEnabled = NO;
    self.closeButton.hidden = YES;
    
    // Make API Call with following values.
    NSLog(@"Favor Text: %@", self.favorTextView.text);
    NSLog(@"Favor Type: %li", self.offerOrAsk);
  
//  Favor *firstFavor = [Favor objectWithClassName:@"Favor"];
  
    [self saveDataToParseAndDismiss];
  
    // Indicate loading - this should go in a block.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.indicator startAnimating];
    [self animateColorChangeForButton:self.postFavorButton toColor:[UIColor colorWithRed:253.0/255 green:196.0/255 blue:60.0/255 alpha:1.0]];
    self.postFavorButton.enabled = NO;
    [self.postFavorButton setTitle:@"" forState:UIControlStateDisabled];
    
  
}

-(void)declinePost {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)animateColorChangeForButton:(UIButton *)button toColor:(UIColor *)newColor {
    POPSpringAnimation *colorAnimation = [POPSpringAnimation animation];
    colorAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewBackgroundColor];
    colorAnimation.springSpeed = 20.0;
    colorAnimation.toValue = (id)newColor.CGColor;
    [button pop_addAnimation:colorAnimation forKey:@"colorAnimation"];
}

-(void)destroySelf {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Blur Background

-(void)captureBackgroundBlurImage {
    UIScreen *screen = [UIScreen mainScreen];
    UIGraphicsBeginImageContextWithOptions(self.backgroundVC.view.frame.size, YES, screen.scale);
    
    CGRect screenRect = CGRectMake(0, 0, self.backgroundVC.view.frame.size.width, self.backgroundVC.view.frame.size.height);
    [self.backgroundVC.view drawViewHierarchyInRect:screenRect afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIImage *backgroundBlurImage = [UIImageEffects imageByApplyingLightEffectToImage:snapshot];
    UIImageView *backgroundBlurImageView = [[UIImageView alloc] initWithImage:backgroundBlurImage];
    
    self.backgroundBlurView = [[UIView alloc] initWithFrame:screenRect];
    [self.backgroundBlurView addSubview:backgroundBlurImageView];
    
    UIGraphicsEndImageContext();
}

-(void)showBackgroundBlurImage {
    [self.backgroundBlurView setAlpha:0.0f];
    [self.backgroundVC.view addSubview:self.backgroundBlurView];
    [UIView animateWithDuration:0.2f animations:^() {
        self.backgroundBlurView.alpha = 1.0f;
    }];
}

-(void)hideBackgroundBlurImage {
    [self.backgroundBlurView setAlpha:1.0f];
    [self.backgroundVC.view addSubview:self.backgroundBlurView];
    [UIView animateWithDuration:0.2f animations:^() {
        self.backgroundBlurView.alpha = 0.0f;
    }];
}

@end
