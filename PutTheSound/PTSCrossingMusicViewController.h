//
//  PTSCrossingMusicViewController.h
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/16.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCOUtilImageView.h"

@interface PTSCrossingMusicViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,SCOUtilImageViewDelegate>
- (void)updateTableView;
@end
