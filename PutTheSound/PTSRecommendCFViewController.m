//
//  PTSRecommendCFViewController.m
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSRecommendCFViewController.h"
#import "PTSRecommendArtworkView.h"

@interface PTSRecommendCFViewController ()
@property (nonatomic) NSArray *recommendItems;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSString *selectedStringUrl;
@end

@implementation PTSRecommendCFViewController

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
    
    self.carousel.type = iCarouselTypeWheel;
    
    
    [self p_indicatorShow:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/***************************************************/
#pragma mark - PrivateMethod
/***************************************************/

- (void)p_indicatorShow:(BOOL)flag {
    if(flag){
        self.indicatorView.hidden = NO;
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView*)[_indicatorView viewWithTag:300];
        [indicatorView startAnimating];
    }
    else{
        self.indicatorView.hidden = YES;
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView*)[_indicatorView viewWithTag:300];
        [indicatorView stopAnimating];
    }
}

- (void)p_setUpLabelWithImageView:(SCOUtilImageView*)imageView isPlaying:(BOOL)flag {
    imageView.isPlaying = flag;
    [imageView setNeedsLayout];
}


/***************************************************/
#pragma mark - iCarousel Delegate
/***************************************************/
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return _recommendItems.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(PTSRecommendArtworkView *)view
{
    //create new view if no view is available for recycling
    if (view == nil) {
        view = [PTSRecommendArtworkView instanceFromNib];
    }
    
    view.artworkImageView.delegate = self;
    view.artworkImageView.songUrl = _recommendItems[index][@"previewUrl"];
    view.titleLabel.text = _recommendItems[index][@"trackName"];
    [self p_setUpLabelWithImageView:((PTSRecommendArtworkView *)view).artworkImageView isPlaying:YES];
    
    // 画像取得（UIImage+AFNetworking）
    NSURL *url = [NSURL URLWithString:_recommendItems[index][@"artworkUrl100"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak PTSRecommendArtworkView *weakView = (PTSRecommendArtworkView *)view;
    [view.artworkImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (weakView) {
            weakView.artworkImageView.image = image;
            [weakView setNeedsLayout];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.1f;
    }
    return value;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
}



#pragma mark - PTSRecommendAPIManagerDelegate
- (void)didFinishLoardWithObject:(NSArray *)array {
    self.recommendItems = array;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self p_indicatorShow:NO];
        [self.carousel reloadData];
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

- (IBAction)onValueChangedType:(UISegmentedControl *)sender {
    //carousel can smoothly animate between types
    [UIView beginAnimations:nil context:nil];
    self.carousel.type = sender.selectedSegmentIndex;
    [UIView commitAnimations];
}

- (IBAction)onValueChangedOrientation:(UISegmentedControl *)sender {
    //carousel orientation can be animated
    [UIView beginAnimations:nil context:nil];
    self.carousel.vertical = sender.selectedSegmentIndex == 1;
    [UIView commitAnimations];
}


@end
