//
//  PTSMusicDataModel.m
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSMusicDataModel.h"
#import "PTSRecommendArtworkView.h"
#import "SCOUtilImageView.h"

static PTSMusicDataModel *_sharedInstance;

@implementation PTSMusicDataModel

+ (PTSMusicDataModel *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PTSMusicDataModel alloc] initSharedInstance];
    });
    return _sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        //return [self reloadData];
        //各セクション名と曲名用の配列の初期化
        self.sectionPlayList = [NSMutableArray new];
        self.playListSongs = [NSMutableDictionary new];
        
        //iPodの音楽ライブラリから取得
        MPMediaQuery *myPlaylistsQuery = [MPMediaQuery albumsQuery];
        NSArray *playlists = [myPlaylistsQuery collections];
        
        for (MPMediaItemCollection *playlist in playlists) {
            [self.sectionPlayList addObject:[playlist.items[0] valueForProperty: MPMediaItemPropertyAlbumTitle]];
            
            //各sectionにぶらさがる曲名用の配列を初期化
            self.sectionSongs  = [NSMutableArray new];
            
            for (MPMediaItem *song in [playlist items]) {
                //曲情報を配列にセット(曲ID、曲名、アーティスト名、アルバム名)
                NSDictionary *songDic = @{@"ID":[song valueForProperty: MPMediaItemPropertyPersistentID],
                                          @"TITLE":[song valueForProperty: MPMediaItemPropertyTitle],
                                          @"ARTIST":[song valueForProperty: MPMediaItemPropertyArtist],
                                          @"ALUBUMTITLE":[song valueForProperty: MPMediaItemPropertyAlbumTitle],
                                          @"ARTWORK":[song valueForProperty: MPMediaItemPropertyArtwork]};
                
                [self.sectionSongs addObject:songDic];
                
            }
            
            //1section分のデータができたので、全体テーブル用の配列にセット
            [self.playListSongs setObject:_sectionSongs forKey:[playlist.items[0] valueForProperty: MPMediaItemPropertyAlbumTitle]];
        }

    }
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (PTSMusicDataModel *)reloadData
{
    //各セクション名と曲名用の配列の初期化
    self.sectionPlayList = [NSMutableArray new];
    self.playListSongs = [NSMutableDictionary new];
    
    //iPodの音楽ライブラリから取得
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery albumsQuery];
    NSArray *playlists = [myPlaylistsQuery collections];
    
    for (MPMediaItemCollection *playlist in playlists) {
        [self.sectionPlayList addObject:[playlist.items[0] valueForProperty: MPMediaItemPropertyAlbumTitle]];
        
        //各sectionにぶらさがる曲名用の配列を初期化
        self.sectionSongs  = [NSMutableArray new];
        
        for (MPMediaItem *song in [playlist items]) {
            //曲情報を配列にセット(曲ID、曲名、アーティスト名、アルバム名)
            NSDictionary *songDic = @{@"ID":[song valueForProperty: MPMediaItemPropertyPersistentID],
                                      @"TITLE":[song valueForProperty: MPMediaItemPropertyTitle],
                                      @"ARTIST":[song valueForProperty: MPMediaItemPropertyArtist],
                                      @"ALUBUMTITLE":[song valueForProperty: MPMediaItemPropertyAlbumTitle],
                                      @"ARTWORK":[song valueForProperty: MPMediaItemPropertyArtwork]};
            
            [self.sectionSongs addObject:songDic];
            
        }
        
        //1section分のデータができたので、全体テーブル用の配列にセット
        [self.playListSongs setObject:_sectionSongs forKey:[playlist.items[0] valueForProperty: MPMediaItemPropertyAlbumTitle]];
    }
    return self;
}

- (PTSMusicDataModel *)sortDataWithAlbumName:(NSString*)albumName
{
    NSInteger count = 0;
    NSInteger replaceIndex = 0;
    for(NSString *title in self.sectionPlayList){
        if([title isEqualToString:albumName]){
            replaceIndex = count;
        }
        count++;
    }
    
    [self.sectionPlayList exchangeObjectAtIndex:0 withObjectAtIndex:replaceIndex];
    
    return self;
}
@end
