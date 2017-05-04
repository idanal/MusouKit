//
//  MSTimerButton.h
//  MusouKit
//
//  Created by danal.luo on 17/5/3.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTimerButton : UIButton {
    __weak NSTimer *_timer;
}
/** Start seconds, default 0 */
@property (nonatomic, assign) NSInteger seconds;

/** Start with a tick callback */
- (void)startWithTick:(void (^)(MSTimerButton *))tick;

/** Stop, You must call it explicit */
- (void)stop;

@end
