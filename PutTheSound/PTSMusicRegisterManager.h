//
//  PTSMusicRegisterManager.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/04/29.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PTSMusicRegisterManager : NSObject
+ (PTSMusicRegisterManager *)sharedManager;
- (void)requestRegisterMusicArtist:(NSString*)artist songTitle:(NSString*)songTitle albumTitle:(NSString*)albumTitle genre:(NSString*)genre WithLat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon;
@end
