//
//  SCOUtilImageView.m
//  StarbucksCustomOrder
//
//  Created by 千葉 俊輝 on 2013/10/29.
//  Copyright (c) 2013年 koganepj. All rights reserved.
//

#import "SCOUtilImageView.h"
#import "UIColor+Hex.h"
@interface SCOUtilImageView () {
    UIView *_loadingView;
    UIActivityIndicatorView *_indicator;
    UILabel *_label;
}

@end
@implementation SCOUtilImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup {
    if(!self.image) {
        // ローディングビュー作成
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _loadingView.backgroundColor = [UIColor blackColor];
        _loadingView.alpha = 0.5f;
        
        // インジケータ作成
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [_indicator setCenter:CGPointMake(_loadingView.bounds.size.width / 2, _loadingView.bounds.size.height / 2)];
        
        // ビューに追加
        [_loadingView addSubview:_indicator];
        [self addSubview:_loadingView];
        
        // インジケータ再生
        [_indicator startAnimating];
        
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 4.0f, self.frame.size.height / 4.0f)];
        [_label setCenter:CGPointMake(_loadingView.bounds.size.width / 2, _loadingView.bounds.size.height / 2)];
        _label.backgroundColor = [UIColor whiteColor];
        _label.alpha = 0.7f;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.hidden = YES;
        [self addSubview:_label];
    }
}

- (void)awakeFromNib {
    [self setup];
}

- (id)init{
    self = [super init];
    if(self) {
    
    }
    
    return self;
}

- (void)layoutSubviews {
    if(self.image){
        [_indicator stopAnimating];
        [_loadingView removeFromSuperview];
        [_label setHidden:NO];
    }
    else {
        [_label setHidden:YES];
    }

    self.userInteractionEnabled = ([self.songUrl isEqualToString:@""])?NO:YES;
    
    [self p_setUpLabelTitle];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //self.alpha = 0.2f;
    [self setHighlighted:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //self.alpha = 1.0f;
    [self setHighlighted:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //self.alpha = 1.0f;
    [self setHighlighted:NO];
    
    if([self.delegate respondsToSelector:@selector(didPushImageViewWithDictionary:)]){
        
        NSDictionary *dic = @{@"object":self,
                              @"songUrl":_songUrl};
        
        [self.delegate didPushImageViewWithDictionary:dic];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    //if(highlighted && ![self highlightedImage]){
    UIGraphicsBeginImageContextWithOptions([[self image] size], NO, [[UIScreen mainScreen] scale]);
    CGRect rect = CGRectMake(0.0f, 0.0f, [[self image] size].width, [[self image] size].height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[self image] drawInRect:rect];
    CGContextSetFillColorWithColor(ctx, [[UIColor colorIntWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f] CGColor]);
    CGContextFillRect(ctx, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setHighlightedImage:newImage];
    //}
    [super setHighlighted:highlighted];
}

#pragma mark - Private Methods
- (void)p_setUpLabelTitle{
    _label.text = !_isPlaying?@"Pause":@"Play";
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
