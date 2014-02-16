//
//  PTSCrossingMusicManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/16.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSCrossingMusicManager.h"

@interface PTSCrossingMusicManager()
@property (nonatomic) NSMutableArray *songs;
@end

static PTSCrossingMusicManager *_sharedManager = nil;
// Request URL
//static NSString *const requestURL = @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?term=AKON&country=JP&entity=musicTrack";
//static NSString *const requestURL = @"http://www1415uo.sakura.ne.jp/music/Recommend.php?lat=0&lon=0";
//static NSString *const requestURL =@"http://www1415uo.sakura.ne.jp/music/StationMusic.php?action=get&station=";

@implementation PTSCrossingMusicManager
+ (PTSCrossingMusicManager *)sharedManager {
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PTSCrossingMusicManager alloc] init];
    });
    return _sharedManager;
}
- (id)init
{
    self = [super init];
    if (self) {
        // 初期処理
        self.songs = [NSMutableArray array];
    }
    return self;
}

- (void)addSongObject:(NSDictionary*)dic {
    if(!dic){
        return;
    }
    
    [self.songs addObject:dic];
}

- (NSArray*)getSongsArray {
    return _songs;
}

- (void)resetSongsArray {
    self.songs = [NSMutableArray array];
}

- (BOOL)containSongID:(NSString*)string {
    for(NSDictionary *dic in _songs){
        if([string isEqualToString:dic[@"ID"]]){
            return YES;
        }
    }
    
    return NO;
}

@end
