//
//  MSSimpleHttp.h
//  MusouKit
//
//  Created by DANAL LUO on 2017/4/25.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSHttpResult;

/**
 * 一个简单的http请求类
 */
@interface MSSimpleHttp : NSObject {
    NSMutableDictionary *_params;
    NSDictionary *_headers;
    NSURLSessionTask *_task;
    BOOL _cacheResult;
}
@property (nonatomic, copy, nonnull) NSString *url;
@property (nonatomic, copy, nonnull) NSString *method;     //POST,GET,PUT...
@property (nonatomic, copy, nullable) NSString *contentType;    //Default nil

//设置Api域名
+ (void)setupDomain:(NSString * _Nonnull)apiDomain;
+ (void)saveToken:(NSString * _Nonnull)token;

//创建实例
+ (instancetype _Nonnull)new:(NSString * _Nonnull)url;

//设置post/get/put等方法
- (MSSimpleHttp* _Nonnull (^_Nonnull)(NSString * _Nonnull method))use;

//是否缓存结果
- (MSSimpleHttp* _Nonnull (^_Nonnull)(BOOL cacheResult))cacheResult;

//添加header
- (MSSimpleHttp* _Nonnull (^_Nonnull)(NSDictionary * _Nonnull))addHeaders;

//点语法传参 Put Key-Value
- (MSSimpleHttp* _Nonnull (^_Nonnull)(NSString * _Nonnull key, id _Nonnull val))putKV;


//同上，给swift用
- (MSSimpleHttp * _Nonnull)use:(NSString * _Nonnull)method;
- (MSSimpleHttp * _Nonnull)cacheResult:(BOOL)cacheResult;
- (MSSimpleHttp * _Nonnull)addHeaders:(NSDictionary * _Nonnull)headers;
- (MSSimpleHttp * _Nonnull)putKV:(NSString * _Nonnull)key val:(id _Nullable)val;

/*
 * 发送请求
 * @param onComplete, data: Dictionay 或 Array; error: 网络错误
 */
- (void)doRequest:(void (^_Nonnull)(id _Nullable data, NSError * _Nullable error))onComplete;

/**
 * 发送NSURLRequest请求, 不缓存
 */
- (void)doURLRequest:(NSURLRequest * _Nonnull)req onComplete:(void (^_Nonnull)(id _Nullable data, NSError * _Nullable error))onComplete;

/**
 * 取消
 */
- (void)cancel;

//清理Cache
+ (void)clearCache:(NSString * _Nonnull)forUrl;
+ (void)clearAllCache;

@end


//Simple result
@interface MSHttpResult : NSObject
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy, nullable) NSString *message;
//Create with dict
+ (instancetype _Nonnull)new:(NSDictionary * _Nullable)d;
@end
