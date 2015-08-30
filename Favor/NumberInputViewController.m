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

@end

@implementation NumberInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [ColorPalette getFavorPinkRedColor];
  
  self.parseDataManager = [[DatabaseManager alloc]init];
  
  self.parseDataManager.delegate = self;

  [self.parseDataManager getDataForCurrentUser:[User currentUser]];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
