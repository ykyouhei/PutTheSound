//
//  PTSUtilManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/04/29.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSUtilManager.h"

@implementation PTSUtilManager

//UUIDは取得の度に変わるので、UserDefaultsに保存
//アプリを一度削除しちゃうと初期化されちゃうので注意

+ (NSString *)getUserID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuidStr = [defaults stringForKey:@"uuid"];
    
    if (uuidStr.length == 0) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        [defaults setObject:uuidStr forKey:@"uuid"];
    }
    return uuidStr;
}

//学習の初期化などで使うといいかも
+ (void)resetUserID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    [defaults setObject:uuidStr forKey:@"uuid"];
}
@end
