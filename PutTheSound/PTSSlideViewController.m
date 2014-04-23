//
//  PTSSlideViewController.m
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSSlideViewController.h"

#import "PTSViewController.h"
#import "PTSRecommendViewController.h"

@interface PTSSlideViewController ()
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *recommendView;
@property (weak, nonatomic) IBOutlet UIView *timeLineView;
@property (nonatomic) BOOL isHiddenStatusBar;
@end

// つうち
NSString *const openLeftNotification = @"openLeft";
NSString *const openRightNotification = @"openRight";

@implementation PTSSlideViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _closed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mainView.layer.shadowOpacity = 0.2; // 濃さを指定
    self.mainView.layer.shadowOffset = CGSizeMake(0.0, 0.0); // 影までの距離を指定
    self.isHiddenStatusBar = YES;
    self.customStatusBarView.alpha = 0.0f;
    self.animationLabel.alpha = 0.0f;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_updateStatusBar:)
                                                 name:@"RefreshStatusBar"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedPlayList"]) {
        PTSViewController *vc = segue.destinationViewController;
        vc.slideVC = self;
    }
}


/***************************************************/
#pragma mark - Public Method
/***************************************************/
- (void)shouldOpenLeft
{
    CGRect frame = self.mainView.frame;
    frame.origin.x = self.recommendView.frame.size.width;
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.frame = frame;
    } completion:^(BOOL finished) {
        if (finished) {
             [[NSNotificationCenter defaultCenter] postNotificationName:openLeftNotification object:self userInfo:nil];
            self.closed = NO;
        }
    }];
}

- (void)shouldOpenRight
{
    CGRect frame = self.mainView.frame;
    frame.origin.x = -self.recommendView.frame.size.width;
    
    CGRect frame2 = self.recommendView.frame;
    frame2.origin.x = frame.origin.x;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.frame = frame;
        self.recommendView.frame = frame2;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:openRightNotification object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startTimer" object:self userInfo:nil];
            self.closed = NO;
        }
    }];
}

- (void)shouldClose
{
    CGRect frame = self.mainView.frame;
    frame.origin.x = 0;
    
    CGRect frame2 = self.recommendView.frame;
    frame2.origin.x = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.frame = frame;
        self.recommendView.frame = frame2;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimer" object:self userInfo:nil];
            self.closed = YES;
        }
    }];
}

// statusbar 
- (BOOL)prefersStatusBarHidden
{
    return _isHiddenStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    // ステータスバーの文字色を白に指定
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (void)p_updateStatusBar:(NSNotification *)notification
{
    //NSLog(@"%@",notification.userInfo[@"SongTitle"]);
    NSString *string = notification.userInfo[@"SongTitle"];
    [self p_fadeStartAnimationCustomStatusBarView:string];
}

- (void)p_fadeStartAnimationCustomStatusBarView:(NSString*)string
{
    [UIView animateWithDuration:0.5f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.animationLabel.text = @"";
                         self.animationLabel.alpha = 1.0f;
                         self.customStatusBarView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {
                         // アニメーション終了時
                         self.isHiddenStatusBar = YES;
                         [self setNeedsStatusBarAppearanceUpdate];
                         [self p_scrollAnimationLabel:string];
                     }];

}

- (void)p_scrollAnimationLabel:(NSString*)string
{
    NSDictionary *attributeDic = @{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                   NSForegroundColorAttributeName:[UIColor whiteColor],
                                   NSStrokeColorAttributeName:[UIColor orangeColor],
                                   NSStrokeWidthAttributeName:@-2.0f};
    CGSize size = [string boundingRectWithSize:CGSizeMake(1000.0f, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                    attributes:attributeDic
                                       context:nil].size;
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:string
                                                                 attributes:attributeDic];
    self.animationLabel.frame = CGRectMake(320.0f, 0.0f, size.width, 20.0f);
    self.animationLabel.attributedText = aString;
    //self.animationLabel.text = string;
    // アニメーション
    [UIView animateWithDuration:size.width/60.0f
                          delay:0.2f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.animationLabel.frame = CGRectMake(-size.width, 0.0f, size.width, 20.0f);
                         
                     } completion:^(BOOL finished) {
                         // アニメーション終了時
                         [self p_downAnimationLabel];
                     }];
}

- (void)p_downAnimationLabel
{
    CGSize customStatusBarViewsize = _customStatusBarView.frame.size;
    CGSize animationLabelsize = _animationLabel.frame.size;
    CGFloat originSize = (customStatusBarViewsize.width - animationLabelsize.width) / 2.0f;
    
    self.animationLabel.frame = CGRectMake(originSize, -20.0f, animationLabelsize.width, 20.0f);
    [UIView animateWithDuration:0.5f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.animationLabel.frame = CGRectMake(originSize, 0.0f, animationLabelsize.width, 20.0f);
                         
                     } completion:^(BOOL finished) {
                         // アニメーション終了時
                         [self p_fadeEndAnimationCustomStatusBarView];
                     }];

}

- (void)p_fadeEndAnimationCustomStatusBarView
{
    [UIView animateWithDuration:0.5f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.animationLabel.alpha = 0.0f;
                         self.customStatusBarView.alpha = 0.0f;

                     } completion:^(BOOL finished) {
                         // アニメーション終了時
                         self.isHiddenStatusBar = NO;
                         [self setNeedsStatusBarAppearanceUpdate];
                     }];

}
@end
