//
//  PTSPeripheralManager.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/19.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PTSPeripheralManager : NSObject <CBPeripheralManagerDelegate>
+ (PTSPeripheralManager *)sharedManager;
- (void)startAdvertising:(NSString*)artistName withAlubumName:(NSString*)alubumNAme;
- (void)stopAdvertising;
@end
