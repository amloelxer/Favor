//
//  ModalViewController.h
//  favorModalCreatePost
//
//  Created by Cassidy Clawson on 8/17/15.
//  Copyright (c) 2015 Cassidy Clawson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageEffects.h"
#import "Pop.h"

@protocol RadiusViewControllerDelegate;

@interface RadiusViewController : UIViewController <UITextViewDelegate>

@property (nonatomic) id <RadiusViewControllerDelegate> delegate;
-(instancetype)initWithBackgroundViewController:(UIViewController *)backgroundVC currentRadius:(NSNumber *)currentRadius;

@end

@protocol RadiusViewControllerDelegate <NSObject>

-(void)radiusSelected:(NSNumber *)radius radiusViewController:(RadiusViewController *)radiusVC;

@end