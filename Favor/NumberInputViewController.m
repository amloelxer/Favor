//
//  NumberInputViewController.m
//  Favor
//
//  Created by Alex Moller on 8/29/15.
//  Copyright (c) 2015 Alex Moller. All rights reserved.
//

#import "NumberInputViewController.h"
#import "ColorPalette.h"
#import "DatabaseManager.h"
#import "User.h"

@interface NumberInputViewController () <DatabaseManagerDelegate>
@property DatabaseManager *parseDataManager;
@property User *currentUser;
@property (weak, nonatomic) IBOutlet UIImageView *numberInputImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberInputNameLabel;


@end

@implementation NumberInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [ColorPalette getFavorPinkRedColor];
  
  self.parseDataManager = [[DatabaseManager alloc]init];
  
  self.parseDataManager.delegate = self;
  
  self.currentUser = [User currentUser];
  
  [self.parseDataManager getDataForFile:self.currentUser[@"ProfilePicture"]];
  
  
//  NSLog(@"The current User's name is: %@", currentUser[@"name"]);
  
}

- (void)isDoneConvertingPFFileToData:(NSData *)imageData
{

  UIImage *profImage = [UIImage imageWithData:imageData];
  self.numberInputImageView.image = profImage;
  //make sure this is frame.size and not image.size
  self.numberInputImageView.layer.cornerRadius = self.numberInputImageView.frame.size.width/2;
  self.numberInputImageView.layer.masksToBounds = YES;
  self.numberInputNameLabel.text = self.currentUser[@"name"];

}



@end
