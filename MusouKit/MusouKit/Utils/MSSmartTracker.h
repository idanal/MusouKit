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
 */
@interface MSSmartTracker : UIWindow
/** Enable the tracker */
@property (nonatomic) BOOL enableGlobalTrack;

/** Singleton */
+ (instancetype)shared;

/** Call when enter */
- (void)enterPage:(UIViewController *)c;

/**
 Get the fastest child and hierarchy

 @param pt A point tap at the view
 @param parent Parent view to test
 @param outView The fastest child tapped
 @param hierarchy View hierarchy tapped
 */
+ (void)hitTest:(CGPoint)pt inView:(UIView *)parent outView:(UIView **)outView hierarchy:(NSMutableArray<NSString *> *)hierarchy;

@end
