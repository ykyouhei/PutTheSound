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
//#import "StationManager.h"
#import "PTSLocalSearchManager.h"
#import "UIImage+ImageEffects.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "PTSPeripheralManager.h"
#import "CentralManager.h"

//曲情報登録用
#import "PTSMusicRegisterManager.h"
//social用
#import <Social/Social.h>
#import <Accounts/Accounts.h>


@interface PTSViewController ()
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *toolView;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic) MPMusicPlayerController *player;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) NSInteger playingAlbumIndex;

@property (weak, nonatomic) PTSMusicDataModel *dataModel;

@property (nonatomic) UIView *controllView;
@property (nonatomic) UIView *getDetailView;
@property (nonatomic) UIView *putDetailView;

@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSString *selectedStringUrl;

@property (nonatomic) NSArray *nearestLocations;
@property (nonatomic) NSString *selectedLocationName;

@property (nonatomic) NSDateFormatter *formatter;
@property (nonatomic, strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIView *musicControllView;
@property (assign, nonatomic, getter = isDragging) BOOL dragging;

@end

@implementation PTSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"mm:ss"];
    
    self.playingAlbumIndex = -1;
    self.dataModel = [PTSMusicDataModel sharedManager];
    
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.type = 0;
    self.carousel.vertical = YES;
    self.dragging = NO;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                              target:self
                                            selector:@selector(musicCount)
                                            userInfo:nil
                                             repeats:YES];
    [_timer fire];
    
    
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
    [self p_setUpControllView];
    [self p_setUpGetView];
    [self p_setUpPutView];
    
    //iBeacon
    [[PTSPeripheralManager sharedManager] startAdvertising:@"" withAlubumName:@""];
    [[CentralManager sharedManager] startMonitoring];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_nowPlayingItemChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:self.player];
    
    [self.player beginGeneratingPlaybackNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player endGeneratingPlaybackNotifications];
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
- (IBAction)didPushPostButton:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
    as.title = @"選択してください";
    [as addButtonWithTitle:@"LINEに投稿"];
    [as addButtonWithTitle:@"Twitterに投稿"];
    [as addButtonWithTitle:@"Facebookに投稿"];
    [as addButtonWithTitle:@"キャンセル"];
    as.cancelButtonIndex = 3;
    [as showInView:self.view];
}


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
            //iBeacon
            //[[PTSPeripheralManager sharedManager] startAdvertising:[self p_getNowArtist] withAlubumName:[self p_getNowAlubum]];
            //[self p_updateStatusBar];
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
            //iBeacon
            //[[PTSPeripheralManager sharedManager] startAdvertising:[self p_getNowArtist] withAlubumName:[self p_getNowAlubum]];
            //[self p_updateStatusBar];
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
    [self p_openControllViewWithContent:_getDetailView];
}

- (IBAction)didPushPutButton:(id)sender {
    if (!self.isPlaying) {
        OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:nil
                                                                    message:@"曲が選択されていません"];
        [ghastly show];
        return;
    }
    [self p_openControllViewWithContent:_putDetailView];
}

- (IBAction)musicControlHandler:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            self.dragging = YES;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            self.dragging = NO;
            break;
        default:
            break;
    }
    
    MPMediaItem *item = [self.player nowPlayingItem];
    if (!item || !self.isPlaying) {
        return;
    }
    
    CGPoint location = [sender locationInView:self.progressView];
    if (location.x < 0 || location.x > self.progressView.frame.size.width) {
        return;
    }
    
    NSUInteger duration = [[item valueForKey:MPMediaItemPropertyPlaybackDuration] unsignedIntegerValue];
    
    CGFloat progress = location.x / self.progressView.frame.size.width;
    CGPoint center = self.musicControllView.center;
    center.x = location.x;
    self.player.currentPlaybackTime = (NSInteger)(duration * progress);
    self.musicControllView.center = center;
    self.progressView.progress = progress;
}



- (void)p_putMusic
{
    MPMediaItem *item = [self.player nowPlayingItem];
    if (!item) {
        [self p_closeControllView];
        return;
    }
    
    NSString *location = self.selectedLocationName;
    NSString *title = [item valueForKey:MPMediaItemPropertyTitle];
    NSString *artist = [item valueForKey:MPMediaItemPropertyArtist];
    
    [[PTSMusicStationAPIManager sharedManager] setDelegate:self];
    [[PTSMusicStationAPIManager sharedManager] putRequestWithStation:location
                                                               title:title
                                                              artist:artist];
}

- (void)musicCount
{
    MPMediaItem *item = [self.player nowPlayingItem];
    if (!item || !self.isPlaying || self.isDragging) {
        return;
    }
    
    NSUInteger duration = [[item valueForKey:MPMediaItemPropertyPlaybackDuration] unsignedIntegerValue];
    NSUInteger now = [self.player currentPlaybackTime];
    
    CGFloat progress = (float)now/(float)duration;
    CGPoint center = self.musicControllView.center;
    center.x = self.progressView.frame.size.width * progress;
    self.musicControllView.center = center;
    self.progressView.progress = progress;
}

