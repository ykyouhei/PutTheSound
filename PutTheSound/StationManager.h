//
//  StationManager.h
//  GetStations
//
//  Created by 山口 恭兵 on 2014/02/14.
//  Copyright (c) 2014年 Kyouhei Yamaguchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^RequestStationsResultHandler)(NSArray *stations, NSError *error);

/**
 *  駅情報取得関連クラス
 */
@interface StationManager : NSObject
<CLLocationManagerDelegate>

+ (StationManager *)sharedManager;
- (void)requestNearestStations:(RequestStationsResultHandler)completion;

@end
