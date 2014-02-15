//
//  PTSViewController.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/14.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSViewController.h"
#import "PTSPlayListViewController.h"
#import "PTSSlideViewController.h"
#import "PTSMusicDataModel.h"
#import "PTSRecommendArtworkView.h"
#import "UIImage+ImageEffects.h"

#import <AFNetworking/UIImageView+AFNetworking.h>


@interface PTSViewController ()
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *toolView;

@property (nonatomic) MPMusicPlayerController *player;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) NSInteger playingAlbumIndex;

@property (weak, nonatomic) PTSMusicDataModel *dataModel;

@property (nonatomic) UIView *getView;
@property (nonatomic) UIView *getDetailView;

@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSString *selectedStringUrl;
@end

@implementation PTSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.playingAlbumIndex = -1;
    self.dataModel = [PTSMusicDataModel sharedManager];
    
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.type = 0;
    self.carousel.vertical = YES;
    
    
    
//    CAGradientLayer *pageGradient = [CAGradientLayer layer];
//    pageGradient.frame = self.toolView.bounds;
//    pageGradient.colors =
//    [NSArray arrayWithObjects:
//     (id)[UIColor colorWithWhite:0.0 alpha:0.9].CGColor,
//     (id)[UIColor colorWithWhite:0.0 alpha:0.6].CGColor,
//     (id)[UIColor colorWithWhite:0.0 alpha:0.05].CGColor, nil];
//    [self.toolView.layer insertSublayer:pageGradient atIndex:0];
    
    self.player = [MPMusicPlayerController iPodMusicPlayer];
    self.player.repeatMode = MPMusicRepeatModeAll;
    
    //getView
    [self p_setUpGetView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/***************************************************/
#pragma mark - iCarouselDataSource
/***************************************************/

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.dataModel.sectionPlayList.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(PTSRecommendArtworkView *)view
{
    //create new view if no view is available for recycling
    if (view == nil) {
        view = [PTSRecommendArtworkView instanceFromNib];
    }
    
    view.mainLabel.text = self.dataModel.sectionPlayList[index];
    MPMediaItemArtwork *artwork = self.dataModel.playListSongs[self.dataModel.sectionPlayList[index]][0][@"ARTWORK"];
    view.artworkImageView.image = [artwork imageWithSize:CGSizeMake(220.0f, 220.0f)];
    view.stateImageView.image = self.playingAlbumIndex == index ? [UIImage imageNamed:@"stop"] : [UIImage imageNamed:@"play"];
    
    return view;
}


/***************************************************/
#pragma mark - iCarouselDelegate
/***************************************************/

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    self.dataModel.selectedSong = self.dataModel.playListSongs[self.dataModel.sectionPlayList[index]][0];
    
    //　プレイリストでグループ化するクエリを生成
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    //　曲の一覧を取得
    NSArray *playlists = query.collections;
    
    //　全てのグループについてプレイリスト名を比較
    for (MPMediaItemCollection *playlist in playlists) {
        
        if([[playlist.items[0] valueForProperty: MPMediaItemPropertyAlbumTitle] isEqualToString:self.dataModel.selectedSong[@"ALUBUMTITLE"]]){
            [self.player setQueueWithItemCollection:playlist];
            break;
        }
    }
    
    
    PTSRecommendArtworkView *view = (PTSRecommendArtworkView *)[self.carousel itemViewAtIndex:index];
    view.stateImageView.image = [UIImage imageNamed:@"stop"];
    
    if (index == self.playingAlbumIndex) {
        [self.player pause];
        view.stateImageView.image = [UIImage imageNamed:@"play"];
        _isPlaying = NO;
        _playingAlbumIndex = -1;
    } else {
        [self.player play];
        view.stateImageView.image = [UIImage imageNamed:@"stop"];
        _isPlaying = YES;
        _playingAlbumIndex = index;
    }
    
    [self p_updateLabel];
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (self.carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value*2;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if(self.dataModel.playListSongs.count == 0){
        return;
    }
    
    MPMediaItemArtwork *artwork = self.dataModel.playListSongs[self.dataModel.sectionPlayList[carousel.currentItemIndex]][0][@"ARTWORK"];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionFade;
    
    [self.backgroundImageView.layer addAnimation:transition forKey:nil];
    self.backgroundImageView.image = [[artwork imageWithSize:self.backgroundImageView.frame.size] applyLightEffect];
}

/***************************************************/
#pragma mark - IBAction
/***************************************************/
- (IBAction)rightSwipeHandler:(id)sender {
    if (self.playingAlbumIndex != self.carousel.currentItemIndex) {
        return;
    }
    
    PTSRecommendArtworkView *view = (PTSRecommendArtworkView *)[self.carousel currentItemView];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = view.frame;
        frame.origin.x += 20;
        view.frame = frame;
        
        frame.origin.x -= 20;
        view.frame = frame;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self.player skipToPreviousItem];
            [self p_updateLabel];
        }
    }];
    
}
- (IBAction)leftSwipeHander:(id)sender {
    if (self.playingAlbumIndex != self.carousel.currentItemIndex) {
        return;
    }
    
    PTSRecommendArtworkView *view = (PTSRecommendArtworkView *)[self.carousel currentItemView];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = view.frame;
        frame.origin.x -= 20;
        view.frame = frame;
        
        frame.origin.x += 20;
        view.frame = frame;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self.player skipToNextItem];
            [self p_updateLabel];
        }
    }];
}

