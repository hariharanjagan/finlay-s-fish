//
//  ViewController.m
//  fish
//
//  Created by hariharan on 7/22/16.
//  Copyright © 2016 hariharan. All rights reserved.
//

#import "FinlayFishViewController.h"
#import "Order.h"
#import "InputPortion.h"
#import "Constant.h"
@interface FinlayFishViewController ()
{
    NSMutableArray * orderList;
    NSDate * previousEndTime;
    
}
@end

@implementation FinlayFishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.maxChipsRound= [self maxCookRoundwithinSecs:chipsCookTime withinSec:withinMaxCookedSecs];
    self.maxfishRound= [self maxCookRoundwithinSecs:codCookTime<hadCookTime? codCookTime:hadCookTime withinSec:withinMaxCookedSecs];
    orderList = [[NSMutableArray alloc]init];
    [self start];
}
-(BOOL)isExceedMaxRound:(Order*)order
{
    int chipsCookRequireRound = [self divideRoundup:order.chipsNum divider:chipsFyerQtn];
    int totalFishNum = order.codNum + order.hadNum;
    int fishCookRequireRound = [self divideRoundup:totalFishNum divider: fishFyerQtn];
    if (chipsCookRequireRound > self.maxChipsRound || fishCookRequireRound > self.maxfishRound) {
        return true;
    }
    
    return false;


}
-(int)divideRoundup:(int)dividend divider:(int)divider
{
    
    if (dividend == 0)
        return 0;
    
    return (dividend % divider) > 0 ? (dividend / divider) + 1 : dividend / divider;
}
-(void)start
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"input002" ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray *arr = [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    for (NSString * strOrder in arr) {
        Order*order=[[Order alloc ]initWith:strOrder];
        [orderList addObject:order];
    }
    NSDateFormatter * dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"hh:mm:ss"];

    for (int i = 0; i < [orderList count]; i++) {
        Order*order =[orderList objectAtIndex:i];
        NSString * strOrderDetail =[NSString stringWithFormat:@"at %@, Order #%d",[dateFormatter stringFromDate:order.orderTime],order.orderNumber];
        if ([self isExceedMaxRound:order] || [self isCustomerWillWaitTooLong:order]) {
           strOrderDetail= [strOrderDetail stringByAppendingString:@" Rejected"];
            NSLog(@"%@",strOrderDetail);

        } else {
        strOrderDetail=    [strOrderDetail stringByAppendingString:@" Accepted"];
            NSLog(@"%@",strOrderDetail);

            [self handleOrder:order];
        }
    }
}
-(void)handleOrder:(Order*)order
{
    int minFishTime =[self minFishTime:order.codNum hadCod:order.hadNum];
    int minChipsTime =[self minchipsTime:order.chipsNum];
    int minRequireTime =[self getMax:minFishTime secondNum:minChipsTime];
    
    // Input all the request into map
    [order inputChipsRequest:order.requestDataDic chipsTimeUsage:minChipsTime totalTimeUsage:minRequireTime chipsNum:order.chipsNum];
    [order inputFishRequest:order.requestDataDic fishTimeUsage:minFishTime totalTimeUsage:minRequireTime orderCodNum:order.codNum orderHadNum:order.hadNum];
    
    NSArray* arrayKey =[order.requestDataDic allKeys];
    NSArray *sortedKeys = [arrayKey sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];
    NSDateFormatter * dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"hh:mm:ss"];

    for (NSString * timeStamp in sortedKeys) {
        InputPortion * inputPortion = [order.requestDataDic valueForKey:timeStamp];
        
        NSDate* offSetCal =[order.actualStartCal dateByAddingTimeInterval:[timeStamp doubleValue]];
        NSString * strOrderResult =[NSString stringWithFormat:@"at %@, Begin Cooking ",[dateFormatter stringFromDate:offSetCal]];

        if(inputPortion.codNum>0){
            strOrderResult=    [strOrderResult stringByAppendingFormat:@"%d Cod",inputPortion.codNum];
        }else if( inputPortion.hadNum > 0 ){
            strOrderResult=    [strOrderResult stringByAppendingFormat:@"%d Haddock",inputPortion.hadNum];
        }else if( inputPortion.chipsNum > 0 ){
            strOrderResult=    [strOrderResult stringByAppendingFormat:@"%d Chips",inputPortion.chipsNum];
        }
        
        NSLog(@"%@",strOrderResult);
    }
    NSLog(@"at %@, Serve Order #%d",[dateFormatter stringFromDate:order.endCal],order.orderNumber);

}
-(BOOL)isCustomerWillWaitTooLong:(Order*)order
{
    
    NSDateFormatter *df=[[NSDateFormatter alloc]init];
    [df setDateFormat:@"hh:mm:ss"];

    order.chipsRequireTime=[self minchipsTime:order.chipsNum];
    order.fishRequireTime=[self minFishTime:order.codNum hadCod:order.hadNum];
    [self updateCookingTime:order];
   if ( order.orderTime!=nil && ([order.orderTime compare:previousEndTime]== NSOrderedAscending))
       {
           int offsetInSec =[previousEndTime timeIntervalSinceDate:order.orderTime];
           order.actualStartCal=[order.orderTime dateByAddingTimeInterval:offsetInSec];
       }
   else{
       order.actualStartCal=order.orderTime;
   }
    order.endCal=[order.actualStartCal dateByAddingTimeInterval:order.reqCookingTime];

    order.customerWaitSecs=[order.endCal timeIntervalSinceDate:order.orderTime];
    if (order.customerWaitSecs > maxCustomerWaitingSecs) {
        return true;
    } else {
        previousEndTime = order.endCal;
        return false;
    }
}
-(void)updateCookingTime:(Order*)order {
    order.reqCookingTime=[self getMax:order.chipsRequireTime secondNum:order.fishRequireTime];
}
-(int)maxCookRoundwithinSecs:(int)cookTime withinSec:(int)withinSec
{
    int availRound=(withinSec/cookTime)+1;
    return availRound;
    
}
-(int)minchipsTime:(int)chipsPortion
{
    if (chipsPortion == 0) {
        return 0;
    }
    
    return chipsCookTime *[self divideRoundup:chipsPortion divider:chipsFyerQtn];
}
-(int)minFishTime:(int)codNum hadCod:(int)hadNum
{
    int total = codNum + hadNum;
    int requireRound = [self divideRoundup:total divider:fishFyerQtn];
    int minTime = -1;
    
    minTime = [self recurFishTime:codNum hadCod:hadNum round:requireRound possibleMinTime:0 reminingFyer:fishFyerQtn];
    return minTime;
}
-(int)recurFishTime:(int) codNum hadCod:(int)hadNum round:(int)round possibleMinTime:(int)psbleMinTime reminingFyer:(int)remainingslot
{
    int time = 0;
    int totalNum = codNum + hadNum;
    
    if (totalNum <= remainingslot) {
        return[self getMax:psbleMinTime secondNum:[self getMax:codNum > 0 ? codCookTime : 0 secondNum:hadNum > 0 ? hadCookTime : 0]];
    }
    
    // If we put all cods into slot
    int fullCodSlot = codNum > 0 ? [self divideRoundup:codNum divider:round] : 0;
    
    // The remainAvailableSlots we have to cook haddock
    int availableSlot = remainingslot - fullCodSlot;
    
    if (hadNum > 0 && codNum > 0 && hadNum > availableSlot * (round - 1)) {
        codNum = codNum - 1;
        hadNum = hadNum - 1;
        time = codCookTime + hadCookTime;
    }
    else if (codNum >= round) {
        codNum = codNum - round;
        time = codCookTime * round;
    }
    else if (codNum > 0 && hadNum > 0) {
        codNum = codNum - 1;
        hadNum = hadNum - 1;
        time = codCookTime + hadCookTime;
    }
    else if (hadNum >= round) {
        hadNum = hadNum - round;
        time = hadCookTime * round;
    }
    
    psbleMinTime = [self getMax:psbleMinTime secondNum:time];
    remainingslot--;
    if (remainingslot > 0) {
        return[self recurFishTime:codNum hadCod:hadNum round:round possibleMinTime:psbleMinTime reminingFyer:remainingslot];
        
    
    }
    
    return psbleMinTime;
}
-(int)getMax:(int)a secondNum:(int)b
{
    return (a > b) ? a : b;

}
-(int)getMin:(int)a secondNum:(int)b
{
    return (a < b) ? a : b;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
