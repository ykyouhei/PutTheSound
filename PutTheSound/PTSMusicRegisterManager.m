//
//  PTSMusicRegisterManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/04/29.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSMusicRegisterManager.h"
//USERID取得用
#import "PTSUtilManager.h"

static PTSMusicRegisterManager *_sharedInstance;

static NSString *const baseRegisterUrl = @"http://www5250up.sakura.ne.jp:3000/api/onput/music_history";
/*
 curl http://www5250up.sakura.ne.jp:3000/api/onput/music_history -X POST -d "user=hoge" -d "title=あいうえお" -d "artist=かきくけこ" -d "genre=anime"
 */
/*
 ・user（必須）　UUID
 ・track（必須）音楽のタイトル
 ・artist（任意）歌手
 ・collection（任意）アルバム名
 ・lat（任意）
 ・lon（任意）
 */
@implementation PTSMusicRegisterManager

+ (PTSMusicRegisterManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PTSMusicRegisterManager alloc] initSharedInstance];
    });
    return _sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// TODO: 位置情報付与
- (void)requestRegisterMusicArtist:(NSString*)artistName
                         songTitle:(NSString*)songTitle
                         albumTitle:(NSString*)albumTitle
                             genre:(NSString*)genre
                           WithLat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon
{
    // 必要情報がなかったら登録処理を行わない
    if(artistName.length < 1 ||
       songTitle.length < 1 ||
       genre.length < 1){
        return;
    }
    
    
    NSString *urlString = baseRegisterUrl;//[NSString stringWithFormat:kGetLocationsURLTemplate, lat, fabs(lon)];
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    //パラメータを作成
    NSString *userid = [PTSUtilManager getUserID];
    NSString *body = [NSString stringWithFormat:@"user=%@&track=%@&artist=%@&album=%@&genre=%@&lat=%f&lon=%f", userid, [self p_uriEncodeForString:songTitle], [self p_uriEncodeForString:artistName], [self p_uriEncodeForString:albumTitle],[self p_uriEncodeForString:genre], lat, lon];
    
    NSLog(@"request body:%@",body);
    
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
        
        if(data){
        }
        
    }];
}

- (NSString*)p_uriEncodeForString:(NSString *)str {
    return ((NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (CFStringRef)str,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingUTF8)));
}
@end
