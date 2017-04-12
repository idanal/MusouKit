//
//  MSTaskQueue.m
//  GIFAlbum
//
//  Created by danal on 8/24/15.
//  Copyright (c) 2015 danal. All rights reserved.
//

#import "MSTaskQueue.h"

@implementation MSTask

- (void)start{
    _running = YES;
}

- (void)cancel{
    [self onFinish];
}

- (void)onFinish{
    _running = NO;
    [_taskQueue finishTask:self];
}

- (void)setTaskQueue:(MSTaskQueue *)taskQueue{
    _taskQueue = taskQueue;
}

@end


@implementation MSTaskQueue

+ (instancetype)standardQueue{
    @synchronized(self){
        static MSTaskQueue *__queue = nil;
        if (!__queue) __queue = [[self alloc] init];
        return __queue;
    }
}

- (id)init{
    self = [super init];
    if (self){
        _maxConcurrent = 4;
        _lock = [[NSLock alloc] init];
        _tasks = [[NSMutableArray alloc] init];
        _runnings = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addTask:(MSTask *)t{
    [_lock lock];
    t.taskQueue = self;
    [_tasks addObject:t];
    [_lock unlock];
    [self _runLoop];
}

- (void)removeTask:(MSTask *)t{
    [_lock lock];
    [_tasks removeObject:t];
    [_runnings removeObject:t];
    [_lock unlock];
}

- (void)finishTask:(MSTask *)t{
    [self removeTask:t];
    [self _runLoop];
}

- (void)_runLoop{
    [_lock lock];
    while (_runnings.count < _maxConcurrent) {
        MSTask *t = [_tasks firstObject];
        if (!t) break;
        [_runnings addObject:t];
        [_tasks removeObject:t];
        [t start];
    }
    [_lock unlock];
}

@end
