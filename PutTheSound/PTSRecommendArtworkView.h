//
//  PTSRecommendArtworkView.h
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCOUtilImageView;

@interface PTSRecommendArtworkView : UIView

@property (weak, nonatomic) IBOutlet SCOUtilImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (id)instanceFromNib;

@end
