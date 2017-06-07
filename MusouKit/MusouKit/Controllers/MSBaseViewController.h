//
//  MSBaseViewController.h
//  MusouKit
//
//  Created by danal on 13-7-17.
//  Copyright (c) 2013年 danal. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - UIViewController

@interface UIViewController (Musou)
/** Navigation bar buttons */
- (void)setLeftBarButton:(UIButton *)button;
- (void)setRightBarButtons:(UIButton *)button1,...;

- (UIButton *)barButton:(NSString *)title action:(SEL)selector;
- (UIButton *)imageBarButton:(UIImage *)image action:(SEL)selector;

- (UIBarButtonItem *)barButtonItem:(NSString *)title action:(SEL)selector;
- (UIBarButtonItem *)barButtonImageItem:(NSString *)image action:(SEL)selector;

/** Keyboard helper */
- (void)addKeyboardObserver;
- (void)removeKeyboardObserver;

/** Callbacks after keyboard show or hide   */
- (void)keyboardWillShowComplete:(CGRect)keyboardFrame;
- (void)keyboardWillHideComplete:(CGRect)keyboardFrame;

@end


#pragma mark - Storyboard

/**
 * Storyboard扩展，
 * 规则：storyboard中的identifier必须与controller类同名，则可用create方法创建实例
 */
@interface UIViewController (Storyboard)
/**
 * 静态创建controller的方法
 * 如将来需要开发ipad版，可在此方法中做智能判断来创建不同版本的controller
 * 如果是使用storyboard,则会根据storyboardName和storyboradID来创建
 */
+ (instancetype)create;
/** Name.storyboard, 默认为nil */
+ (NSString *)storyboardName;
/** storyboard Identifier, 默认为自已的类名 */
+ (NSString *)storyboradID;

@end


#pragma mark - UINavigationController

@interface UINavigationController (Musou)

- (void)flipPopViewController;
- (void)flipPushViewController:(UIViewController *)vc;

- (void)transitionPushViewController:(UIViewController *)vc;
- (void)transitionPopViewController;

@end


