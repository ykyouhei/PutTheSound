//
//  PTSRecommendAPIManager.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/14.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTSRecommendAPIManagerDelegate <NSObject>
- (void)didFinishLoardWithObject:(NSArray*)array;
@end

@interface PTSRecommendAPIManager : NSObject
@property (nonatomic,weak) id<PTSRecommendAPIManagerDelegate>delegate;
+ (PTSRecommendAPIManager *)sharedManager;
- (void)request;
@end
