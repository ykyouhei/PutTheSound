//
//  PTSPeripheralManager.m
//  PutTheSound
//
//  Created by 千葉 俊輝 on 2014/02/19.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSPeripheralManager.h"

@interface PTSPeripheralManager()
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@end

//612446160
//static NSString *const stringURL = @"http://www1415uo.sakura.ne.jp/music/GetTrackID.php?artist=%E3%81%AB%E3%82%93%E3%81%98%E3%82%83%E3%82%8A%E3%81%B0%E3%82%93%E3%81%B0%E3%82%93&title=%E3%81%8D%E3%82%83%E3%82%8A%E3%83%BC%E3%81%B1%E3%81%BF%E3%82%85%E3%81%B1%E3%81%BF%E3%82%85";

static NSString *const stringURL = @"http://www1415uo.sakura.ne.jp/music/GetTrackID.php?artist=";

static NSString *const stringUUID = @"D801A9FA-13A7-49E3-9A67-B7FCA50C8934";
static NSString *const stringidentifer = @"kogane";

static PTSPeripheralManager *_sharedManager = nil;

@implementation PTSPeripheralManager

+ (PTSPeripheralManager *)sharedManager{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PTSPeripheralManager alloc] init];
    });
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // 初期処理
        _proximityUUID = [[NSUUID alloc] initWithUUIDString:stringUUID];
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    return self;
}


#pragma mark - Public Methods
- (void)startAdvertising:(NSString*)artistName withAlubumName:(NSString*)alubumNAme{
    if([artistName isEqualToString:@""] || [alubumNAme isEqualToString:@""]){
        return;
    }
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        
        //一度停止
        [self.peripheralManager stopAdvertising];
        
        //NSURL *url = [NSURL URLWithString:stringURL];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@&title=%@",stringURL,
                                           [artistName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                           [alubumNAme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                               completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                                   
                                   if(data){
                                       NSError *error = nil;
                                       NSNumber *trackID = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                       
                                       if(!trackID && error){
                                           return;
                                       }
                                       
                                       int major = [trackID intValue] / 10000;
                                       int minor = [trackID intValue] % 10000;
                                       
                                       
                                       CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_proximityUUID
                                                                                                              major:major
                                                                                                              minor:minor
                                                                                                         identifier:stringidentifer];
                                       NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
                                       [self.peripheralManager startAdvertising:beaconPeripheralData];
                                       
                                   }
                               }];
        
        
    }
}
- (void)stopAdvertising{
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self.peripheralManager stopAdvertising];
    }
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            break;
        case CBPeripheralManagerStatePoweredOn:
            break;
        case CBPeripheralManagerStateResetting:
            break;
        case CBPeripheralManagerStateUnauthorized:
            break;
        case CBPeripheralManagerStateUnknown:
            break;
        case CBPeripheralManagerStateUnsupported:
            break;
        default:
            break;
    }
}
@end
