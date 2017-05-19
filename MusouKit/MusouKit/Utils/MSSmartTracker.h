//
//  SmartTracker.h
//  
//
//  Created by DANAL LUO on 4/20/16.
//  Copyright © 2016年 GREI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Controller 跟踪，双击状态栏电池图标启用/禁用
 */
@interface MSSmartTracker : UIWindow {
}
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL enableGlobalTrack;
@property (nonatomic, weak) UILabel *textLabel;

/** Singleton */
+ (instancetype)shared;

/** Call when enter */
- (void)enterPage:(UIViewController *)c;

/** Call when exit */
- (void)exitPage:(UIViewController *)c;

/** Displa a text on the bar */
- (void)echo:(NSString *)text;

@end
