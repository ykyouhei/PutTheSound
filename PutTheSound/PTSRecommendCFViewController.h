//
//  PTSRecommendCFViewController.h
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel/iCarousel.h>
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PTSRecommendAPIManager.h"
#import "SCOUtilImageView.h"

@interface PTSRecommendCFViewController : UIViewController
<PTSRecommendAPIManagerDelegate,SCOUtilImageViewDelegate, iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) IBOutlet iCarousel *carousel;

@end
