//
//  PTSSlideViewController.h
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/** Notification
 */
extern NSString *const openLeftNotification;
extern NSString *const openRightNotification;

/**
 *  Slideを管理するViewController
 */
@interface PTSSlideViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *customStatusBarView;
@property (weak, nonatomic) IBOutlet UILabel *animationLabel;

@property (assign, nonatomic, getter= isClosed) BOOL closed;

- (void)shouldOpenLeft;
- (void)shouldOpenRight;
- (void)shouldClose;

@end
