//
//  PTSMusicStationAPIManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/16.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSMusicStationAPIManager.h"

static PTSMusicStationAPIManager *_sharedManager = nil;
// Request URL
//static NSString *const requestURL = @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?term=AKON&country=JP&entity=musicTrack";
//static NSString *const requestURL = @"http://www1415uo.sakura.ne.jp/music/Recommend.php?lat=0&lon=0";
static NSString *const requestURL =@"http://www1415uo.sakura.ne.jp/music/StationMusic.php?action=get&station=";

@implementation PTSMusicStationAPIManager
+ (PTSMusicStationAPIManager *)sharedManager {
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PTSMusicStationAPIManager alloc] init];
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

- (void)getRequest{
    NSString *stringUrl = @"http://www1415uo.sakura.ne.jp/music/StationMusic.php?action=get&station=%E5%A4%A7%E6%B1%9F%E6%88%B8%E7%B7%9A_%E4%BB%A3%E3%80%85%E6%9C%A8";//[NSString stringWithFormat:@"%@%@",requestURL,@"大江戸線_代々木"];
    NSURL *url = [NSURL URLWithString:stringUrl];
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
                                   if([self.delegate respondsToSelector:@selector(didFinishLoardWithStationSongObject:)]){
                                       [self.delegate didFinishLoardWithStationSongObject:jsonObject[@"results"]];
                                   }
                               }
                               
                           }];
    
}
@end
