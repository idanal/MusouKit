//
//  SmartTracker.h
//  see https://github.com/idanal/musouKit
//
//  Created by DANAL LUO on 4/20/16.
//  Copyright © 2016年 GREI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Controller 跟踪
 * 双击状态栏电池图标显示/隐藏控制器层次结构
 * 双击状态栏左侧运营商图标显示/隐藏视图跟踪器
 */
@interface MSSmartTracker : UIWindow
/** Enable the tracker */
@property (nonatomic) BOOL enabled;
/** Enable the view tracker */
@property (nonatomic) BOOL enableViewTracker;
/** Simple view tracker info print class name only */
@property (nonatomic) BOOL simpleViewTrackerInfo;

/** Singleton */
+ (instancetype)shared;

/** Call when enter */
- (void)enterPage:(UIViewController *)c;

@end
