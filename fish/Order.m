//
//  Order.m
//  fish
//
//  Created by hariharan on 7/22/16.
//  Copyright © 2016 hariharan. All rights reserved.
//

#import "Order.h"
#import "InputPortion.h"
#import "Constant.h"
#import "FinlayFishViewController.h"
@implementation Order
{
    int maxChipsRound;
    int maxfishRound;
}
-(id)initWith:(NSString *)str{
    self = [super init];
    maxChipsRound= [self maxCookRoundwithinSecs:chipsCookTime withinSec:withinMaxCookedSecs];
    maxfishRound= [self maxCookRoundwithinSecs:codCookTime<hadCookTime? codCookTime:hadCookTime withinSec:withinMaxCookedSecs];

    self.requestDataDic=[[NSMutableDictionary alloc]init];
    
    [self createOrderFromStr:str];
    return self;
}
-(int)maxCookRoundwithinSecs:(int)cookTime withinSec:(int)withinSec
{
    int availRound=(withinSec/cookTime)+1;
    return availRound;
    
}
-(void)createOrderFromStr:(NSString*)strOrder
{
    strOrder=[strOrder stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray * arrayorder=[strOrder componentsSeparatedByString:@","];
    
    for (NSString*partStr in arrayorder) {
        NSString * convertedString=@"";
        if ([[partStr lowercaseString]containsString:@"order"]) {
            convertedString =  [partStr stringByReplacingOccurrencesOfString:@"Order#" withString:@""];
           self.orderNumber =[convertedString intValue];

            continue;
        }
        
        else  if ([[partStr lowercaseString]containsString:@"cod"]) {
            convertedString= [partStr stringByReplacingOccurrencesOfString:@"Cod" withString:@""];
            self.codNum =[convertedString intValue];
            continue;
            
        }
        else  if ([[partStr lowercaseString]containsString:@"haddock"]) {
            convertedString=  [partStr stringByReplacingOccurrencesOfString:@"Haddock" withString:@""];
            self.hadNum =[convertedString intValue];
            continue;
            
        }
        
        else if ([[partStr lowercaseString]containsString:@"chips"]) {
            convertedString =  [partStr stringByReplacingOccurrencesOfString:@"Chips" withString:@""];
            self.chipsNum =[convertedString intValue];
            continue;
            
        }
        else{
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"hh:mm:ss"];
            self.orderTime = [dateFormat dateFromString:partStr];
            continue;
        
        }
        
    }
    
}
-(void)inputChipsRequest:(NSMutableDictionary*)inputRequest chipsTimeUsage:(int)chipsTimeUsage totalTimeUsage:(int)totalTimeUsage chipsNum:(int)chipsNum

