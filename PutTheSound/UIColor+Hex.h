//
//  UIColor+Hex.h
//  StarbucksCustomOrder
//
//  Created by 山口 恭兵 on 2013/10/24.
//  Copyright (c) 2013年 koganepj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (id)colorWithHexString:(NSString *)hex alpha:(CGFloat)a;
+ (UIColor*) colorIntWithRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)alpha;

@end
