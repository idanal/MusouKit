//
//  MSVersion.h
//  Musou
//
//  Created by luo danal on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSHttpClient.h"

#define kLoopupApi @"http://itunes.apple.com/lookup?id=%@"

@interface MSVersion : NSObject{
    BOOL  _done;
}
@property (retain, nonatomic) NSString *appid;
@property (copy, nonatomic) void (^completionBlock)(NSString *);

- (id)initWithAPPID:(NSString *)appid completion:(void (^)(NSString *))block;
- (void)detect;

@end
