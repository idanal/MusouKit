//
//  RangeSlider.h
//  GoJobNow
//
//  Created by danal on 6/1/16.
//  Copyright © 2016 Sean. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A RangeSlider: Selection range 0.0-1.0
 */
@interface MSRangeSlider : UIControl
//Labels, it's nil if not set
@property (nonatomic, assign) IBOutlet UILabel *labelLeft;
@property (nonatomic, assign) IBOutlet UILabel *labelRight;

/** Selected start value, in 0.0-1.0 */
@property (nonatomic, readonly) CGFloat startValue;
/** Selected end value, in 0.0-1.0 */
@property (nonatomic, readonly) CGFloat endValue;
//Event callback
@property (nonatomic, copy) void (^onValueChanged)(MSRangeSlider *sender);
@end
