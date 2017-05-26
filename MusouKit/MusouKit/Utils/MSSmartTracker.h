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
 * Controller 跟踪
 * 双击状态栏电池图标启用/禁用, 双击左上角运营商显示/隐藏控制器层次结构
 */
@interface MSSmartTracker : UIWindow
/** Enable the tracker */
@property (nonatomic) BOOL enableGlobalTrack;

/** Singleton */
+ (instancetype)shared;

/** Call when enter */
- (void)enterPage:(UIViewController *)c;

///** Call when exit */
//- (void)exitPage:(UIViewController *)c;

/** Displa a text on the bar */
- (void)echo:(NSString *)text;

@end
