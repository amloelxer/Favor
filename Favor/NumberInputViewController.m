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

@interface NumberInputViewController () <DatabaseManagerDelegate,UITextFieldDelegate>
@property DatabaseManager *parseDataManager;
@property User *currentUser;
@property (weak, nonatomic) IBOutlet UIImageView *numberInputImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberInputNameLabel;
@property UIFont* proximaNovaRegular;
@property UIFont* proximaNovaBold;
@property UIFont* proximaNovaSoftBold;
@property (weak, nonatomic) IBOutlet UILabel *pleaseEnterYourNumberBelowToGetStarted;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property NSString *phoneNumber;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *phoneNumberInputActivityIndicator;

@end

@implementation NumberInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [ColorPalette getFavorPinkRedColor];
  
  self.proximaNovaRegular = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
  
  self.proximaNovaBold = [UIFont fontWithName:@"ProximaNova-Bold" size:16];
  
  self.proximaNovaSoftBold = [UIFont fontWithName:@"ProximaNovaSoft-Bold" size:16];
  
  self.parseDataManager = [[DatabaseManager alloc]init];
  
  self.parseDataManager.delegate = self;
  
  self.currentUser = [User currentUser];
  
  [self.parseDataManager getDataForFile:self.currentUser[@"ProfilePicture"]];
  
  self.phoneNumberInputActivityIndicator.hidden = YES;
  
  [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

//  NSLog(@"The current User's name is: %@", currentUser[@"name"]);
  
}


#pragma mark - textFieldDelegateMethod

-(void)textFieldDidChange :(UITextField *)theTextField
{
   self.phoneNumber = self.phoneNumberTextField.text;
}


//Taken from Stack. Thanks Dingo Sky!!!
- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  
  // All digits entered
  if (range.location == 12) {
    return NO;
  }
  
  // Reject appending non-digit characters
  if (range.length == 0 &&
      ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
    return NO;
  }
  
  // Auto-add hyphen before appending 4rd or 7th digit
  if (range.length == 0 &&
      (range.location == 3 || range.location == 7)) {
    textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
    return NO;
  }
  
  // Delete hyphen when deleting its trailing digit
  if (range.length == 1 &&
      (range.location == 4 || range.location == 8))  {
    range.location--;
    range.length = 2;
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
    return NO;
  }
  
  return YES;
}

- (IBAction)goButtonClicked:(UIButton *)sender
{
  [self.phoneNumberTextField resignFirstResponder];
  
    [self.parseDataManager savePhoneNumberForCurrentUser:self.phoneNumber];
    self.phoneNumberInputActivityIndicator.hidden = NO;
  [self.phoneNumberInputActivityIndicator startAnimating];
}


#pragma mark - Database Manager Delegate Methods
- (void)isDoneConvertingPFFileToData:(NSData *)imageData
{

  UIImage *profImage = [UIImage imageWithData:imageData];
  self.numberInputImageView.image = profImage;
  //make sure this is frame.size and not image.size
  self.numberInputImageView.layer.cornerRadius = 100;
  self.numberInputImageView.layer.masksToBounds = YES;
  
  
//  self.numberInputNameLabel.text
  NSString *initalName = self.currentUser[@"name"];
  
  NSArray *arrayOfFirstAndLastName = [initalName componentsSeparatedByString:@" "];
  
  NSString *firstName = [arrayOfFirstAndLastName firstObject];
  
  NSString *fullGreetingWithNameString = [NSString stringWithFormat:@"Hi %@!",firstName];
    
  self.pleaseEnterYourNumberBelowToGetStarted.font = [self.proximaNovaRegular fontWithSize:22];
  self.pleaseEnterYourNumberBelowToGetStarted.textColor = [ColorPalette getFavorYellowColor];
    [self.pleaseEnterYourNumberBelowToGetStarted setTextAlignment:UITextAlignmentCenter];
    
  
  self.goButton.titleLabel.font = self.proximaNovaSoftBold;
  
  self.numberInputNameLabel.text = fullGreetingWithNameString;
  self.numberInputNameLabel.textColor = [ColorPalette getFavorYellowColor];
  self.numberInputNameLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:26];
    [self.phoneNumberTextField becomeFirstResponder];
    
    self.goButton.layer.cornerRadius = 3;
    [self.goButton setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:24]];
  
}

- (void)isDoneSavingPhoneNumber
{
  [self performSegueWithIdentifier:@"phoneNumberSegue" sender:self];
}




@end
