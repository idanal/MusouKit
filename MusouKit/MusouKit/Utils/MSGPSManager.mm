//
//  MSGPSManager.mm
//  
//
//  Created by danal on 1/20/15.
//  Copyright (c) 2015 danal. All rights reserved.
//

#include <stdio.h>
#include <math.h>
#include "MSGPSManager.h"


/**
 * 坐标系统转换类
 *
 * Google:火星坐标（GCJ-02）
 * Baidu: 百度坐标（BD-09）
 * GPS:   地球坐标（WGS-84）
 */
class GPS {
private:
    static double pi;
    static double a;
    static double ee;
    
public:
    typedef struct {
        double latitude;
        double longitude;
    } Coordinate;
    
public:
    static Coordinate wgs84_To_Gcj02(double lat, double lon);
    static Coordinate wgs84_To_Bd09(double lat, double lon);
    static Coordinate gcj_To_Gps84(double lat, double lon);
    static Coordinate gcj02_To_Bd09(double gg_lat, double gg_lon);
    static Coordinate bd09_To_Gcj02(double bd_lat, double bd_lon);
    static Coordinate bd09_To_Gps84(double bd_lat, double bd_lon);
    
    static Coordinate transform(double lat, double lon);
    static double transformLat(double x, double y);
    static double transformLon(double x, double y);
    static bool outOfChina(double lat, double lon);
};


//////////////////////////////////////////////


double GPS::pi = 3.1415926535897932384626;
double GPS::a = 6378245.0;
double GPS::ee = 0.00669342162296594323;

/**
 * 84 to 火星坐标系 (GCJ-02) World Geodetic System ==> Mars Geodetic System
 * iOS为例: GPS取得坐标为WGS84,需要转换为GCJ02坐标显示到地图上。
 */
GPS::Coordinate GPS::wgs84_To_Gcj02(double lat, double lon) {
    if (GPS::outOfChina(lat, lon)) {
        return {lat,lon};
    }
    double dLat = GPS::transformLat(lon - 105.0, lat - 35.0);
    double dLon = GPS::transformLon(lon - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    double mgLat = lat + dLat;
    double mgLon = lon + dLon;
    return {mgLat,mgLon};
}

/**
 * wgs to bd09
 */
GPS::Coordinate GPS::wgs84_To_Bd09(double lat, double lon) {
    Coordinate coord = wgs84_To_Gcj02(lat, lon);
    return gcj02_To_Bd09(coord.latitude, coord.longitude);
}

/**
 * * 火星坐标系 (GCJ-02) to 84
 * */
GPS::Coordinate GPS::gcj_To_Gps84(double lat, double lon) {
    GPS::Coordinate cood = GPS::transform(lat, lon);
    double latitude = lat * 2 - cood.latitude;
    double lontitude = lon * 2 - cood.longitude;
    return {latitude, lontitude};
}

/**
 * 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换算法 将 GCJ-02 坐标转换成 BD-09 坐标
 */
GPS::Coordinate GPS::gcj02_To_Bd09(double gg_lat, double gg_lon) {
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * pi);
    double bd_lon = z * cos(theta) + 0.0065;
    double bd_lat = z * sin(theta) + 0.006;
    return {bd_lat, bd_lon};
}

/**
 * * 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换算法 * * 将 BD-09 坐标转换成GCJ-02 坐标
 */
GPS::Coordinate GPS::bd09_To_Gcj02(double bd_lat, double bd_lon) {
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * pi);
    double gg_lon = z * cos(theta);
    double gg_lat = z * sin(theta);
    return {gg_lat, gg_lon};
}

/**
 * (BD-09)-->84
 */
GPS::Coordinate GPS::bd09_To_Gps84(double bd_lat, double bd_lon) {
    
    GPS::Coordinate gcj02 = bd09_To_Gcj02(bd_lat, bd_lon);
    GPS::Coordinate map84 = gcj_To_Gps84(gcj02.latitude, gcj02.longitude);
    return map84;
    
}

