//
//  MSGPSManager.h
//  
//
//  Created by danal on 1/20/15.
//  Copyright (c) 2015 danal. All rights reserved.
//

#ifndef Map_GPS_h
#define Map_GPS_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 * 坐标系统转换类
 *
 * Google:火星坐标（GCJ-02）
 * Baidu: 百度坐标（BD-09）
 * GPS:   地球坐标（WGS-84）
 */
@interface MSGPSManager : NSObject
/** Current location */
@property (nonatomic, assign) CLLocationCoordinate2D coord;
/** Result callback */
@property (nonatomic, copy) void (^onLocationUpdated)(MSGPSManager *mgr);

/** 单例访问 */
+ (instancetype)shared;

/** 开始定位, 在onLocationUpdated可获得结果回调 */
- (void)startLocation;

/** 停止定位 */
- (void)stopLocation;

/** tmpBlock不会被onLocationUpdated属性覆盖 */
- (void)startLocation:(void (^)(MSGPSManager *mgr))tmpBlock;

/** alert提示打开定位服务 */
- (void)alertServiceTips;

/** 把地址编码成坐标。pcd:省市区数据，区可空 */
+ (void)geocodeAddress:(NSArray<NSString *> *)pcd complete:(void (^)(CLLocation *loc))complete;

#pragma mark - Coord converters

/** Gps -> Gcj02 */
+ (CLLocationCoordinate2D)gpsToGcj02:(CLLocationCoordinate2D)coord;

/** Gps -> Bd09 */
+ (CLLocationCoordinate2D)gpsToBd09:(CLLocationCoordinate2D)coord;

/** Bd09 -> Gcj02 */
+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)coord;

/** Gcj02 -> Bd09 */
+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)coord;

@end

#endif
