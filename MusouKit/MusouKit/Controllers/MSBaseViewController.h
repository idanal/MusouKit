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


#pragma mark - UINavigationController

@interface UINavigationController (Musou)

- (void)flipPopViewController;
- (void)flipPushViewController:(UIViewController *)vc;

- (void)transitionPushViewController:(UIViewController *)vc;
- (void)transitionPopViewController;

@end