- (IBAction)tapNowHandler:(id)sender
{
    if (self.playingAlbumIndex == -1) {
        return;
    }
    
    [self.carousel scrollToItemAtIndex:self.playingAlbumIndex duration:0.1];
}


- (IBAction)didPushOpenRecommend:(id)sender {
    if (self.slideVC.isClosed) {
        [self.slideVC shouldOpenLeft];
    } else {
        [self.slideVC shouldClose];
    }
}
- (IBAction)didPushOpenSettings:(id)sender {
    if (self.slideVC.isClosed) {
        [self.slideVC shouldOpenRight];
    } else {
        [self.slideVC shouldClose];
    }
}

- (IBAction)didPushGetButton:(id)sender {
    [[PTSMusicStationAPIManager sharedManager] setDelegate:self];
    [[PTSMusicStationAPIManager sharedManager] getRequest];
}


/***************************************************/
#pragma mark - PrivateMethods
/***************************************************/

- (void)p_setUpButton {
    if(_isPlaying){
        [self.player pause];
//        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        _isPlaying = NO;
    }
    else{
        [self.player play];
//        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        _isPlaying = YES;
    }
}


- (void)p_updateLabel {
    if(_isPlaying){
        
        MPMediaItem *song = [self.player nowPlayingItem];
        NSDictionary *songDic = @{@"ID":[song valueForProperty: MPMediaItemPropertyPersistentID],
                                  @"TITLE":[song valueForProperty: MPMediaItemPropertyTitle],
                                  @"ARTIST":[song valueForProperty: MPMediaItemPropertyArtist],
                                  @"ALUBUMTITLE":[song valueForProperty: MPMediaItemPropertyAlbumTitle],
                                  @"ARTWORK":[song valueForProperty: MPMediaItemPropertyArtwork]};
        
        self.mainLabel.text = songDic[@"TITLE"];
        self.detailLabel.text = songDic[@"ALUBUMTITLE"];
    }
}

- (void)p_setUpGetView {
    //ベース
    self.getView = [UIView new];
    self.getView.frame = CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height / 2.0f);
    self.getView.backgroundColor = [UIColor clearColor];
    
    //ブラー用
    UIToolbar *toolBar = [UIToolbar new];
    toolBar.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height / 2.0f);
    toolBar.alpha = 0.99f;
    
    //つまみ
    UIImage *image = [UIImage imageNamed:@"pull.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake((_getView.frame.size.width - image.size.width) / 2.0f,
                                 5.0f, image.size.width, image.size.height);
    
    //閉じるボタン
    UIButton *button = [[UIButton alloc] initWithFrame:imageView.frame];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(p_closeGetView) forControlEvents:UIControlEventTouchUpInside];
    
    //要素
    UINib *nib = [UINib nibWithNibName:@"View" bundle:nil];
    self.getDetailView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    CGRect rect = _getDetailView.frame;
    rect.origin.y = _getView.frame.size.height - _getDetailView.frame.size.height -20.0f;
    _getDetailView.frame = rect;
    
    //角丸
    self.getView.clipsToBounds = YES;
    self.getView.layer.cornerRadius = 10;
    toolBar.clipsToBounds = YES;
    toolBar.layer.cornerRadius = 10;
    
    [toolBar addSubview:_getDetailView];
    [toolBar addSubview:button];
    [toolBar addSubview:imageView];
    [self.getView addSubview:toolBar];
    [self.view addSubview:_getView];
}

- (void)p_openGetView {
    CGRect frame = self.getView.frame;
    frame.origin.y = self.view.frame.size.height - self.getView.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.getView.frame = frame;
    
    } completion:^(BOOL finished) {
        if (finished) {

        }
    }];
}

- (void)p_closeGetView {
    CGRect frame = self.getView.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.getView.frame = frame;;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self.audioPlayer pause];
        }
    }];
}

- (void)p_updateGetView{
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

#pragma mark - PTSMusicStationAPIManagerDelegate
- (void)didFinishLoardWithStationSongObject:(NSArray*)array{
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        //駅名
        UILabel *stationLabel = (UILabel*)[_getDetailView viewWithTag:10];
        stationLabel.text = @"六本木";

        //アルバム名
        UILabel *alubumLabel = (UILabel*)[_getDetailView viewWithTag:30];
        alubumLabel.text = array[0][@"collectionName"];
        
        //曲名
        UILabel *songLabel = (UILabel*)[_getDetailView viewWithTag:40];
        songLabel.text = array[0][@"trackName"];
        //ゲット文言

        //アルバムジャケット
        SCOUtilImageView *imageView = (SCOUtilImageView*)[_getDetailView viewWithTag:20];
        imageView.delegate = self;
        imageView.songUrl = array[0][@"previewUrl"];
        
        // 画像取得（UIImage+AFNetworking）
        __weak SCOUtilImageView *weakImageView = imageView;
        NSURL *url = [NSURL URLWithString:array[0][@"artworkUrl100"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            if (weakImageView) {
                weakImageView.image = image;
                [self p_openGetView];
                [self p_setUpLabelWithImageView:weakImageView isPlaying:YES];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];

    });
}
@end
