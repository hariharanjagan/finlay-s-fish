//
//  InputPortion.m
//  fish
//
//  Created by hariharan on 7/22/16.
//  Copyright © 2016 hariharan. All rights reserved.
//

#import "InputPortion.h"

@implementation InputPortion
-(void)addPortion:(InputPortion*) inputPortion{
    
    self.codNum +=inputPortion.codNum;
    self.hadNum+=inputPortion.hadNum;
    self.chipsNum+=inputPortion.chipsNum;
    
}


@end
