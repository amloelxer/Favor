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
#import "Favor.h"
#import "FavorFeedViewController.h"
#import "DatabaseManager.h"

@protocol ModalViewControllerDelegate;

@interface ModalViewController : UIViewController <UITextViewDelegate>

@property (nonatomic) id <ModalViewControllerDelegate> delegate;
- (instancetype)initWithBackgroundViewController:(UIViewController *)backgroundVC;



@end

@protocol ModalViewControllerDelegate <NSObject>

- (void)ModalViewControllerDidCancel:(ModalViewController *)modalViewController;
- (void)ModalViewControllerDidSubmitFavor:(ModalViewController *)modalViewController askOrOffer:(NSInteger)someAskOrOffer;

@end