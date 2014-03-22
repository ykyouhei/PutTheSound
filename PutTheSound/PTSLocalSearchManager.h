//
//  PTSLocalSearchManager.h
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/23.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^RequestLocationsResultHandler)(NSArray *locations, NSError *error);

@interface PTSLocalSearchManager : NSObject
<CLLocationManagerDelegate>

+ (PTSLocalSearchManager *)sharedManager;
- (void)requestNearestLocations:(RequestLocationsResultHandler)completion;

@end
