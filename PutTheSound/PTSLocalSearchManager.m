//
//  PTSLocalSearchManager.m
//  PutTheSound
//
//  Created by 山口 恭兵 on 2014/02/23.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSLocalSearchManager.h"

static PTSLocalSearchManager *_sharedInstance;

static NSString *const kGetLocationsURLTemplate = @"http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch?appid=dj0zaiZpPXpvblhpUEVZNTlTSyZzPWNvbnN1bWVyc2VjcmV0Jng9NzA-&lat=%f&lon=%f&dist=0.2&output=json&detail=simple";

@interface PTSLocalSearchManager ()
{
    RequestLocationsResultHandler _requestLocationsHandler;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation PTSLocalSearchManager

/***************************************************/
#pragma mark - initializer
/***************************************************/

+ (PTSLocalSearchManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PTSLocalSearchManager alloc] initSharedInstance];
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


/***************************************************/
#pragma mark - Public Method
/***************************************************/

- (void)requestNearestLocations:(RequestLocationsResultHandler)completion
{
    _requestLocationsHandler = completion;
    [self.locationManager startUpdatingLocation];
}

/***************************************************/
#pragma mark - Private Method
/***************************************************/
- (void)requestLocationsWithLat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon
{
    NSString *urlString = [NSString stringWithFormat:kGetLocationsURLTemplate, lat, fabs(lon)];
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (error) {
        _requestLocationsHandler(nil, error);
        _requestLocationsHandler = nil;
        return;
    }
    
    NSError *jsonError;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&jsonError];
    
    _requestLocationsHandler(responseDic[@"Feature"], nil);
    _requestLocationsHandler = nil;
    
    return;
}


/***************************************************/
#pragma mark - CLLocationManagerDelegate
/***************************************************/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_requestLocationsHandler == nil) {
        return;
    }
    
    CLLocation* location = [locations lastObject];
    [self requestLocationsWithLat:location.coordinate.latitude
                             lon:location.coordinate.longitude];
    
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    _requestLocationsHandler(nil, error);
    _requestLocationsHandler = nil;
}


@end
