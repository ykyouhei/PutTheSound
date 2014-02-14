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
    [[PTSRecommendAPIManager sharedManager] request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    UILabel *mainLabel = (UILabel*)[cell viewWithTag:20];
    
    mainLabel.text = _recommendItems[indexPath.row][@"TITLE"];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_recommendItems[indexPath.row][@"IMAGE"]]]];
    imageView.image = image;
    
    //NSLog(@"%@",_playListSongs[_sectionPlayList[indexPath.section]][indexPath.row]);
    
    return cell;
}

#pragma mark - IBAction
- (IBAction)didPushReturnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
