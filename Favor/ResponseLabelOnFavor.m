//
//  ResponseLabelOnFavor.m
//  Favor
//
//  Created by Alex Moller on 8/24/15.
//  Copyright © 2015 Alex Moller. All rights reserved.
//

#import "ResponseLabelOnFavor.h"

@implementation ResponseLabelOnFavor
- (void)setOnNumber:(NSNumber *)numOfResponses;
{
  if([numOfResponses intValue] == 0)
  {
    self.backgroundColor = [ColorPalette getFavorRedColor];
    self.text = @" 0 Responses";
  }
  else if([numOfResponses intValue] == 1)
  {
    self.backgroundColor = [ColorPalette getFavorYellowColor];
    self.text = @" 1 Responses";
  }
  else
  {
    self.backgroundColor = [ColorPalette getFavorYellowColor];
    self.text =  [NSString stringWithFormat:@" %@ Responses",numOfResponses];
  }

}

@end