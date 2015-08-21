//
//  FavorDetailViewController.m
//  Favor
//
//  Created by Alex Moller on 8/18/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "FavorDetailViewController.h"

@interface FavorDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *favorLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedFavorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePassedTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *passedSelectedFavorPosterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@end

@implementation FavorDetailViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  self.favorLabel.backgroundColor = [ColorPalette getFavorRedColor];
  
  self.profileImageView.image = self.profImage;
  
  //code to make it circular 
  self.profileImageView.layer.cornerRadius = self.profileImageView.image.size.width / 2;
  self.profileImageView.layer.masksToBounds = YES;
  
  self.selectedFavorTextLabel.text = self.passedFavorText;
  self.passedSelectedFavorPosterNameLabel.text = self.passedSelectedFavorPosterName;
  self.timePassedTextLabel.text = self.passedTimeText;
  
}

@end
