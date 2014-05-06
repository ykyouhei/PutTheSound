//
//  PTSMusicDataModel.h
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <iCarousel/iCarousel.h>

@interface PTSMusicDataModel : NSObject
<iCarouselDataSource>

@property (nonatomic) NSMutableArray *sectionPlayList;
@property (nonatomic) NSMutableArray *sectionSongs;
@property (nonatomic) NSMutableDictionary *playListSongs;
@property (nonatomic) NSDictionary *selectedSong;

+ (PTSMusicDataModel *)sharedManager;
- (PTSMusicDataModel *)reloadData;
- (PTSMusicDataModel *)sortDataWithAlbumName:(NSString*)albumName;
@end
