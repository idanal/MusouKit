//
//  MSBaseViewController.m
//  MusouKit
//
//  Created by danal on 13-7-17.
//  Copyright (c) 2013年 danal. All rights reserved.
//

#import "MSBaseViewController.h"

#pragma mark - Additions ---------------------------------------------

@implementation UIViewController (Musou)

//Navigation bar
- (void)setLeftBarButton:(UIButton *)button{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7){
        UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        fix.width = -10.f;
        self.navigationItem.leftBarButtonItems = @[fix,item];
    } else {
        self.navigationItem.leftBarButtonItem = item;
    }
}

- (void)setRightBarButtons:(UIButton *)button1,...{
    va_list args;
    va_start(args, button1);
    
    CGFloat w = 0.f, h = 32.f, mar = 5.f, x = 0;
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    
    UIButton *button = button1;             //get the 1st param
    while (button) {
        w = button.bounds.size.width;
        button.frame = CGRectMake(x, 0, w, h);
        [customView addSubview:button];
        x += mar+w;
        
        button = va_arg(args, UIButton *); //get next
    }
    va_end(args);
    customView.frame = CGRectMake(0, 0, x-mar, h);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:customView];
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7){
        UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        fix.width = -10.f;
        self.navigationItem.rightBarButtonItems = @[fix,item];
    } else {
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (UIButton *)barButton:(NSString *)title action:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 32.f, 32.f);
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)imageBarButton:(UIImage *)image action:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 32.f, 32.f);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIBarButtonItem *)barButtonItem:(NSString *)title action:(SEL)selector{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:selector];
    return item;
}

- (UIBarButtonItem *)barButtonImageItem:(NSString *)image action:(SEL)selector{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:image] style: UIBarButtonItemStylePlain target:self action:selector];
    return item;
}

#pragma mark - Keyboard

- (UIViewController *)findCurrentVC{
    @try {
        
        UIViewController *result = nil;
        
        UIWindow * window = [[[UIApplication sharedApplication] windows] firstObject];
        if (window.windowLevel != UIWindowLevelNormal){
            
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows){
                if (tmpWin.windowLevel == UIWindowLevelNormal){
                    window = tmpWin;
                    break;
                }
            }
        }
        
        UIView *frontView = [[window subviews] firstObject];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            result = nextResponder;
        else
            result = window.rootViewController;
        
        return result;
        
    } @catch (NSException *exception) {
        
        NSLog(@"%@", exception);
        
    }
}

- (void)addKeyboardObserver{
    [self removeKeyboardObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardShowHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardShowHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)removeKeyboardObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (UIView *)findResponder:(UIView *)view{
    if (view.isFirstResponder){
        return view;
    }
    UIView *ret;
    for (UIView *subv in view.subviews){
        if (subv.isFirstResponder){
            return subv;
        } else {
            ret = [self findResponder:subv];
            if (ret){
                return ret;
            }
        }
    }
    return nil;
}

- (void)keyboardWillShowComplete:(CGRect)keyboardFrame{
    UIView *responder = [self findResponder:self.view];
    UIView *view = self.view;
    
    if (responder){
        CGRect rect = [view convertRect:responder.frame fromView:responder.superview];
#ifdef DEBUG
        NSLog(@"%s %@", __FILE__, NSStringFromCGRect(rect));
#endif
        if (rect.origin.y + rect.size.height < self.view.bounds.size.height-keyboardFrame.size.height){
            return;
        }
    }
    
    CGRect rect = self.view.frame;
    rect.origin.y = -keyboardFrame.size.height;
    if (rect.size.height < [UIScreen mainScreen].bounds.size.height){
        rect.origin.y += [UIScreen mainScreen].bounds.size.height - rect.size.height;
    }
    self.view.frame = rect;
    
}

- (void)keyboardWillHideComplete:(CGRect)keyboardFrame{
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    if (rect.size.height < [UIScreen mainScreen].bounds.size.height){
        rect.origin.y = [UIScreen mainScreen].bounds.size.height - rect.size.height;
    }
    self.view.frame = rect;
}


- (void)_keyboardShowHide:(NSNotification *)noti{
    NSValue *value = [noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    
    [UIView animateWithDuration:.25f animations:^{
        
        if ([noti.name isEqualToString:UIKeyboardWillShowNotification]){
            [self keyboardWillShowComplete:keyboardRect];
        } else {
            [self keyboardWillHideComplete:keyboardRect];
        }
        
    } completion:^(BOOL b){
        
    }];
}

- (void)dismissKeyboard{
    [self.view endEditing:YES];
}

@end


#pragma mark - UINavigationController

@implementation UINavigationController (Musou)

#define kFlipDuration 0.7f
- (void)flipPopViewController{
    [UIView transitionWithView:self.view
                      duration:kFlipDuration
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self popViewControllerAnimated:NO];
                    }
                    completion:^(BOOL finished){
                    }];
    
}

- (void)flipPushViewController:(UIViewController *)vc{
    [UIView transitionWithView:self.view
                      duration:kFlipDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self pushViewController:vc animated:NO];
                    }
                    completion:^(BOOL finished){
                    }];
    
}

- (void)transitionPushViewController:(UIViewController *)vc{
    CATransition *t = [[CATransition alloc] init];
    t.type = kCATransitionPush,
    t.subtype = kCATransitionFromTop;
    t.duration = .4f;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.view.layer addAnimation:t forKey:@"TRAN_PUSH"];
    [self pushViewController:vc animated:NO];
}

- (void)transitionPopViewController{
    CATransition *t = [[CATransition alloc] init];
    t.type = kCATransitionPush,
    t.subtype = kCATransitionFromBottom;
    t.duration = .4f;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.view.layer addAnimation:t forKey:@"TRAN_POP"];
    [self popViewControllerAnimated:NO];
}

- (void)replacePushViewController:(UIViewController *)vc animated:(BOOL)animated{
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    [controllers removeLastObject];
    [controllers addObject:vc];
    [self setViewControllers:controllers animated:animated];
}

- (void)replacePopViewController:(UIViewController *)vc animated:(BOOL)animated{
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    [controllers insertObject:vc atIndex:self.viewControllers.count-2];
    [controllers removeLastObject];
    [self setViewControllers:controllers animated:animated];
}

@end
