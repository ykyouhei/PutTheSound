//
//  PTSRecommendAPIManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/14.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSRecommendAPIManager.h"

static PTSRecommendAPIManager *_sharedManager = nil;
// Request URL
static NSString *const requestURL = @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?term=AKON&country=JP&entity=musicTrack";
//static NSString *const requestURL = @"http://www1415uo.sakura.ne.jp/music/Recommend.php?lat=0&lon=0";

@implementation PTSRecommendAPIManager
+ (PTSRecommendAPIManager *)sharedManager {
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PTSRecommendAPIManager alloc] init];
    });
    return _sharedManager;
}
- (id)init
{
    self = [super init];
    if (self) {
        // 初期処理
    }
    return self;
}

- (void)request {
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
    
                               if(data){
                                   NSError *error = nil;
                                   NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                               
                                   if(!jsonObject && error){
                                       return;
                                   }
                                   
                                   //要素を削るなら高速列挙して抽出
                                   /*
                                   for(NSDictionary *dic in jsonObject[@"results"]){
                                   }
                                    */
                                   if([self.delegate respondsToSelector:@selector(didFinishLoardWithObject:)]){
                                       [self.delegate didFinishLoardWithObject:jsonObject[@"results"]];
                                   }
                               }
                               
                           }];
   
}
@end
