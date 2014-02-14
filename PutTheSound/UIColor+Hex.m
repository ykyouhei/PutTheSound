//
//  UIColor+Hex.m
//  StarbucksCustomOrder
//
//  Created by 山口 恭兵 on 2013/10/24.
//  Copyright (c) 2013年 koganepj. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

/**
 16進数からUIColorを生成する。
 
 @param hex 16進数文字列
 @return UIColor
*/
+ (id)colorWithHexString:(NSString *)hex alpha:(CGFloat)a
{
    NSScanner *colorScanner = [NSScanner scannerWithString:hex];
    unsigned int color;
    if (![colorScanner scanHexInt:&color]) return nil;
    CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
    CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
    CGFloat b =  (color & 0x0000FF) /255.0f;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

/**
 0~255でUIColorを生成する。

 @param red R
 @param green G
 @param blue B
 @param alpha A
 @return UIColor
 */
+ (UIColor*) colorIntWithRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
