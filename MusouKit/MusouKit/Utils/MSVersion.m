//
//  MSVersion.m
//  Musou
//
//  Created by luo danal on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MSVersion.h"


@implementation MSVersion

- (id)initWithAPPID:(NSString *)appid completion:(void (^)(NSString *))block{
    if ((self = [super init])) {
        self.appid = appid;
        self.completionBlock = block;
    }
    return self;
}

- (void)detect{
//    self.request = MSAutorelease([[MSHTTPRequest alloc] initWithDelegate:self]);
//    self.request.parseJson = YES;
//    self.request.URL = [NSURL URLWithString:[NSString stringWithFormat:kLoopupApi,self.appid]];
//    [self.request start];
//    do {
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    } while (!_done);
}

+ (void)detectWithAPPID:(NSString *)appid completion:(void (^)(NSString *))block{
}

#pragma mark - Delegate
- (void)requestDidFinishLoading:(id *)req error:(NSError *)error{
    _done = YES;
    NSDictionary *json;
//    NSLog(@"%@",json);
    int resultCount = [[json objectForKey:@"resultCount"] intValue];
    if (resultCount > 0) {
        NSArray *results = [json objectForKey:@"results"];
        NSDictionary *d = [results objectAtIndex:0];
        NSString *version = [d objectForKey:@"version"];
        NSString *name = [d objectForKey:@"trackName"];
#ifdef DEBUG
        NSLog(@"LAST VERSION:[%@] FOR APP [%@]",version,name);
#endif
        if (_completionBlock != NULL) {
            _completionBlock(version);
        }
    }
}

@end
