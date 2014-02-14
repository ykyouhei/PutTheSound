//
//  PTSRecommendViewController.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/14.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSRecommendViewController.h"

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
    [[PTSRecommendAPIManager sharedManager] setDelegate:self];
    [[PTSRecommendAPIManager sharedManager] request];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    [self p_indicatorShow:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UILabel *mainLabel = (UILabel*)[cell viewWithTag:200];
    mainLabel.text = _recommendItems[indexPath.row][@"trackName"];
    
    SCOUtilImageView *imageView = (SCOUtilImageView*)[cell viewWithTag:100];
    imageView.delegate = self;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_recommendItems[indexPath.row][@"artworkUrl100"]]]];
    imageView.image = image;
    imageView.songUrl = _recommendItems[indexPath.row][@"previewUrl"];
    [self p_setUpLabelWithImageView:imageView isPlaying:YES];
    
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
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
    [self.audioPlayer play];
    [self setSelectedStringUrl:stringUrl];
    [self p_setUpLabelWithImageView:dictionary[@"object"] isPlaying:NO];
}

#pragma mark - IBAction
- (IBAction)didPushReturnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
