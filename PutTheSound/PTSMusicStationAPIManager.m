//
//  PTSMusicStationAPIManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/16.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSMusicStationAPIManager.h"
#import "StationManager.h"

static PTSMusicStationAPIManager *_sharedManager = nil;
// Request URL
//static NSString *const requestURL = @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?term=AKON&country=JP&entity=musicTrack";
//static NSString *const requestURL = @"http://www1415uo.sakura.ne.jp/music/Recommend.php?lat=0&lon=0";
static NSString *const requestURL =@"http://www1415uo.sakura.ne.jp/music/StationMusic.php?action=get&station=%@";
static NSString *const putRequestURL = @"http://www1415uo.sakura.ne.jp/music/StationMusic.php?action=put&station=%@&title=%@&artist=%@";

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
    [[StationManager sharedManager] requestNearestStations:^(NSArray *stations, NSError *error) {
        NSString *station = [NSString stringWithFormat:@"%@_%@", stations[0][@"line"], stations[0][@"name"]];
        NSString *Estation = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                        NULL,
                                                                                        (CFStringRef)station,
                                                                                        NULL,
                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                        kCFStringEncodingUTF8 ));
        NSString *stringUrl = [NSString stringWithFormat:requestURL, Estation];//[NSString stringWithFormat:@"%@%@",requestURL,@"大江戸線_代々木"];
        NSURL *url = [NSURL URLWithString:stringUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                               completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                                   
                                   if(data.length != 0){
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
                                       if([self.delegate respondsToSelector:@selector(didFinishLoardWithStationSongObject:station:)]){
                                           [self.delegate didFinishLoardWithStationSongObject:jsonObject[@"results"] station:station];
                                       }
                                   } else {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if ([self.delegate respondsToSelector:@selector(didErrorResponse)]) {
                                               
                                               [self.delegate didErrorResponse];
                                           }
                                       });
                                   }
                                   
                               }];
    }];
    
    
    
    
}

- (void)putRequestWithStation:(NSString *)station title:(NSString *)title artist:(NSString *)artist
{
    NSString *Estation = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                    NULL,
                                                                                    (CFStringRef)station,
                                                                                    NULL,
                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                    kCFStringEncodingUTF8 ));
    NSString *Etitle = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                    NULL,
                                                                                    (CFStringRef)title,
                                                                                    NULL,
                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                    kCFStringEncodingUTF8 ));
    NSString *Eartist = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                    NULL,
                                                                                    (CFStringRef)artist,
                                                                                    NULL,
                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                    kCFStringEncodingUTF8 ));
    
    NSString *stringUrl = [NSString stringWithFormat:putRequestURL, Estation, Etitle, Eartist];
    
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if([self.delegate respondsToSelector:@selector(didFinishPutMusic)]){
                                       [self.delegate didFinishPutMusic];
                                   }
                                   NSString *message = [NSString stringWithFormat:@"駅：%@\n曲名：%@\nアーティスト：%@", station, title, artist];
                                   OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:@"SUCCESS！"
                                                                                               message: message];
                                   [ghastly show];
                               });
                           }];
}

@end
