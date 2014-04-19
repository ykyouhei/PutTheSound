//
//  PTSTimelineManager.m
//  PutTheSound
//
//  Created by Daisuke Shibata on 2014/03/17.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSTimelineManager.h"

static PTSTimelineManager *_sharedManager = nil;
static NSString *const requestURL = @"http://www1415uo.sakura.ne.jp/music/GetTimeline.php";

@implementation PTSTimelineManager

+ (PTSTimelineManager *) sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PTSTimelineManager alloc] init];
    });
    return _sharedManager;
    
}

- (void)request
{
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               if(data){
                                   NSError *error = nil;
                                   NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                   
                                   if(!jsonObject || error){
                                       return;
                                   }
                                   
                                   NSMutableArray *resultArray = [NSMutableArray new];
                                   NSString *dateString = @"";
                                   
                                   for (NSMutableDictionary *dic in jsonObject) {
                                       if (dic) {
                                           if ([dic[@"station"]  isEqual: @""] || dic[@"station"] == nil) {
                                               continue;
                                           }
                                           
                                           NSRange searchResult = [dic[@"station"] rangeOfString:@"null"];
                                           if(searchResult.location != NSNotFound){
                                               continue;
                                           }
                                           
                                           NSMutableDictionary *parsedDic = [NSMutableDictionary dictionary];
                                           
                                           [parsedDic setObject:[self stationLabelText:dic] forKey:@"text"];
                                           [parsedDic setObject:dic[@"type"] forKey:@"type"];
                                           
                                           NSDate* date = [NSDate dateWithTimeIntervalSince1970:[dic[@"time"] doubleValue]];
                                           NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                           [formatter setLocale:[NSLocale systemLocale]];
                                           [formatter setDateFormat:@"MM/dd"];
                                           NSString *dateStr = [formatter stringFromDate:date];

                                           if (![dateStr isEqualToString:dateString]) {
                                               if ([dateString isEqualToString:@""]) {
                                                   dateString = dateStr;
                                               } else {
                                                   NSDictionary *dateDic = @{@"type"        : @"DateCell",
                                                                             @"date"        : dateString};
                                                   [resultArray addObject:dateDic];
                                                   dateString = dateStr;
                                               }
                                           }
                                           [resultArray addObject:parsedDic];
                                       }
                                   }
                                   NSDictionary *dateDic = @{@"type" : @"DateCell",
                                                             @"date" : dateString};
                                   [resultArray addObject:dateDic];

                                   NSArray *array = [[resultArray reverseObjectEnumerator] allObjects];
                                   if ([self.delegate respondsToSelector:@selector(didFinishLoardWithObject:)]) {
                                       [self.delegate didFinishLoardWithObject:array];
                                   }
                               }
                           }];
    
}

- (NSString*)dateString:(NSString*)dateStr
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[dateStr doubleValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setDateFormat:@"HH:ss"];
    return [formatter stringFromDate:date];
}

- (NSMutableAttributedString*)stationLabelText:(NSMutableDictionary*)dic
{
    NSString *time = [self dateString:dic[@"time"]];
    NSString *stationName = [NSString stringWithFormat:@"%@", dic[@"station"]];
    NSRange range = [stationName rangeOfString:@"_"];
    if (range.location != NSNotFound) {
        NSString *lineName = [stationName substringToIndex:range.location];
        stationName = [lineName stringByAppendingString:[stationName substringFromIndex:range.location + 1]];
    }
        
    if ([dic[@"type"] isEqualToString:@"put"]) {
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@に曲が置かれました\n%@", stationName, time]];
        
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont boldSystemFontOfSize:14.0f]
                        range:NSMakeRange(0, stationName.length)];
        
        NSRange timeRange = [[attrStr string] rangeOfString:time];
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:13.0f]
                        range:timeRange];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor lightGrayColor]
                        range:timeRange];

        return attrStr;
    } else {
        
        NSString *musicName   = dic[@"title"];
        
         NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@で\n%@\nが拾われました    %@", stationName, musicName, time]];
        
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont boldSystemFontOfSize:14.0f]
                        range:NSMakeRange(0, stationName.length)];
        
        NSRange musicRange = [[attrStr string] rangeOfString:musicName];
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont boldSystemFontOfSize:14.0f]
                        range:musicRange];
        
        NSRange timeRange = [[attrStr string] rangeOfString:time];
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:13.0f]
                        range:timeRange];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor lightGrayColor]
                        range:timeRange];
        return attrStr;
    }
}

@end
