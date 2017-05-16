//
//  MSSimpleHttp.m
//  MusouKit
//
//  Created by DANAL LUO on 2017/4/25.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSSimpleHttp.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>


@implementation MSSimpleHttp

static NSString *s_Domain;

+ (void)setupDomain:(NSString *)apiDomain{
    s_Domain = apiDomain;
}

+ (void)saveToken:(NSString *)token{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"tk"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)readToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"tk"];
}

+ (NSString *)md5Data:(NSData *)data{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)urlEncodeString:(NSString *)str{
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (instancetype)new:(NSString *)url{
    MSSimpleHttp *h = [[self alloc] init];
    h.url = url;
    return h;
}

- (id)init{
    self = [super init];
    if (self){
        _params = [NSMutableDictionary new];
        _method = @"GET";
    }
    return self;
}

- (void)put:(id)value key:(NSString *)key{
    if (key.length > 0 && value != nil) _params[key] = value;
}

+ (MSSimpleHttp* (^)(NSString *url))make{
    MSSimpleHttp *h = [self new];
    return ^(NSString *url){
        h.url = url;
        return h;
    };
}

- (MSSimpleHttp* (^)(NSString *))use{
    return ^(NSString *method){
        self.method = method;
        return self;
    };
}

- (MSSimpleHttp* (^)(BOOL))cacheResult{
    return ^(BOOL cacheResult){
        self->_cacheResult = cacheResult;
        return self;
    };
}

- (MSSimpleHttp* (^)(id, NSString *))put{
    return ^(id val, NSString *key){
        [self put:val key:key];
        return self;
    };
}

- (MSSimpleHttp* (^)(NSString *, id))putKV{
    return ^(NSString *key, id val){
        [self put:val key:key];
        return self;
    };
}

- (void)iterateDict:(NSDictionary *)target dest:(NSMutableDictionary *)dest{
    for (NSString *k in target){
        id obj = [target objectForKey:k];
        if ([obj isKindOfClass:[NSDictionary class]]){
            NSData *json = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
            dest[k] = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        } else {
            dest[k] = obj;
        }
    }
}

/** Send a request that support cache */
- (void)doRequest:(void (^)(id, NSError *))onComplete{
    
    BOOL shouldCache = _cacheResult;
    
    NSString *path = [[self class] cacheFile:_url];
    if (shouldCache && [[NSFileManager defaultManager] fileExistsAtPath:path]){
        
        NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:path];
        onComplete(data, nil);
        
    } else {
        
        //Parse response
        void (^parseBlock)(NSData *data, NSError *error) = ^(NSData *data, NSError *error){
            
            id json = nil;
            if (data != nil){
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            }
            if(shouldCache && json){
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [data writeToFile:path atomically:YES];
                });
            }
            
#ifdef DEBUG
            NSLog(@"\n\n==>onResponse [%@]:%@ \n\n", self.url, json);
#endif
            
            onComplete(json, error);
        };
        
        //Send request
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        request.HTTPMethod = self.method;
        
        NSString *url;
        NSString *urlEncoded;
        
        NSMutableString *query = [NSMutableString new];
        __block NSInteger i = 0;
        [_params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (i > 0){
                [query appendString:@"&"];
            }
            [query appendFormat:@"%@=%@", key, obj];
            ++i;
        }];
        
        if ([self.method.uppercaseString isEqualToString:@"GET"]){
            
            url = self.url;
            if (query.length > 0){
                if ([url containsString:@"?"]){
                    url = [NSString stringWithFormat:@"%@&%@", url, query];
                } else {
                    url = [NSString stringWithFormat:@"%@?%@", url, query];
                }
            }
            urlEncoded = [[self class] urlEncodeString:url];
            request.URL = [NSURL URLWithString:urlEncoded];
            
        } else {
            
            url = self.url;
            urlEncoded = [[self class] urlEncodeString:url];
            request.URL = [NSURL URLWithString:urlEncoded];
            request.HTTPBody = [query dataUsingEncoding:NSUTF8StringEncoding];
        }
        
#ifdef DEBUG
        NSLog(@"\n\n==>doRequest: %@ \n\n==>with params: %@ \n\n", url, _params);
#endif
        
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg];
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                parseBlock(data, error);
            });
            
        }];
        [task resume];
        
    }
    
}

- (MSSimpleHttp *)use:(NSString *)method{
    return self.use(method);
}

- (MSSimpleHttp *)cacheResult:(BOOL)cacheResult{
    return self.cacheResult(cacheResult);
}

- (MSSimpleHttp *)putKV:(NSString *)key val:(id)val{
    return self.putKV(key, val);
}

+ (void)clearAllCache{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"http"];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:path];
    for (NSString *f in files){
        [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:f] error:nil];
    }
}

+ (void)clearCache:(NSString *)forUrl{
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheFile:forUrl] error:nil];
}

+ (NSString *)cacheFile:(NSString *)forUrl{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"http"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *urlIdent = [self urlEncodeString:forUrl];
    urlIdent = [urlIdent stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    urlIdent = [urlIdent stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    return [path stringByAppendingPathComponent:urlIdent];
}

@end



@implementation MSHttpResult

+ (instancetype)new:(NSDictionary *)d{
    MSHttpResult *r = [[self alloc] init];
    r.code = [d[@"code"] integerValue];
    r.success = [d[@"success"] integerValue];
    r.message = d[@"msg"];
    return r;
}

@end
