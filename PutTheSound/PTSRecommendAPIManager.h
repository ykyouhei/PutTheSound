//
//  PTSRecommendAPIManager.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/14.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTSRecommendAPIManager : NSObject
+ (PTSRecommendAPIManager *)sharedManager;
- (void)request;
@end