{
    
     int round = 1;
    while (chipsNum > 0) {
        chipsTimeUsage=chipsCookTime *((chipsNum % chipsFyerQtn) > 0 ? (chipsNum / chipsFyerQtn) + 1 : chipsNum / chipsFyerQtn);

        int putChipsNum = chipsNum > chipsFyerQtn ? chipsFyerQtn : chipsNum;
        chipsNum -= putChipsNum;
        InputPortion *inputPortion=[[InputPortion alloc]init];
        inputPortion.codNum =0;
        inputPortion.hadNum =0;
        inputPortion.chipsNum =putChipsNum;
        [self addRequestToDic:inputRequest time:(totalTimeUsage - chipsTimeUsage)  inputPortion:inputPortion];
        
        round++;
    }
}
-(void)inputFishRequest:(NSMutableDictionary*)inputRequest fishTimeUsage:(int)
fishTimeUsage totalTimeUsage:(int)totalTimeUsage orderCodNum:(int)orderCodNum orderHadNum:(int)orderHadNum
{
    if (fishTimeUsage == codCookTime) {
        InputPortion * inputPortion=[[InputPortion alloc]init];
        inputPortion.codNum=orderCodNum;
        inputPortion.hadNum=0;
        inputPortion.chipsNum=0;
        [self addRequestToDic:inputRequest time:(totalTimeUsage - codCookTime) inputPortion:inputPortion];
    }
    else if (fishTimeUsage ==hadCookTime)
    {
        InputPortion * inputPortion=[[InputPortion alloc]init];
        inputPortion.codNum=0;
        inputPortion.hadNum=orderHadNum;
        inputPortion.chipsNum=0;
        [self addRequestToDic:inputRequest time:(totalTimeUsage- hadCookTime) inputPortion:inputPortion];
    }
    else if (fishTimeUsage == codCookTime*maxfishRound){
        
        int round = 1;
        while (orderCodNum > 0) {
            fishTimeUsage=codCookTime *((orderCodNum % fishFyerQtn) > 0 ? (orderCodNum / fishFyerQtn) + 1 : orderCodNum / fishFyerQtn);
            
            int putCodNum = orderCodNum > fishFyerQtn ? fishFyerQtn : orderCodNum;
            orderCodNum -= putCodNum;
            InputPortion *inputPortion=[[InputPortion alloc]init];
            inputPortion.codNum =putCodNum;
            inputPortion.hadNum =0;
            inputPortion.chipsNum =0;
            [self addRequestToDic:inputRequest time:(totalTimeUsage- fishTimeUsage)  inputPortion:inputPortion];
            
            round++;
        }
    }
    else if (fishTimeUsage == hadCookTime * maxfishRound) {
        // we cook HadCod ALone

        int round = 1;
        while (orderHadNum > 0) {
            fishTimeUsage=hadCookTime *((orderHadNum % fishFyerQtn) > 0 ? (orderHadNum / fishFyerQtn) + 1 : orderHadNum / fishFyerQtn);
            
            int putHadNum = orderHadNum > fishFyerQtn ? fishFyerQtn : orderHadNum;
            orderHadNum -= putHadNum;
            InputPortion *inputPortion=[[InputPortion alloc]init];
            inputPortion.codNum =0;
            inputPortion.hadNum =putHadNum;
            inputPortion.chipsNum =0;
            [self addRequestToDic:inputRequest time:(totalTimeUsage- fishTimeUsage)  inputPortion:inputPortion];
            
            round++;
        }
    }

    else if (fishTimeUsage == (codCookTime + hadCookTime)) {
        /*
         try to put all cod at last round, leave had at first round
         but not all first round will be full of had
         */
        int endRoundHadNum = (fishFyerQtn - orderHadNum) > 0 ? (fishFyerQtn - orderHadNum) : 0;
        int firstRoundHadNum = orderHadNum - endRoundHadNum;
        int endRoundCodNum = fishFyerQtn - orderCodNum;
        
        InputPortion * inputPortion=[[InputPortion alloc]init];
        inputPortion.codNum=0;
        inputPortion.hadNum=firstRoundHadNum;
        inputPortion.chipsNum=0;
        
        [self addRequestToDic:inputRequest time:(totalTimeUsage - fishTimeUsage) inputPortion:inputPortion];
        
        int firstPutCod = orderCodNum - endRoundCodNum;
        if (firstPutCod > 0) {
            InputPortion * inputPortion=[[InputPortion alloc]init];
            inputPortion.codNum=firstPutCod;
            inputPortion.hadNum=0;
            inputPortion.chipsNum=0;
            
            [self addRequestToDic:inputRequest time:(totalTimeUsage - fishTimeUsage) inputPortion:inputPortion];
        }
        
        if (endRoundHadNum > 0) {
            InputPortion * inputPortion=[[InputPortion alloc]init];
            inputPortion.codNum=0;
            inputPortion.hadNum=endRoundHadNum;
            inputPortion.chipsNum=0;
            
            [self addRequestToDic:inputRequest time:(totalTimeUsage - hadCookTime) inputPortion:inputPortion];
           
        }
        
        if (endRoundCodNum > 0) {
            InputPortion * inputPortion=[[InputPortion alloc]init];
            inputPortion.codNum=endRoundCodNum;
            inputPortion.hadNum=0;
            inputPortion.chipsNum=0;
            
            [self addRequestToDic:inputRequest time:(totalTimeUsage - codCookTime) inputPortion:inputPortion];
        }
        
    }
   }
-(void)addRequestToDic:(NSMutableDictionary*)dic time:(int)time inputPortion:(InputPortion*)inputPortion{
    
    if ([dic objectForKey:[NSString stringWithFormat:@"%d",time]] != nil) {
        [inputPortion addPortion:[dic objectForKey:[NSString stringWithFormat:@"%d",time]]];
    }
    else{
        [dic setObject:inputPortion forKey:[NSString stringWithFormat:@"%d",time]];
    }
}
@end
