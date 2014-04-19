//
//  PTSTimelineViewController.h
//  PutTheSound
//
//  Created by Daisuke Shibata on 2014/03/16.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PTSTimelineManager.h"

@interface PTSTimelineViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PTSTimelineAPIDelegate>

@end
