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
                                   
                                   for(NSDictionary *dic in jsonObject[@"results"]){
                                   
                                   }
                               }
                               
                           }];
   
}
@end
