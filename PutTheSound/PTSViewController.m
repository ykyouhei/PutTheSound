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
    self.backgroundImageView.image = [[artwork imageWithSize:self.backgroundImageView.frame.size] applyLightEffect];
}

/***************************************************/
#pragma mark - IBAction
/***************************************************/
- (IBAction)rightSwipeHandler:(id)sender {
    [self.player skipToPreviousItem];
    [self p_updateLabel];
}
- (IBAction)leftSwipeHander:(id)sender {
    [self.player skipToNextItem];
    [self p_updateLabel];
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


@end