/***************************************************/
#pragma mark - PrivateMethods
/***************************************************/
- (void)p_nowPlayingItemChanged:(NSNotification*)ntf {
    //Label更新
    [self p_updateLabel];
    //StatusBar更新
    [self p_updateStatusBar];
    //RegisterAPIたたく
    [[PTSMusicRegisterManager sharedManager] requestRegisterMusicArtist:[self p_getNowArtist] songTitle:[self p_getNowSong] genre:[self p_getNowGenre] WithLat:0 lon:0];
    //iBeacon
    [[PTSPeripheralManager sharedManager] startAdvertising:[self p_getNowArtist] withAlubumName:[self p_getNowAlubum]];
}

- (void)p_updateStatusBar
{
    NSString *str = [self p_getNowSong];
    if(str.length < 1){
        return;
    }
    NSDictionary *dict = @{@"SongTitle":str};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshStatusBar" object:self userInfo:dict];
}

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

- (NSString*)p_getNowArtist {
    if(_isPlaying){
        MPMediaItem *song = [self.player nowPlayingItem];
        return [song valueForProperty: MPMediaItemPropertyArtist];
    }
    else{
        return @"";
    }
}

- (NSString*)p_getNowSong {
    if(_isPlaying){
        MPMediaItem *song = [self.player nowPlayingItem];
        return [song valueForProperty: MPMediaItemPropertyTitle];
    }
    else{
        return @"";
    }
}

- (NSString*)p_getNowAlubum {
    if(_isPlaying){
        MPMediaItem *song = [self.player nowPlayingItem];
        return [song valueForProperty: MPMediaItemPropertyAlbumTitle];
    }
    else{
        return @"";
    }
}

- (NSString*)p_getNowGenre {
    if(_isPlaying){
        MPMediaItem *song = [self.player nowPlayingItem];
        return [song valueForProperty: MPMediaItemPropertyGenre];
    }
    else{
        return @"";
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
        
        MPMediaItem *item = [self.player nowPlayingItem];
        NSUInteger duration = [[item valueForKey:MPMediaItemPropertyPlaybackDuration] unsignedIntegerValue];
        
        // NSDateFormatter を用意します。
        
        self.timeLabel.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:duration]];
    }
}

- (void)p_setUpControllView {
    //ベース
    self.controllView = [UIView new];
    self.controllView.frame = CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height / 2.0f);
    self.controllView.backgroundColor = [UIColor clearColor];
    
    //ブラー用
    UIToolbar *toolBar = [UIToolbar new];
    toolBar.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height / 2.0f);
    toolBar.alpha = 0.99f;
    
    //つまみ
    UIImage *image = [UIImage imageNamed:@"pull.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake((_controllView.frame.size.width - image.size.width) / 2.0f,
                                 5.0f, image.size.width, image.size.height);
    
    //閉じるボタン
    UIButton *button = [[UIButton alloc] initWithFrame:imageView.frame];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(p_closeControllView) forControlEvents:UIControlEventTouchUpInside];
    
    //角丸
    self.controllView.clipsToBounds = YES;
    self.controllView.layer.cornerRadius = 10;
    toolBar.clipsToBounds = YES;
    toolBar.layer.cornerRadius = 10;
    
    [toolBar addSubview:button];
    [toolBar addSubview:imageView];
    [self.controllView addSubview:toolBar];
    [self.view addSubview:_controllView];
}

- (void)p_setUpGetView {
    //要素
    UINib *nib = [UINib nibWithNibName:@"View" bundle:nil];
    self.getDetailView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    CGRect rect = _getDetailView.frame;
    rect.origin.y = _controllView.frame.size.height - _getDetailView.frame.size.height -20.0f;
    _getDetailView.frame = rect;
}

- (void)p_setUpPutView {
    //要素
    UINib *nib = [UINib nibWithNibName:@"PutView" bundle:nil];
    self.putDetailView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    CGRect rect = _putDetailView.frame;
    rect.origin.y = _controllView.frame.size.height - _putDetailView.frame.size.height -20.0f;
    _putDetailView.frame = rect;
    
    UIPickerView *pickrView = (UIPickerView *)[_putDetailView viewWithTag:10];
    pickrView.dataSource = self;
    pickrView.delegate = self;
    
    UIButton *button = (UIButton *)[self.putDetailView viewWithTag:20];
    [button addTarget:self action:@selector(p_putMusic) forControlEvents:UIControlEventTouchUpInside];
}

