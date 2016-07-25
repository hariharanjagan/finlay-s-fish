//
//  Order.h
//  fish
//
//  Created by hariharan on 7/22/16.
//  Copyright © 2016 hariharan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject


@property(nonatomic,assign) int orderNumber;
@property(nonatomic,assign)int codNum;
@property(nonatomic,assign)int hadNum;
@property(nonatomic,assign)int chipsNum;
@property(nonatomic,strong)NSDate * orderTime;
@property(nonatomic,strong)NSDate * actualStartCal;
@property(nonatomic,strong)NSDate * endCal;
@property(nonatomic,assign)int reqCookingTime;
@property(nonatomic,assign)int customerWaitSecs;
@property(nonatomic,assign)int fishRequireTime;
@property(nonatomic,assign)int chipsRequireTime;
@property(nonatomic, strong) NSMutableDictionary * requestDataDic;
-(id)initWith:(NSString*) str;
-(void)createOrderFromStr:(NSString*)str;
-(void)inputChipsRequest:(NSMutableDictionary*)inputRequest chipsTimeUsage:(int)chipsTimeUsage totalTimeUsage:(int)totalTimeUsage chipsNum:(int)chipsNum;
-(void)inputFishRequest:(NSMutableDictionary*)inputRequest fishTimeUsage:(int)
fishTimeUsage totalTimeUsage:(int)totalTimeUsage orderCodNum:(int)orderCodNum orderHadNum:(int)orderHadNum;
@end
