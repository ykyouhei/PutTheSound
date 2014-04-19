//
//  PTSTimelineManager.h
//  PutTheSound
//
//  Created by Daisuke Shibata on 2014/03/17.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PTSTimelineAPIDelegate <NSObject>
- (void)didFinishLoardWithObject:(NSArray*)array;
@end

@interface PTSTimelineManager : NSObject

@property (nonatomic, weak) id<PTSTimelineAPIDelegate>delegate;
+ (PTSTimelineManager *) sharedManager;
- (void)request;
@end
