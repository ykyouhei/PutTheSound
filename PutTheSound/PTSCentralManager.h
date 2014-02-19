//
//  PTSCentralManager.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/19.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PTSCentralManager : NSObject <CLLocationManagerDelegate>
+ (PTSCentralManager *)sharedManager;
- (void)startMonitoring;
- (void)stopMonitoring;
@end
