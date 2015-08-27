//
//  RadiusViewController.m
//  favorModalCreatePost
//
//  Created by Cassidy Clawson on 8/17/15.
//  Copyright (c) 2015 Cassidy Clawson. All rights reserved.
//

#import "RadiusViewController.h"
#import "math.h"
#import "UICountingLabel.h"

@interface RadiusViewController()

@property (nonatomic, strong) UIViewController *backgroundVC;
@property (nonatomic, strong) UIView *backgroundBlurView;
@property (nonatomic, strong) UIView *modalView;
@property (nonatomic) CGPoint modalViewOffscreenCenter;
@property (nonatomic) CGPoint modalViewOnscreenCenter;
@property (nonatomic) CGPoint modalCenterPoint;

@property (nonatomic) NSArray *radiuses;
@property (nonatomic) NSNumber *currentRadius;

@property (nonatomic) CAShapeLayer *indicatorCircle;
@property (nonatomic) UIView *indicatorCircleView;
@property (nonatomic, strong) UIView *pullView;

@property (nonatomic) NSInteger minRadiusY;
@property (nonatomic) NSInteger maxRadiusY;
@property (nonatomic) NSInteger currentRadiusY;

@property (nonatomic, strong) UICountingLabel *radiusLabel;


@property (nonatomic) float scaleRadius;
@property (nonatomic) float scaleFactor;
@property (nonatomic) float maxFactor;

@end


@implementation RadiusViewController

-(instancetype)initWithBackgroundViewController:(UIViewController *)backgroundVC currentRadius:(NSNumber *)currentRadius {
    self = [super init];
    if (self) {
        _backgroundVC = backgroundVC;
        _delegate = backgroundVC;
        _radiuses = [self setupRadiuses];
        _currentRadius = currentRadius;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [self captureBackgroundBlurImage];
    [self showCoordinator];
}

-(void)viewDidLoad {
    [self setupModalView];
    [self addObserver:self forKeyPath:@"scaleFactor" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - Show & Hide View Controller

-(void)showCoordinator {
    [self showBackgroundBlurImage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self moveModalViewTo:self.modalViewOnscreenCenter];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self moveModalViewTo:self.modalViewOnscreenCenter];
    });
}

-(void)hideCoordinator {
  
  [self removeObserver:self forKeyPath:@"scaleFactor"];
  
    [self moveModalViewTo:self.modalViewOffscreenCenter];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideBackgroundBlurImage];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destroySelf];
    });
}

-(void)destroySelf {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)setupModalView {
    // Modal View Initializer
    CGRect modalRect = CGRectMake(0, 0, self.view.frame.size.width - 32, self.view.frame.size.width - 32);
    UIView *modalView = [[UIView alloc] initWithFrame:modalRect];
    
    // Modal View Basic Styling
    modalView.backgroundColor = [UIColor whiteColor];
    modalView.layer.cornerRadius = modalRect.size.width / 2;
    
    // Drop Shadow
    [modalView.layer setShadowColor:[UIColor blackColor].CGColor];
    modalView.layer.shadowOffset = CGSizeMake(0,0);
    modalView.layer.shadowRadius = 16;
    modalView.layer.shadowOpacity = 0.1;
    
    
    // Add child elements
    [self radiusLabelToView:modalView];
    [self circleViewsToView:modalView];

    // Modal View Positions
    self.modalViewOffscreenCenter = CGPointMake(self.view.center.x, modalView.frame.size.height * -1);
    self.modalViewOnscreenCenter = CGPointMake(self.view.center.x, self.view.center.y);
    modalView.center = self.modalViewOffscreenCenter;
    
    // Setup Modal View
    self.modalView = modalView;
    [self.view addSubview:modalView];
}

-(void)radiusLabelToView:(UIView *)view {
    CGPoint center = [view convertPoint:view.center fromView:view.superview];
    int height = 30;
    int width = 200;
    CGRect rect = CGRectMake(center.x - (width / 2), center.y - (height / 1.5), width, height);
    UICountingLabel *label = [[UICountingLabel alloc] initWithFrame:rect];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    label.font = [self radiusFont];
    label.format = @"%d";
    label.method = UILabelCountingMethodLinear;
    label.textColor = [self darkColor];
    [label countFromCurrentValueTo:self.currentRadius.floatValue withDuration:0];
    
    CGRect subtitleRect = CGRectMake(center.x - (width / 2), center.y + (height / 3), width, height / 2);
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:subtitleRect];
    [subtitleLabel setTextAlignment:NSTextAlignmentCenter];
    
    subtitleLabel.text = @"miles";
    subtitleLabel.textColor = [self darkColor];

    self.radiusLabel = label;
    
    [view addSubview:label];
    [view addSubview:subtitleLabel];
}

