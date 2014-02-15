//
//  StationManager.m
//  GetStations
//
//  Created by 山口 恭兵 on 2014/02/14.
//  Copyright (c) 2014年 Kyouhei Yamaguchi. All rights reserved.
//

#import "StationManager.h"

static StationManager *_sharedInstance;

static NSString *const kGetStationsURLTemplate = @"http://express.heartrails.com/api/json?method=getStations&x=%f&y=%f";

@interface StationManager () {
    RequestStationsResultHandler _requestStationsHandler;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation StationManager

+ (StationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[StationManager alloc] initSharedInstance];
    });
    return _sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 500;
    }
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)requestNearestStations:(RequestStationsResultHandler)completion
{
    _requestStationsHandler = completion;
    [self.locationManager startUpdatingLocation];
}


/***************************************************/
#pragma mark - Private Method
/***************************************************/
- (void)requestStationsWithLat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon
{
    NSString *urlString = [NSString stringWithFormat:kGetStationsURLTemplate, fabs(lon), lat];
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (error) {
        _requestStationsHandler(nil, error);
        _requestStationsHandler = nil;
        return;
    }
    
    NSError *jsonError;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&jsonError];
    
    _requestStationsHandler(responseDic[@"response"][@"station"], nil);
    _requestStationsHandler = nil;
    
    return;
}


/***************************************************/
#pragma mark - CLLocationManagerDelegate
/***************************************************/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_requestStationsHandler == nil) {
        return;
    }
    
    CLLocation* location = [locations lastObject];
    [self requestStationsWithLat:location.coordinate.latitude
                             lon:location.coordinate.longitude];
    
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    _requestStationsHandler(nil, error);
    _requestStationsHandler = nil;
}

@end