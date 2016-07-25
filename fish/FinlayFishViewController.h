//
//  ViewController.h
//  fish
//
//  Created by hariharan on 7/22/16.
//  Copyright © 2016 hariharan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinlayFishViewController : UIViewController
@property(nonatomic,assign)    int maxChipsRound;
@property(nonatomic,assign)     int maxfishRound;
-(int)maxCookRoundwithinSecs:(int)cookTime withinSec:(int)withinSec;

@end

