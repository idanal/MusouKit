//
//  MSTimerButton.h
//  MusouKit
//
//  Created by danal.luo on 17/5/3.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTimerButton : UIView {
    __weak NSTimer *_timer;
}
/** Start seconds, default 0 */
@property (nonatomic, assign) NSInteger startSeconds;
/** Tick callback */
@property (nonatomic, copy) void (^onTick)(MSTimerButton *btn);

- (void)start;
- (void)stop;

@end
