//
//  MSTimerButton.m
//  MusouKit
//
//  Created by danal.luo on 17/5/3.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSTimerButton.h"

@interface MSTimerButton ()
@property (nonatomic, strong) dispatch_source_t timer;
/** Tick callback */
@property (nonatomic, copy) void (^onTick)(MSTimerButton *);
@end

@implementation MSTimerButton

- (void)dealloc{
    [self stop];
#ifdef DEBUG
    NSLog(@"[%@ dealloc]", self);
#endif
}

- (void)startWithTick:(void (^)(MSTimerButton *))tick{
    [self stop];
    
    self.onTick = tick;
    
    __weak typeof(self) self_ = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        
        self_.onTick(self_);
        
    });
    dispatch_resume(timer);
    _timer = timer;
}

- (void)stop{
    if (_timer){
        dispatch_source_cancel(_timer);
        self.timer = nil;
    }
}

@end
