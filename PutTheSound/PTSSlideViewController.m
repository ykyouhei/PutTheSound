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
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@end

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
    [self.view sendSubviewToBack:self.settingsView];
    
    CGRect frame = self.mainView.frame;
    frame.origin.x = self.recommendView.frame.size.width;
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.frame = frame;
    }];
    self.closed = NO;
}

- (void)shouldOpenRight
{
    [self.view sendSubviewToBack:self.recommendView];
    
    CGRect frame = self.mainView.frame;
    frame.origin.x = -self.recommendView.frame.size.width;
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.frame = frame;
    }];
    self.closed = NO;
}

- (void)shouldClose
{
    CGRect frame = self.mainView.frame;
    frame.origin.x = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.frame = frame;
    }];
    self.closed = YES;
}

@end
