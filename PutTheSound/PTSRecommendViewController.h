//
//  PTSRecommendViewController.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/14.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PTSRecommendAPIManager.h"
#import "SCOUtilImageView.h"

@interface PTSRecommendViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,PTSRecommendAPIManagerDelegate,SCOUtilImageViewDelegate>

@end
