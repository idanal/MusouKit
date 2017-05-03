//
//  MSTimerButton.m
//  MusouKit
//
//  Created by danal.luo on 17/5/3.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSTimerButton.h"

@implementation MSTimerButton

- (void)start{
    if (_timer){
        [self stop];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void)stop{
    [_timer invalidate];
    _timer = nil;
}

- (void)tick:(NSTimer *)t{
    if (_onTick) _onTick(self);
}

@end
