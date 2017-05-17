//
//  MSHttpRequest.m
//  MusouKit
//
//  Created by DANAL LUO on 2017/5/17.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSHttpRequest.h"

static NSString *boundary = @"=======B-o-u-n-d-a-r-y=======";

@implementation NSMutableURLRequest (Musou)

- (void)beginAppending{
    if (self.HTTPBody == nil){
        self.HTTPBody = [NSMutableData new];
        [self setContentType:@"multipart/form-data; charset=utf-8"];
    }
}

- (void)endAppending{
    [self appendEndBoundary];
}

- (void)setContentType:(NSString *)contentType{
    if ([contentType.lowercaseString containsString:@"multipart/form-data"]){
        
        [self setValue:[NSString stringWithFormat:@"%@; boundary=\"%@\"", contentType, boundary] forHTTPHeaderField:@"Content-Type"];
    } else {
        
        [self setValue:[NSString stringWithFormat:@"%@", contentType] forHTTPHeaderField:@"Content-Type"];
    }
}

- (void)setBodyData:(NSData *)data{
    self.HTTPBody = data;
}

#pragma mark - For Multipart form

- (NSMutableData *)bodyData{
    if ([self.HTTPBody isKindOfClass:[NSMutableData class]]){
        return (NSMutableData *)self.HTTPBody;
    }
    return nil;
}

- (void)appendFormValue:(id)val name:(NSString *)name{
    NSString *str = [NSString stringWithFormat:@"%@", val];
    [self.bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",name] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendFormData:(NSData *)data name:(NSString *)name{
    [self.bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:data];
}

- (void)appendFileFormData:(NSData *)data name:(NSString *)name filename:(NSString *)filename{
    [self.bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.bodyData appendData:data];
}

- (void)appendEndBoundary{
    [self.bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setValue:[NSString stringWithFormat:@"%@", @([self.bodyData length])] forHTTPHeaderField:@"Content-Length"];
}

@end
