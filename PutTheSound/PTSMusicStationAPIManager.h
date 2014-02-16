//
//  PTSMusicStationAPIManager.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/16.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OLGhostAlertView.h>

@protocol PTSMusicStationAPIManagerDelegate <NSObject>
- (void)didFinishLoardWithStationSongObject:(NSArray*)array station:(NSString *)station;
- (void)didFinishPutMusic;
- (void)didErrorResponse;
@end

@interface PTSMusicStationAPIManager : NSObject
@property (nonatomic,weak) id<PTSMusicStationAPIManagerDelegate>delegate;
+ (PTSMusicStationAPIManager *)sharedManager;
- (void)getRequest;
- (void)putRequestWithStation:(NSString *)station title:(NSString *)title artist:(NSString *)artist;
@end
