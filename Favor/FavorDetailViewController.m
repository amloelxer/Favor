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
  
  
  
}

@end
