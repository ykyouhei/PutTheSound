//
//  CentralManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/20.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "CentralManager.h"

@interface CentralManager()
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) int currentMajor;
@property (nonatomic) int currentMinor;
@end

static NSString *const stringUUID = @"D801A9FA-13A7-49E3-9A67-B7FCA50C8934";
static NSString *const stringidentifer = @"kogane";
static NSString *const stringURL = @"http://www1415uo.sakura.ne.jp/music/MusicDetail.php?id=";
static CentralManager *_sharedManager = nil;

@implementation CentralManager

+ (CentralManager *)sharedManager {
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[CentralManager alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // 初期処理
        _currentMajor = 0;
        _currentMinor = 0;
        
        _proximityUUID = [[NSUUID alloc] initWithUUIDString:stringUUID];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_proximityUUID
                                                           identifier:stringidentifer];
        
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return self;
}

- (void)startMonitoring {
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        //モニタリング開始
        [self.locationManager startMonitoringForRegion:_beaconRegion];
    }
}

- (void)stopMonitoring {
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        [self.locationManager stopMonitoringForRegion:_beaconRegion];
    }
}

#pragma mark - LacationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
}

// モニタリング開始が正常に始まった時に呼ばれるdelegateメソッド
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    // 領域内でモニタリングを開始した場合、受信できなくなるために、下記メソッドを呼び、状態検知することができる
    // 下記のメソッドが呼ばれるdidDetermineState
    [manager requestStateForRegion:_beaconRegion];
    //[manager startMonitoringForRegion:(CLBeaconRegion *)region];
    //[self.locationManager requestStateForRegion:_beaconRegion];
}

// 距離の測定を開始する
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    //領域内からモニタリングが開始された場合対策
    switch (state) {
        case CLRegionStateInside: //既に領域内にいる場合
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                //通知の受け取りを開始
                [manager startRangingBeaconsInRegion:_beaconRegion];
                
                //[manager startMonitoringForRegion:(CLBeaconRegion *)region];
                
                //[self.locationManager startRangingBeaconsInRegion:_beaconRegion];
            }
            
            break;
            
        case CLRegionStateOutside:
            
        case CLRegionStateUnknown:
            
        default:
            
            break;
    }
}

//領域内に入ったときに呼ばれるdelegateメソッド
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        //通知の受け取りを開始
        [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
        //[manager startMonitoringForRegion:(CLBeaconRegion *)region];
        //[self.locationManager startRangingBeaconsInRegion:_beaconRegion];
    }
}

//Beacon の距離測定イベントのハンドリング
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        // 最も距離の近いBeaconについて処理する
        CLBeacon *nearestBeacon = beacons.firstObject;
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                //この中に処理
                break;
            case CLProximityNear:
                //この中に処理
                break;
            case CLProximityFar:
                //この中に処理
                break;
            default:
                
                break;
                
        }
        
        int localMajor = [nearestBeacon.major intValue];
        int localMinor = [nearestBeacon.minor intValue];
        
        if(localMajor != _currentMajor && localMinor != _currentMinor){
            int number = [nearestBeacon.major intValue] * 10000;
            number += [nearestBeacon.minor intValue];
            self.currentMajor = [nearestBeacon.major intValue];
            self.currentMinor = [nearestBeacon.minor intValue];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d",stringURL,number]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                                   completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                                       
                                       if(data){
                                           NSError *error = nil;
                                           NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                           
                                           if(!jsonObject && error){
                                               return;
                                           }
                                           if(((NSArray*)jsonObject[@"results"]).count == 0){
                                               return;
                                           }
                                           
                                           [self p_showAlert:jsonObject[@"results"][0][@"trackName"]];
                                           
                                       }
                                   }];
        }
        
    }
}

#pragma mark - Private Methods

- (void)p_showAlert:(NSString*)message {
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground){
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"近くで聴かれてる曲" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }];
    }
    else{
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            UILocalNotification *notification = [UILocalNotification new];
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.alertAction = @"聴く";
            notification.alertBody = message;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }];
    }
    
}
@end