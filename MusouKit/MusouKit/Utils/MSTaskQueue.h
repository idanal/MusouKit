//
//  MSTaskQueue.h
//  GIFAlbum
//
//  Created by danal on 8/24/15.
//  Copyright (c) 2015 danal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSTaskQueue;

@interface MSTask : NSObject
@property (nonatomic, readonly) BOOL running;
@property (nonatomic, assign, readonly) MSTaskQueue *taskQueue;

- (void)start;
- (void)cancel;
//When finished or canceled
- (void)onFinish;
@end


@interface MSTaskQueue : NSObject
{
    NSLock *_lock;
    NSMutableArray *_tasks;
    NSMutableArray *_runnings;
}
@property (nonatomic, assign) NSInteger maxConcurrent; //Default 4

+ (instancetype)standardQueue;

- (void)addTask:(MSTask *)t;
- (void)removeTask:(MSTask *)t;
//You should never call this
- (void)finishTask:(MSTask *)t;
@end
