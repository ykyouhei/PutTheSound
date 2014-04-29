//
//  PTSRecommendViewController.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/14.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSRecommendViewController.h"
#import "PTSRecommendArtworkView.h"
#import "PTSSlideViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface PTSRecommendViewController ()
@property (nonatomic) NSArray *recommendItems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSString *selectedStringUrl;
@end

@implementation PTSRecommendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    [self p_indicatorShow:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    // scrollToTopの制御通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_setScrollsToTopNo)
                                                 name:openRightNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_setScrollsToTopYes)
                                                 name:openLeftNotification
                                               object:nil];

    [[PTSRecommendAPIManager sharedManager] setDelegate:self];
    [[PTSRecommendAPIManager sharedManager] request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods
- (void)p_indicatorShow:(BOOL)flag {
    if(flag){
        self.indicatorView.hidden = NO;
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView*)[_indicatorView viewWithTag:300];
        [indicatorView startAnimating];
        [self.tableView bringSubviewToFront:_indicatorView];
    }
    else{
        self.indicatorView.hidden = YES;
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView*)[_indicatorView viewWithTag:300];
        [indicatorView stopAnimating];
        [self.tableView sendSubviewToBack:_indicatorView];
        [self.view bringSubviewToFront:_tableView];
    }
}

- (void)p_setUpLabelWithImageView:(SCOUtilImageView*)imageView isPlaying:(BOOL)flag {
    imageView.isPlaying = flag;
    [imageView setNeedsLayout];
}

- (void)p_showImageViewIndicator:(SCOUtilImageView*)imageView show:(BOOL)flag {
    if(flag){
        [imageView showPlayView:NO];
    }
    else{
        [imageView showPlayView:YES];
    }
}

- (void)p_showRoadingIndicator:(SCOUtilImageView*)imageView show:(BOOL)flag {
    if(flag){
        [imageView showPlayIndicatorView:NO];
    }
    else{
        [imageView showPlayIndicatorView:YES];
    }
}
#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return _recommendItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecommendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *alubumLabel = (UILabel*)[cell viewWithTag:500];
    alubumLabel.text = _recommendItems[indexPath.row][@"collectionName"];
    
    UILabel *mainLabel = (UILabel*)[cell viewWithTag:200];
    mainLabel.text = _recommendItems[indexPath.row][@"trackName"];
    
    SCOUtilImageView *imageView = (SCOUtilImageView*)[cell viewWithTag:100];
    imageView.delegate = self;
    imageView.songUrl = _recommendItems[indexPath.row][@"previewUrl"];
    
    //DLButton
    UIButton *downLoadButton = (UIButton*)[cell viewWithTag:900];
    downLoadButton.tag = indexPath.row;
    
    // 画像取得（UIImage+AFNetworking）
    __weak SCOUtilImageView *weakImageView = imageView;
    NSString *urlString = [_recommendItems[indexPath.row][@"artworkUrl100"] stringByReplacingOccurrencesOfString:@"100x100" withString:@"200x200"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (weakImageView) {
            weakImageView.image = image;
            [self p_setUpLabelWithImageView:weakImageView isPlaying:YES];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];

    return cell;
}

#pragma mark - PTSRecommendAPIManagerDelegate
- (void)didFinishLoardWithObject:(NSArray *)array {
    self.recommendItems = array;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self p_indicatorShow:NO];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark - SCOUtilImageViewDelegate
-(void)didPushImageViewWithDictionary:(NSDictionary *)dictionary {
    NSString *stringUrl = dictionary[@"songUrl"];
    if([_selectedStringUrl isEqualToString:stringUrl]){

        dispatch_async(dispatch_get_main_queue(), ^(){
            [self p_showRoadingIndicator:dictionary[@"object"] show:YES];
        });

        if(_audioPlayer.playing){
            [self.audioPlayer pause];
            [self p_setUpLabelWithImageView:dictionary[@"object"] isPlaying:YES];
            return;
        }
        else{
            [self p_setUpLabelWithImageView:dictionary[@"object"] isPlaying:NO];
            [self.audioPlayer play];
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self p_showRoadingIndicator:dictionary[@"object"] show:NO];
    });
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (data){
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
            [self.audioPlayer play];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self p_showRoadingIndicator:dictionary[@"object"] show:YES];
            });
        }
    }];
    
    [self setSelectedStringUrl:stringUrl];
    [self p_setUpLabelWithImageView:dictionary[@"object"] isPlaying:NO];
}

#pragma mark - IBAction
- (IBAction)didPushReturnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didPushDownLoadButton:(id)sender {
    NSString *stringUrl = _recommendItems[((UIButton*)sender).tag][@"trackViewUrl"];
    // 文字列を置換
    NSString *result = [stringUrl stringByReplacingOccurrencesOfString:@"https" withString:@"itmss"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
}

- (IBAction)didPushSettingsButton:(id)sender {
    [self.parentViewController performSegueWithIdentifier:@"showSettings" sender:self];
}


#pragma mark - Notification
- (void)p_setScrollsToTopNo
{
    [self.tableView setScrollsToTop:NO];
}
- (void)p_setScrollsToTopYes
{
    [self.tableView setScrollsToTop:YES];
    [[PTSRecommendAPIManager sharedManager] setDelegate:self];
    [[PTSRecommendAPIManager sharedManager] request];

}
@end
