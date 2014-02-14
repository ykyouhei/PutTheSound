//
//  PTSPlayListViewController.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/14.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//
#import "PTSViewController.h"
#import "PTSPlayListViewController.h"
#import "UIColor+Hex.h"

@interface PTSPlayListViewController ()
@property (nonatomic) NSMutableArray *sectionPlayList;
@property (nonatomic) NSMutableArray *sectionSongs;
@property (nonatomic) NSMutableDictionary *playListSongs;
@property (nonatomic) NSDictionary *selectedSong;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation PTSPlayListViewController

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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //各セクション名と曲名用の配列の初期化
    self.sectionPlayList = [NSMutableArray new];
    self.playListSongs = [NSMutableDictionary new];
    
    //iPodの音楽ライブラリから取得
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    NSArray *playlists = [myPlaylistsQuery collections];
    
    for (MPMediaPlaylist *playlist in playlists) {
        //section名を配列にセット
        [self.sectionPlayList addObject:[playlist valueForProperty: MPMediaPlaylistPropertyName]];
        
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
        [self.playListSongs setObject:_sectionSongs forKey:[playlist valueForProperty: MPMediaPlaylistPropertyName]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // ハイライト解除
    [self.tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return _sectionPlayList.count;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return _sectionPlayList[section];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    id key = _sectionPlayList[section];
    return ((NSArray*)_playListSongs[key]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    UILabel *mainLabel = (UILabel*)[cell viewWithTag:20];
    UILabel *detailLabel = (UILabel*)[cell viewWithTag:30];
    
    mainLabel.text = _playListSongs[_sectionPlayList[indexPath.section]][indexPath.row][@"TITLE"];
    detailLabel.text =  _playListSongs[_sectionPlayList[indexPath.section]][indexPath.row][@"ALUBUMTITLE"];
    
    MPMediaItemArtwork *artwork = _playListSongs[_sectionPlayList[indexPath.section]][indexPath.row][@"ARTWORK"];
    imageView.image = [artwork imageWithSize:CGSizeMake(140.0f, 140.0f)];
    
    //NSLog(@"%@",_playListSongs[_sectionPlayList[indexPath.section]][indexPath.row]);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //選択された曲を検索条件に指定
    self.selectedSong = _playListSongs[_sectionPlayList[indexPath.section]][indexPath.row];
    
    MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
    NSNumber *persistentId = _selectedSong[@"ID"];
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentId forProperty:MPMediaItemPropertyPersistentID];
    [songQuery addFilterPredicate:predicate];
    
    [self.player setQueueWithQuery:songQuery];
    [self.player play];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor colorIntWithRed:0.7 green:0.7 blue:0.7 alpha:0.7];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _sectionPlayList[section];
    [view addSubview:label];
	return view;
}

#pragma mark - IBAction
- (IBAction)didPushReturnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 }
 */
@end
