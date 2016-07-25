//
//  InputPortion.h
//  fish
//
//  Created by hariharan on 7/22/16.
//  Copyright © 2016 hariharan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputPortion : NSObject
@property(nonatomic,assign)int codNum ;
@property(nonatomic,assign)int hadNum ;
@property(nonatomic,assign)int chipsNum;
-(void)addPortion:(InputPortion*) inputPortion;
@end
