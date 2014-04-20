//
//  PTSSettingsTableViewController.m
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/04/20.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSSettingsTableViewController.h"

@interface PTSSettingsTableViewController ()

@end

@implementation PTSSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/***************************************************/
#pragma mark - IB Action
/***************************************************/
- (IBAction)didPushBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
