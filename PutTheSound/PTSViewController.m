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

@interface PTSViewController ()
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic) MPMusicPlayerController *player;
@property (nonatomic) BOOL isPlaying;

@property (weak, nonatomic) PTSMusicDataModel *dataModel;
@end

@implementation PTSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.dataModel = [PTSMusicDataModel sharedManager];
    self.carousel.dataSource = self.dataModel;
    self.player = [MPMusicPlayerController iPodMusicPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)didPushPlayButton:(id)sender {
    [self p_setUpButton];
}
- (IBAction)didPushBackButton:(id)sender {
    [self.player skipToPreviousItem];
    [self p_updateLabel];
}
- (IBAction)didPushNextButton:(id)sender {
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

#pragma mark - PrivateMethods
- (void)p_setUpButton {
    if(_isPlaying){
        [self.player pause];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        _isPlaying = NO;
    }
    else{
        [self.player play];
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        _isPlaying = YES;
    }
}
- (void)p_showPlaylistInfo {
    NSLog(@"プレイリストを表示する");
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    for( MPMediaPlaylist *plist in [query collections] )
    {
        NSLog(@"%@", [plist valueForProperty:MPMediaPlaylistPropertyName]);
    }
}

- (void)p_updateLabel {
    MPMediaItem *song = [self.player nowPlayingItem];
    NSDictionary *songDic = @{@"ID":[song valueForProperty: MPMediaItemPropertyPersistentID],
                              @"TITLE":[song valueForProperty: MPMediaItemPropertyTitle],
                              @"ARTIST":[song valueForProperty: MPMediaItemPropertyArtist],
                              @"ALUBUMTITLE":[song valueForProperty: MPMediaItemPropertyAlbumTitle],
                              @"ARTWORK":[song valueForProperty: MPMediaItemPropertyArtwork]};
    self.mainLabel.text = songDic[@"TITLE"];
    self.detailLabel.text = songDic[@"ALUBUMTITLE"];
    MPMediaItemArtwork *artwork =  songDic[@"ARTWORK"];
    //self.imageView.image = [artwork imageWithSize:CGSizeMake(320.0f, 320.0f)];
}

@end
