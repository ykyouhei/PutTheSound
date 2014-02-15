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

@interface PTSViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic) MPMusicPlayerController *player;
@property (nonatomic) BOOL isPlaying;

@end

@implementation PTSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    //選択された曲を再生
    self.player = [MPMusicPlayerController iPodMusicPlayer];
    MPMediaItem *song = [self.player nowPlayingItem];
    
    if(!song){
        self.mainLabel.text = @"再生中の曲がありません。";
        self.detailLabel.text = @"";
        self.imageView.image = nil;
        self.playButton.hidden = YES;
        return;
    }
    else{
        self.playButton.hidden = NO;
        
        NSDictionary *songDic = @{@"ID":[song valueForProperty: MPMediaItemPropertyPersistentID],
                                  @"TITLE":[song valueForProperty: MPMediaItemPropertyTitle],
                                  @"ARTIST":[song valueForProperty: MPMediaItemPropertyArtist],
                                  @"ALUBUMTITLE":[song valueForProperty: MPMediaItemPropertyAlbumTitle],
                                  @"ARTWORK":[song valueForProperty: MPMediaItemPropertyArtwork]};
        
        
        MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
        NSNumber *persistentId = songDic[@"ID"];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentId forProperty:MPMediaItemPropertyPersistentID];
        [songQuery addFilterPredicate:predicate];
        
        [self.player setQueueWithQuery:songQuery];
        [self.player play];
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        _isPlaying = YES;
        
        self.mainLabel.text = songDic[@"TITLE"];
        self.detailLabel.text = songDic[@"ALUBUMTITLE"];
        MPMediaItemArtwork *artwork =  songDic[@"ARTWORK"];
        self.imageView.image = [artwork imageWithSize:CGSizeMake(320.0f, 320.0f)];
    }
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


 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
     if([[segue identifier] isEqualToString:@"ControlViewToPlayListView"]){
         PTSPlayListViewController *nextViewController = [segue destinationViewController];
         nextViewController.player = _player;
     }
 }

@end
