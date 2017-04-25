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
}
@property (nonatomic, copy, nonnull) NSString *url;
@property (nonatomic, copy, nonnull) NSString *method;     //POST,GET,PUT...

//设置Api域名
+ (void)setupDomain:(NSString * _Nonnull)apiDomain;
+ (void)saveToken:(NSString * _Nonnull)token;

//创建实例
+ (instancetype _Nonnull)new:(NSString * _Nonnull)url;

//设置post/get/put等方法
- ( MSSimpleHttp* _Nonnull (^_Nonnull)(NSString * _Nonnull method))use;

//点语法传参 Put Key-Value
- (MSSimpleHttp* _Nonnull (^_Nonnull)(NSString * _Nonnull key, id _Nonnull val))putKV;

//同上，给swift用
- (MSSimpleHttp * _Nonnull )use:(NSString * _Nonnull)method;
- (MSSimpleHttp * _Nonnull)putKV:(NSString * _Nonnull)key val:(id _Nullable)val;

//同下，shouldCache为NO
- (void)doRequest:(void (^_Nonnull)(id _Nullable data, NSError * _Nullable error))onComplete;

/*
 * 发送请求
 * @param onComplete, data: Dictionay 或 Array; error: 网络错误
 * @param shouldCache 若为YES,若没缓存只会成功请求一次，以后是从cache读取内容直接返回
 */
- (void)doRequest:(void (^_Nonnull)(id _Nullable data, NSError * _Nullable error))onComplete shouldCache:(BOOL)shouldCache;

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