bool GPS::outOfChina(double lat, double lon) {
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

GPS::Coordinate GPS::transform(double lat, double lon) {
    if (outOfChina(lat, lon)) {
        return {lat, lon};
    }
    double dLat = GPS::transformLat(lon - 105.0, lat - 35.0);
    double dLon = GPS::transformLon(lon - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    double mgLat = lat + dLat;
    double mgLon = lon + dLon;
    return {mgLat, mgLon};
}

double GPS::transformLat(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y
    + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

double GPS::transformLon(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1
    * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0
                                                     * pi)) * 2.0 / 3.0;
    return ret;
}


#pragma mark - OC Api

@interface MSGPSManager () <CLLocationManagerDelegate, UIAlertViewDelegate>{
    CLLocationManager *_locMgr;
    void (^_tmpBlock)(MSGPSManager *mgr);
}
@end

@implementation MSGPSManager

+ (instancetype)shared{
    static MSGPSManager *gps;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gps = [[self alloc] init];
    });
    return gps;
}

- (id)init{
    self = [super init];
    if (self){
        _locMgr = [[CLLocationManager alloc] init];
        _locMgr.distanceFilter = 100;
        _locMgr.desiredAccuracy = kCLLocationAccuracyBest;
        _locMgr.delegate = self;
    }
    return self;
}

- (void)startLocation{
    [_locMgr requestWhenInUseAuthorization];
    [_locMgr startUpdatingLocation];
}

- (void)stopLocation{
    [_locMgr stopUpdatingLocation];
}

- (void)startLocation:(void (^)(MSGPSManager *))tmpBlock{
    _tmpBlock = tmpBlock;
    [self startLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocationCoordinate2D coord = locations.lastObject.coordinate;
#ifdef DEBUG
    printf("%f,%f\n", coord.latitude, coord.longitude);
#endif
    if (fabs(coord.latitude - self.coord.latitude) < 0.0005
        || fabs(coord.longitude - self.coord.longitude) < 0.0005){
        [manager stopUpdatingLocation];
    }
    
    if (_tmpBlock) _tmpBlock(self);
    if (_onLocationUpdated) _onLocationUpdated(self);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (error.code == kCLErrorDenied){
        [self alertServiceTips];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusRestricted
        || status == kCLAuthorizationStatusDenied){
    }
}

- (void)alertServiceTips{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"请在系统 设置-隐私 中打开定位服务"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"设置", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


+ (void)geocodeAddress:(NSArray<NSString *> *)pcd complete:(void (^)(CLLocation *loc))complete{
    NSString *addr = [pcd componentsJoinedByString:@""];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        complete(placemarks.firstObject.location);
    }];
}

#pragma mark - Coord converters

+ (CLLocationCoordinate2D)gpsToGcj02:(CLLocationCoordinate2D)coord{
    GPS::Coordinate ret = GPS::wgs84_To_Gcj02(coord.latitude, coord.longitude);
    return CLLocationCoordinate2DMake(ret.latitude, ret.longitude);
}

+ (CLLocationCoordinate2D)gcj02ToGps:(CLLocationCoordinate2D)coord{
    GPS::Coordinate ret = GPS::gcj_To_Gps84(coord.latitude, coord.longitude);
    return CLLocationCoordinate2DMake(ret.latitude, ret.longitude);
}

+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)coord{
    GPS::Coordinate ret = GPS::gcj02_To_Bd09(coord.latitude, coord.longitude);
    return CLLocationCoordinate2DMake(ret.latitude, ret.longitude);
}

+ (CLLocationCoordinate2D)gpsToBd09:(CLLocationCoordinate2D)coord{
    return [self gcj02ToBd09:[self gpsToGcj02:coord]];
}

+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)coord{
    GPS::Coordinate ret = GPS::bd09_To_Gcj02(coord.latitude, coord.longitude);
    return CLLocationCoordinate2DMake(ret.latitude, ret.longitude);
}

+ (CLLocationCoordinate2D)bd09ToGps:(CLLocationCoordinate2D)coord{
    GPS::Coordinate ret = GPS::bd09_To_Gps84(coord.latitude, coord.longitude);
    return CLLocationCoordinate2DMake(ret.latitude, ret.longitude);
}

@end
