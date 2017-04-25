//
//  MSHttpClient.m
//  JinJin
//
//  Created by danal.luo on 15/7/22.
//  Copyright (c) 2015年 danal. All rights reserved.
//

#import "MSHttpClient.h"
#import "MSJSONEntity.h"


@interface MSHttpClient ()
@property (nonatomic, strong) NSURLConnection *conn;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, copy) void (^onComplete)(NSData *data, NSError *err);
@end

@implementation MSHttpClient

- (void)dealloc{
    [self cancel];
    self.conn = nil;
    self.data = nil;
    self.onComplete = nil;
}

- (void)execute:(MSHttpRequest *)req onComplete:(void (^)(NSData *, NSError *))onComplete{
    [self _execute:req method:req.method ? req.method : @"GET" onComplete:onComplete];
}

- (void)doGet:(MSHttpRequest *)req onComplete:(void (^)(NSData *, NSError *))onComplete{
    [self _execute:req method:@"GET" onComplete:onComplete];
}

- (void)doPost:(MSHttpRequest *)req onComplete:(void (^)(NSData *, NSError *))onComplete{
    [self _execute:req method:@"POST" onComplete:onComplete];
}

- (void)_execute:(MSHttpRequest *)req method:(NSString *)method  onComplete:(void (^)(NSData *data, NSError *err))onComplete{
    self.onComplete = onComplete;
    
    static NSString *boundary = @"=======B-o-u-n-d-a-r-y=======";
    @try {
        
        NSURL *url = [NSURL URLWithString:req.url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:method];
        self.request = request;
        
        NSMutableData *body = [NSMutableData data];
        NSDictionary *params = [req buildParams];
        
        //Json
        if ([req isKindOfClass:[MSJsonRequest class]]){
#ifdef DEBUG
            NSLog(@"%@ %@:\n%@",method, _request.URL, params);
#endif
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil]];
        }
        //Form
        else if ([method isEqualToString:@"POST"]) {      //POST
            if ([params count] > 0) {
                NSEnumerator *enumerator = [params keyEnumerator];
                id key = nil,obj = nil;
                while (key = [enumerator nextObject]) {
                    obj = [params objectForKey:key];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        obj = [NSString stringWithFormat:@"%@",obj];
                    }
                    //String or Number
                    if ([obj isKindOfClass:[NSString class]]){
                        
                        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[obj dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    //Image file, value is the data
                    else if ([obj isKindOfClass:[NSData class]]) {
                        
                        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n",key,key] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:obj];
                    }
                    //Binary file, value is the file dictionary
                    else if ([obj isKindOfClass:[NSDictionary class]]){
                        NSData *value = [obj objectForKey:@"value"];
                        NSString *filename = [obj objectForKey:@"filename"];
                        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",key,filename] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:value];
                    }
                }
            }
            //End mark
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"",boundary] forHTTPHeaderField:@"Content-Type"];
            
            [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:body];
            
#ifdef DEBUG
            NSLog(@"%@ %@:\n%@", method, _request.URL, params);
#endif
        }
        else {      //GET
            NSString *baseUrl = req.url;
            NSMutableString *url = nil;
            if ([baseUrl rangeOfString:@"?"].length > 0) {
                url = [NSMutableString stringWithFormat:@"%@",baseUrl];
            } else {
                url = [NSMutableString stringWithFormat:@"%@?",baseUrl];
            }
            if ([[url substringFromIndex:[url length] - 1] isEqualToString:@"&"]) {
                [url deleteCharactersInRange:NSMakeRange([url length] - 1, 1)];
            }
            for (NSString *key in params) {
                [url appendFormat:@"&%@=%@",key, [params objectForKey:key]];
            }
            _request.URL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            //[request setValue:[NSString stringWithFormat:@"bytes=%llu-",_bytesOffset] forHTTPHeaderField:@"Range"];
#ifdef DEBUG
            NSLog(@"%@ %@:\n%@", method, _request.URL, params);
#endif
        }
        
        [self start];
    
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
}

- (void)start{
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
    self.conn = conn;
    [_conn start];
}

- (void)cancel{
    [_conn cancel];
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSMutableData *data = [[NSMutableData alloc] init];
    self.data = data;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (_onComplete) _onComplete(_data, nil);
#ifdef DEBUG
//    NSString *result = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
//    NSLog(@"RESPONSE %@:\n%@",_request.URL, result);
#endif
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.data = nil;
    if (_onComplete) _onComplete(nil, error);
#ifdef DEBUG
    NSLog(@"\nRESPONSE %@:\n%@",_request.URL, error.description);
#endif
}

@end

//
@implementation MSHttpRequest

- (void)dealloc{
}

- (id)init{
    self = [super init];
    if (self){
        _params = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)method{
    return _method;
}

- (void)setMethod:(NSString *)method{
    _method = [method copy];
}

- (NSString *)url{
    return _url;
}

- (void)setUrl:(NSString *)url{
    _url = [url copy];
}

- (void)putValue:(id)value forParam:(NSString *)param{
    _params[param] = value != nil ? value : @"";
}

- (NSDictionary *)buildParams{
    return _params;
}

- (void)execute:(void (^)(NSData *, NSError *))onComplete{
    [[MSHttpClient new] execute:self onComplete:onComplete];
}

@end

//
@implementation MSHttpResponse

+ (instancetype)create:(NSData *)data{
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data{
    return [super init];
}

@end

//
@implementation MSJsonRequest

@end

//
@implementation MSJsonResponse

+ (instancetype)create:(NSData *)data{
    return [[self class] fromJSON:data];
}

@end

@implementation NSData (MSHttpClient_JSON)

- (id)toFoundation{
    NSError *err = nil;
    id json = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:&err];
    if (err){
        NSLog(@"%@",err);
    }
    return json;
}

@end


@implementation NSMutableURLRequest (Form)

static NSString *boundary = @"=======B-o-u-n-d-a-r-y=======";

- (NSMutableData *)bodyData{
    if (self.HTTPBody == nil){
        self.HTTPBody = [NSMutableData new];
        [self setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"",boundary] forHTTPHeaderField:@"Content-Type"];
    }
    return (NSMutableData *)self.HTTPBody;
}

- (instancetype)appendFormValue:(id)val name:(NSString *)name{
    NSString *str = [NSString stringWithFormat:@"%@", val];
    return [self appendFormData:[str dataUsingEncoding:NSUTF8StringEncoding] name:name];
}

- (instancetype)appendFormData:(NSData *)data name:(NSString *)name{
    [self.bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:data];
    return self;
}

- (instancetype)appendFileFormData:(NSData *)data name:(NSString *)name filename:(NSString *)filename{
    [self.bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:data];
    return self;
}

- (instancetype)appendEndBoundary{
    [self.bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setValue:[NSString stringWithFormat:@"%@", @([self.bodyData length])] forHTTPHeaderField:@"Content-Length"];
    return self;
}

@end