- (void)p_openControllViewWithContent:(UIView *)contentView {
    CGRect frame = self.controllView.frame;
    frame.origin.y = self.view.frame.size.height - self.controllView.frame.size.height;
    
    [self.controllView addSubview:contentView];
    contentView.tag = 1000;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.controllView.frame = frame;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([contentView isEqual:_getDetailView]) {
                [[PTSMusicStationAPIManager sharedManager] setDelegate:self];
                [[PTSMusicStationAPIManager sharedManager] getRequest];
            } else if ([contentView isEqual:_putDetailView]) {
                [[PTSLocalSearchManager sharedManager] requestNearestLocations:^(NSArray *locations, NSError *error) {
                    self.nearestLocations = locations;
                    UIPickerView *pickrView = (UIPickerView *)[contentView viewWithTag:10];
                    [pickrView reloadAllComponents];
                    UILabel *titleLabel = (UILabel *)[pickrView viewForRow:0 forComponent:0];
                    self.selectedLocationName = titleLabel.text;
                }];
                
            }
        }
    }];
}

- (void)p_closeControllView {
    CGRect frame = self.controllView.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.controllView.frame = frame;;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self.audioPlayer pause];
            UIView *contentView = [self.controllView viewWithTag:1000];
            [contentView removeFromSuperview];
        }
    }];
}

- (void)p_updateGetView
{
    
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
- (void)didFinishLoardWithStationSongObject:(NSArray*)array station:(NSString *)station {
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        //駅名
        UILabel *stationLabel = (UILabel*)[_getDetailView viewWithTag:10];
        stationLabel.text = station;

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
                [self p_setUpLabelWithImageView:weakImageView isPlaying:YES];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];

    });
}

- (void)didFinishPutMusic
{
    [self p_closeControllView];
}

- (void)didErrorResponse
{
    [self p_closeControllView];
    OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:nil
                                                                message:@"曲がありませんでした"];
    [ghastly show];
    
}


/***************************************************/
#pragma mark - UIPickerViewDelegate/DataSource
/***************************************************/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.nearestLocations ? self.nearestLocations.count : 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
        retval.minimumScaleFactor = 0.1;
        retval.adjustsFontSizeToFitWidth = YES;
        retval.textAlignment = NSTextAlignmentCenter;
    }
    retval.text = self.nearestLocations[row][@"Name"];
    
    return retval;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (!self.nearestLocations) {
        return;
    }
    
    self.selectedLocationName = self.nearestLocations[row][@"Name"];
}

#pragma mark - UIActionSheet Delegate
// アクションシートのボタンが押された時に呼ばれるデリゲート例文
-(void)actionSheet:(UIActionSheet*)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            // １番目のボタンが押されたときの処理を記述する
            [self p_lineAction];
            break;
        case 1:
            // ２番目のボタンが押されたときの処理を記述する
            [self p_twitterAction];
            break;
        case 2:
            // ３番目のボタンが押されたときの処理を記述する
            [self p_facebookAction];
            break;
        case 3:
            // ４番目のボタンが押されたときの処理を記述する
            break;
    }
    
}

#pragma mark - UIActionSheetDeleatePrivateAction
-(void)p_lineAction
{
    NSString *LineUrlString = [[NSString stringWithFormat:@"line://msg/text/%@ / %@ #nowplaying #音ぷっと",[self p_getNowSong],[self p_getNowArtist]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // URLスキームを使ってLINEを起動
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LineUrlString]];
}
-(void)p_twitterAction
{
    SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterPostVC setInitialText:[NSString stringWithFormat:@"%@ / %@ #nowplaying #音ぷっと",[self p_getNowSong],[self p_getNowArtist]]];
    [twitterPostVC addURL:[NSURL URLWithString:@"http://www1415uo.sakura.ne.jp/jumon.html"]];
    // 処理終了後に呼び出されるコールバックを指定する
    [twitterPostVC setCompletionHandler:^(SLComposeViewControllerResult result) {
        
        switch (result) {
            case SLComposeViewControllerResultDone:
                [self p_showAlertView];
                break;
            case SLComposeViewControllerResultCancelled:
                break;
        }
    }];
    [self presentViewController:twitterPostVC animated:YES completion:nil];
}
-(void)p_facebookAction
{
    SLComposeViewController *vc = [SLComposeViewController
                                   composeViewControllerForServiceType:SLServiceTypeFacebook];
    [vc setInitialText:[NSString stringWithFormat:@"%@ / %@ #nowplaying #音ぷっと",[self p_getNowSong],[self p_getNowArtist]]];
    [vc addURL:[NSURL URLWithString:@"http://www1415uo.sakura.ne.jp/jumon.html"]];
    // 処理終了後に呼び出されるコールバックを指定する
    [vc setCompletionHandler:^(SLComposeViewControllerResult result) {
        
        switch (result) {
            case SLComposeViewControllerResultDone:
                [self p_showAlertView];
                break;
            case SLComposeViewControllerResultCancelled:
                break;
        }
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"投稿に成功しました！" message:@"沢山の投稿に期待してます。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
    
}

-(void)p_showAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"投稿に成功しました！" message:@"沢山の投稿に期待してます。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
