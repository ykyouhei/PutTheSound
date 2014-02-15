//
//  PTSMusicStationAPIManager.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/16.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTSMusicStationAPIManagerDelegate <NSObject>
- (void)didFinishLoardWithStationSongObject:(NSArray*)array;
@end

@interface PTSMusicStationAPIManager : NSObject
@property (nonatomic,weak) id<PTSMusicStationAPIManagerDelegate>delegate;
+ (PTSMusicStationAPIManager *)sharedManager;
- (void)getRequest;
@end