-(void)circleViewsToView:(UIView *)view {
    CGPoint center = [view convertPoint:view.center fromView:view.superview];
    int indicatorRadius = 120;
    int borderWidth = 4;
    
    // Setup Indicator Circle
    CAShapeLayer *indicatorCircle = [CAShapeLayer layer];
    indicatorCircle.fillColor = nil;
    indicatorCircle.strokeColor = [self greenColor].CGColor;
    indicatorCircle.lineWidth = borderWidth;
    indicatorCircle.frame = CGRectMake(0, 0, indicatorRadius, indicatorRadius);
    indicatorCircle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, indicatorRadius, indicatorRadius)cornerRadius:indicatorRadius].CGPath;
    self.indicatorCircle = indicatorCircle;
    
    // Setup Indicator Circle View
    CGRect indicatorCircleViewRect = CGRectMake(center.x - (indicatorRadius / 2), center.y - (indicatorRadius / 2), indicatorRadius, indicatorRadius);
    self.indicatorCircleView = [[UIView alloc] initWithFrame:indicatorCircleViewRect];

    // Add layers and views to subviews
    [self.indicatorCircleView.layer addSublayer:self.indicatorCircle];
    [view addSubview:self.indicatorCircleView];
    
    // Setup Pull Circle
    int parentSize = 50;
    int childSize = 26;
    self.minRadiusY = center.y + (indicatorRadius / 2);
    self.currentRadiusY = self.minRadiusY;
    self.maxRadiusY = (self.view.frame.size.height / 2) - 30;
    
    CGRect parentRect = CGRectMake(center.x - (parentSize / 2), center.y + (indicatorRadius / 2) - (parentSize / 2), parentSize, parentSize);
    UIView *pullCircleParent = [[UIView alloc] initWithFrame:parentRect];
    pullCircleParent.backgroundColor = [UIColor clearColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pull:)];
    
    [pullCircleParent addGestureRecognizer:pan];
    
    CGRect childRect = CGRectMake(0, 0, childSize, childSize);
    UIView *childView = [[UIView alloc] initWithFrame:childRect];
    
    childView.backgroundColor = [UIColor redColor];
    childView.layer.cornerRadius = childSize / 2;
    childView.layer.borderWidth = borderWidth;
    childView.layer.borderColor = [self greenColor].CGColor;
    childView.backgroundColor = [UIColor whiteColor];
    
    self.pullView = pullCircleParent;
    [pullCircleParent addSubview:childView];
    [view addSubview:pullCircleParent];
    childView.center = CGPointMake(pullCircleParent.frame.size.width / 2, pullCircleParent.frame.size.height / 2);
    
    // Scale to match initial number
    [self updateIndicatorCircleRadiusWithOptionalNumber:self.currentRadius];
}

- (void)updateIndicatorCircleRadiusWithOptionalNumber:(NSNumber *)number {
    // TODO: Extract this so it's not run all the time.
    
    if(number == nil) {
        UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
        CGPoint pointInWindowCoords = [mainWindow convertPoint:self.modalView.center fromWindow:nil];
        self.modalCenterPoint = [self.modalView convertPoint:self.modalView.center fromView:mainWindow];
        
        self.scaleRadius = self.pullView.center.y - self.modalCenterPoint.y;
        self.scaleFactor = [self indicatorCircleScaleFactorFor:self.scaleRadius];
        self.indicatorCircleView.transform = CGAffineTransformMakeScale(self.scaleFactor, self.scaleFactor);
        self.indicatorCircle.lineWidth = (4 / self.scaleFactor);
    } else {
        UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
        CGPoint pointInWindowCoords = [mainWindow convertPoint:self.modalView.center fromWindow:nil];
        self.modalCenterPoint = [self.modalView convertPoint:self.modalView.center fromView:mainWindow];
        
        self.pullView.center = CGPointMake(self.pullView.center.x, [self yForScaleFactor:[self scaleFactorForRadius:number]]);
        self.scaleFactor = [self scaleFactorForRadius:number];
        self.indicatorCircleView.transform = CGAffineTransformMakeScale([self scaleFactorForRadius:number], [self scaleFactorForRadius:number]);
        self.indicatorCircle.lineWidth = (4 / [self scaleFactorForRadius:number]);
    }
}

-(float)indicatorCircleScaleFactorFor:(float)radius {
//    NSLog(@"%f", radius / (self.indicatorCircle.frame.size.width / 2));
    return radius / (self.indicatorCircle.frame.size.width / 2);
}

