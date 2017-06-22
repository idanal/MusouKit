//
//  MSTimerButton.h
//  MusouKit
//
//  Created by danal.luo on 17/5/3.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTimerButton : UIButton

/** Start with a tick callback */
- (void)startWithTick:(void (^)(MSTimerButton *))tick;

/** Stop */
- (void)stop;

@end
