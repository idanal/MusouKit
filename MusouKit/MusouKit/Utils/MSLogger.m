//
//  MSLogger.m
//  MusouKit
//
//  Created by DANAL LUO on 2017/5/12.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSLogger.h"

@interface MSLogger (){
    dispatch_queue_t _queue;
}
@end

@implementation MSLogger

+ (instancetype)shared{
    static MSLogger *logger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[self alloc] init];
    });
    return logger;
}

- (id)init{
    self = [super init];
    if (self){
        _queue = dispatch_queue_create("logger", nil);
    }
    return self;
}

- (NSString *)logPath{
    static NSString *file;
    if (!file){
        file = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        file = [file stringByAppendingPathComponent:@"log"];
    }
    return file;
}

- (void)logd:(NSString *)content{
    
    dispatch_async(_queue, ^{
        
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.logPath error:nil];
        NSNumber *fileSize = [attrs objectForKey:NSFileSize];
        if (fileSize.unsignedLongLongValue > 500*1024){
            [self clear];
        }
        
        NSString *now = [NSDate date].description;
        FILE *f = fopen(self.logPath.UTF8String, "a+");
        fputs(now.UTF8String, f);
        fputs(content.UTF8String, f);
        fputs("\n", f);
        fclose(f);
        
    });
}

- (NSString *)readLog{
    return [NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil];
}

- (NSNumber *)logSize{
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.logPath error:nil];
    return [attrs objectForKey:NSFileSize];
}

- (void)clear{
    unlink(self.logPath.UTF8String);
}

@end