-(float)yForScaleFactor:(float)radius {
    return (((radius - 1) / (2.2 - 1.0)) * (self.maxRadiusY - self.minRadiusY) + self.minRadiusY);
}

-(void)moveModalViewTo:(CGPoint)location {
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    animation.toValue = [NSValue valueWithCGPoint:location];
    [self.modalView pop_addAnimation:animation forKey:@"moveOnScreen"];
}

#pragma mark - User Input

- (IBAction)pull:(UIPanGestureRecognizer *)recognizer {
//    NSLog(@"Scale Radius: %f", self.scaleRadius);
  
    switch (recognizer.state) {

        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self.view];
            CGPoint center = self.pullView.center;

            if (center.y >= self.minRadiusY && center.y <= self.maxRadiusY) {
                center.y += translation.y;
                self.pullView.center = center;
                [recognizer setTranslation:CGPointZero inView:self.view];

            } else if (center.y < self.minRadiusY && translation.y < 0) {
                float log = log10f(self.minRadiusY - center.y);
                center.y += log;
                self.pullView.center = center;
                [recognizer setTranslation:CGPointZero inView:self.view];

                break;
            } else if (center.y < self.minRadiusY && translation.y > 0) {
                center.y += translation.y;
                self.pullView.center = center;
                [recognizer setTranslation:CGPointZero inView:self.view];

                break;
            } else if (center.y > self.maxRadiusY && translation.y > 0) {
                float log = log10f(((center.y - self.maxRadiusY) / 5) + 1);
                center.y += log;
                self.pullView.center = center;
                [recognizer setTranslation:CGPointZero inView:self.view];

                break;
            }
            else if (center.y > self.maxRadiusY && translation.y < 0) {
                center.y += translation.y;
                self.pullView.center = center;
                [recognizer setTranslation:CGPointZero inView:self.view];

                break;
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            
            POPDecayAnimation *anim = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPosition];
            anim.deceleration = .3;
            anim.velocity = [NSValue valueWithCGPoint:[recognizer velocityInView:self.view]];
            [self.pullView.layer pop_addAnimation:anim forKey:@"slide"];
            
            CGPoint center = self.pullView.center;
            if (center.y < self.minRadiusY) {
                [self returnPullAnimationTo:CGPointMake(center.x, self.minRadiusY) withKey:@"pullAnim"];
                
                // Return indicatorCircle to minimum positon
                CGAffineTransform origScale = CGAffineTransformMakeScale([self indicatorCircleScaleFactorFor:self.scaleRadius], [self indicatorCircleScaleFactorFor:self.scaleRadius]);
                CGAffineTransform newScale = CGAffineTransformMakeScale(1, 1);
                [self returnIndicatorCircleAnimationFromScale:origScale toNewScale:newScale withKey:@"min"];

            } else if (center.y > self.maxRadiusY) {
                [self returnPullAnimationTo:CGPointMake(center.x, self.maxRadiusY) withKey:@"return"];
                
                // Return indicatorCircle to minimum positon
                float origY = self.maxRadiusY - self.modalCenterPoint.y;
                CGAffineTransform origScale = CGAffineTransformMakeScale([self indicatorCircleScaleFactorFor:self.scaleRadius], [self indicatorCircleScaleFactorFor:self.scaleRadius]);
                CGAffineTransform newScale = CGAffineTransformMakeScale([self indicatorCircleScaleFactorFor:origY], [self indicatorCircleScaleFactorFor:origY]);
                [self returnIndicatorCircleAnimationFromScale:origScale toNewScale:newScale withKey:@"max"];
            }
            
            float selectHighlightDelay = 0.15;
            float hideDelay = 1.15;
            
            [NSTimer scheduledTimerWithTimeInterval:selectHighlightDelay
                                             target:self
                                           selector:@selector(highlightChosenRadius)
                                           userInfo:nil
                                            repeats:NO];
            
            [NSTimer scheduledTimerWithTimeInterval:(selectHighlightDelay + hideDelay)
                                             target:self
                                           selector:@selector(hideCoordinator)
                                           userInfo:nil
                                            repeats:NO];
            
            [self.delegate radiusSelected:self.currentRadius radiusViewController:self];
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
            break;
            
        default:
            break;
    }
    [self updateIndicatorCircleRadiusWithOptionalNumber:nil];
}

-(void)returnPullAnimationTo:(CGPoint)coord withKey:(NSString *)key {
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    anim.toValue = [NSValue valueWithCGPoint:coord];
    anim.springBounciness = 4;
    anim.springSpeed = 20;
    [self.pullView.layer pop_addAnimation:anim forKey:key];
}

