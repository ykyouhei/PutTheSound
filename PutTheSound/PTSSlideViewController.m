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

@end
