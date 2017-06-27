//
//  HUDView.h
//  SideMenuController
//
//  Created by danal on 13-1-3.
//  Copyright (c) 2013年 yz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSHUDView : UIView
{
    NSTimer *_timer;
    UILabel *_textLbl;
    UILabel *_subTextLbl;
    UIImageView *_imageView;
}
@property (nonatomic, strong) UIImageView *iconView;
@property (assign, nonatomic) BOOL touchToHide;


/**
 * 延迟消失
 * @param delay 秒
 */
- (void)delayHides:(NSInteger)delay;
- (void)hide;

/**
 * 显示一条提示消息
 * @param superview 父视图
 * @param msg 消息
 * @param subtitle 消息下方的子标题
 * @return HUDView对象
 */
+ (MSHUDView *)showMessageToView:(UIView *)superview msg:(NSString *)msg subtitle:(NSString *)subtitle;

/**
 * 显示一条加载消息
 * @param superview 父视图
 * @param msg 消息
 * @param subtitle 消息下方的子标题
 * @return HUDView对象
 */
+ (MSHUDView *)showLoadingToView:(UIView *)superview msg:(NSString *)msg subtitle:(NSString *)subtitle;

/**
 * 移除superview里最顶层的hud
 */
+ (void)hideHUD:(UIView *)superview;

@end


//Extension for View
@interface UIView (HUDView)
- (void)showToast:(NSString *)msg;
- (void)showLoading:(NSString *)msg;
- (void)hideHUD;
@end