-(void)returnIndicatorCircleAnimationFromScale:(CGAffineTransform)origScale toNewScale:(CGAffineTransform)newScale withKey:(NSString *)key {
    CABasicAnimation *indicatorAnim = [CABasicAnimation animationWithKeyPath: @"transform" ];
    indicatorAnim.duration = 0.2;
    
    CATransform3D origTrans = CATransform3DMakeAffineTransform (origScale);
    CATransform3D newTrans = CATransform3DMakeAffineTransform (newScale);
    
    indicatorAnim.fromValue = [ NSValue valueWithCATransform3D: origTrans ];
    indicatorAnim.toValue = [ NSValue valueWithCATransform3D: newTrans ];
    [indicatorAnim setValue:key forKey:@"indicatorCircleType"];
    [indicatorAnim setDelegate:self];
    
    [self.indicatorCircleView.layer addAnimation: indicatorAnim forKey: @"scale"];
    [self.indicatorCircleView.layer setAffineTransform: newScale];
    
    self.indicatorCircleView.transform = newScale;
}

// Delegate method from animation to adjust stroke thickness (which is distorted by the scaling, not optimal)
-(void)animationDidStart:(CAAnimation *)anim {
    NSString *type = [anim valueForKey:@"indicatorCircleType"];
    if ([type isEqualToString:@"min"]) {
        CGAffineTransform newScale = CGAffineTransformMakeScale(1, 1);
        self.indicatorCircleView.transform = newScale;
        self.indicatorCircle.lineWidth = 4;
    } else if ([type isEqualToString:@"max"]) {
        float origY = self.maxRadiusY - self.modalCenterPoint.y;
        self.indicatorCircleView.transform = CGAffineTransformMakeScale([self indicatorCircleScaleFactorFor:origY], [self indicatorCircleScaleFactorFor:origY]);
        self.indicatorCircle.lineWidth = 4 / [self indicatorCircleScaleFactorFor:origY];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateRadiusLabel];
}

-(void)updateRadiusLabel {
    float increment = 1.2 / self.radiuses.count;
    int i = 0;
    for (NSNumber *radius in self.radiuses) {
        float firstScaleIncrement = .97 + (increment * (i + 1));
        float secondScaleIncrement = .97 + (increment * (i + 2));

        if (self.scaleFactor > firstScaleIncrement && self.scaleFactor < secondScaleIncrement) {
            if (self.currentRadius != self.radiuses[i]) {
                [self.radiusLabel countFromCurrentValueTo:[self.radiuses[i] floatValue] withDuration:0.2];
                self.currentRadius = self.radiuses[i];
            }
        }
        i ++;
    }
}

-(float)scaleFactorForRadius:(NSNumber *)radius {
    float returnValue = 1;
    float increment = 1.2 / self.radiuses.count;
    int i = 0;
    for (NSNumber *arrayRadius in self.radiuses) {
        if ([arrayRadius isEqualToNumber:radius]) {
            returnValue = .97 + (increment * (i + 1));
        }
        i++;
    }
    return returnValue;
}

-(void)highlightChosenRadius {
    POPSpringAnimation *colorAnimation = [POPSpringAnimation animation];
    colorAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLabelTextColor];
    colorAnimation.springSpeed = 20;
    colorAnimation.springBounciness = 10;
    colorAnimation.toValue = (__bridge id)([self greenColor].CGColor);
    [self.radiusLabel pop_addAnimation:colorAnimation forKey:@"colorAnimation"];
//    NSLog(@"%@", NSStringFromSelector(_cmd));
  
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

-(UIFont *)radiusFont {
    return [UIFont fontWithName:@"Helvetica" size:30];
}

-(UIFont *)subtitleFont {
    return [UIFont fontWithName:@"Helvetica" size:6];
}


-(NSArray *)setupRadiuses {
    NSArray *radiuses = @[@1, @2, @3, @5, @10, @15, @20, @30, @40, @50, @75, @100, @250, @500, @1000, @2500, @5000];
    return radiuses;
}

-(UIColor *)darkColor {
    return [UIColor colorWithRed:75.0/255 green:82.0/255 blue:88.0/255 alpha:1.0];
}

-(UIColor *)redColor {
    return [UIColor colorWithRed:253.0/255 green:65.0/255 blue:58.0/255 alpha:1.0];
}

-(UIColor *)greenColor {
    return [UIColor colorWithRed:80.0/255 green:211.0/255 blue:161.0/255 alpha:1.0];
}

@end
