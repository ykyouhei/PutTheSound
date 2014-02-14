//
//  SCOUtilImageView.h
//  StarbucksCustomOrder
//
//  Created by 千葉 俊輝 on 2013/10/29.
//  Copyright (c) 2013年 koganepj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCOUtilImageViewDelegate <NSObject>
- (void)didPushImageViewWithSongUrl:(NSString*)stringUrl;
@end

@interface SCOUtilImageView : UIImageView
@property(strong, nonatomic) NSString *songUrl;
@property(weak, nonatomic) id<SCOUtilImageViewDelegate>delegate;
@end
