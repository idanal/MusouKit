//
//  MSHttpClient.h
//  JinJin
//
//  Created by danal.luo on 15/7/22.
//  Copyright (c) 2015年 danal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSHttpRequest;
@class MSHttpResponse;

@interface MSHttpClient : NSObject

- (void)execute:(MSHttpRequest *)req onComplete:(void(^)(NSData *data, NSError *err))onComplete;
- (void)doGet:(MSHttpRequest *)req onComplete:(void(^)(NSData *data, NSError *err))onComplete;
- (void)doPost:(MSHttpRequest *)req onComplete:(void(^)(NSData *data, NSError *err))onComplete;
- (void)cancel;

@end

//Request
@interface MSHttpRequest : NSObject {
    NSMutableDictionary *_params;
    NSString *_method;
    NSString *_url;
}
- (NSString *)method;
- (void)setMethod:(NSString *)method;
- (NSString *)url;
- (void)setUrl:(NSString *)url;

/** Put a key/value pair */
- (void)putValue:(id)value forParam:(NSString *)param;
/** Build params in this method */
- (NSDictionary *)buildParams;
/** Shortcut */
- (void)execute:(void(^)(NSData *data, NSError *err))onComplete;
@end

//Resonse
@interface MSHttpResponse : NSObject
/** 
 * Designed initializer
 * @param data Binary for HttpResponse,or Json object for JsonResponse
 * @return instance
 */
+ (instancetype)create:(NSData *)data;
- (instancetype)initWithData:(NSData *)data;
@end

//Json request
@interface MSJsonRequest : MSHttpRequest
@end

//Json response
@interface MSJsonResponse : MSHttpResponse
@end

//Convert json data to foundation object
@interface NSData (MSHttpClient_JSON)
- (id)toFoundation;
@end

//Test url @"http://vgirl.sinaapp.com/1.php";
