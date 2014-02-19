//
//  PTSCentralManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/19.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSCentralManager.h"

@interface PTSCentralManager()
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) CLLocationManager *locationManagger;
@property (nonatomic) NSNumber *currentMajor;
@property (nonatomic) NSNumber *currentMinor;
@end

static NSString *const stringUUID = @"D801A9FA-13A7-49E3-9A67-B7FCA50C8934";
static NSString *const stringidentifer = @"kogane";
static NSString *const stringURL = @"http://www1415uo.sakura.ne.jp/music/MusicDetail.php?id=";


static  PTSCentralManager *_sharedManager = nil;

@implementation PTSCentralManager
+ ( PTSCentralManager *)sharedManager{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[ PTSCentralManager alloc] init];
    });
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // 初期処理
        _proximityUUID = [[NSUUID alloc] initWithUUIDString:stringUUID];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_proximityUUID identifier:stringidentifer];
        
        _locationManagger = [CLLocationManager new];
        _locationManagger.delegate = self;
    }
    return self;
}

#pragma mark - Public Methods
- (void)startMonitoring{
    if([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]){
        [self.locationManagger startMonitoringForRegion:_beaconRegion];
    }
}

- (void)stopMonitoring{
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    [manager requestStateForRegion:_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    switch (state) {
        case CLRegionStateInside:
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
                [manager startRangingBeaconsInRegion:_beaconRegion];
            }
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
        [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                break;
            case CLProximityNear:
                break;
            case CLProximityFar:
                break;
            default:
                break;
        }
        
        if(nearestBeacon.major != _currentMajor && nearestBeacon.minor != _currentMinor){
            int number = [nearestBeacon.major intValue] * 1000;
            number += [nearestBeacon.minor intValue];
            
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
                                           if(((NSArray*)jsonObject[@"results"]).count > 0){
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
    // TODO: Alert処理
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.fireDate = [NSDate date];
    notification.alertAction = @"聴く";
    notification.alertBody = message;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
