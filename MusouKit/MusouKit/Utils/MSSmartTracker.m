//
//  SmartTracker.m
//  
//
//  Created by DANAL LUO on 2016/12/12.
//  Copyright © 2016年 GREI. All rights reserved.
//

#import "MSSmartTracker.h"
#import <objc/runtime.h>


@interface UIViewController (SmartTracker)
- (void)sm_viewDidAppear:(BOOL)animated;
- (void)old_viewDidAppear:(BOOL)animated;
@end

@implementation UIViewController (SmartTracker)

- (void)sm_viewDidAppear:(BOOL)animated{
    //call super
    [self old_viewDidAppear:animated];
    [[MSSmartTracker shared] enterPage:self];
}

- (void)old_viewDidAppear:(BOOL)animated{
    //imp has set to viewDidAppear:
}

+ (void)sm_replaceMethods{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = UIViewController.class;
        SEL old = @selector(viewDidAppear:);
        
        //save orig method imp to old_viewDidAppear, so that we can call 'super' in new method
        Method oldM = class_getInstanceMethod(cls, old);
        class_replaceMethod(cls, @selector(old_viewDidAppear:), method_getImplementation(oldM), method_getTypeEncoding(oldM));
        
        //replace orig method with new method
        Method m = class_getInstanceMethod(cls, @selector(sm_viewDidAppear:));
        class_replaceMethod(cls, old, method_getImplementation(m), method_getTypeEncoding(m));
        
    });
}

@end


@implementation MSSmartTracker

+ (instancetype)shared{
    static MSSmartTracker *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _instance = [[self alloc] initWithFrame:CGRectMake(0, 0, width, 20.0)];
    });
    return _instance;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        CGRect rect = CGRectInset(self.bounds, 2, 0);
        UILabel *textLabel = [[UILabel alloc] initWithFrame:rect];
        [self addSubview:textLabel];
        
        textLabel.minimumScaleFactor = 0.5;
        textLabel.textColor = [UIColor redColor];
        textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        textLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
        
        _textLabel = textLabel;
        
        self.windowLevel = UIWindowLevelStatusBar;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
        
        self.textLabel.hidden = YES;
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled{
#ifdef DEBUG
    
    if (_enabled != enabled){

        _enabled = enabled;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.hidden = !_enabled;
        });
    }
    
#endif
}

- (void)setEnableGlobalTrack:(BOOL)enableGlobalTrack{
#ifdef DEBUG
    if (_enableGlobalTrack != enableGlobalTrack){
        _enableGlobalTrack = enableGlobalTrack;
        
        if (_enableGlobalTrack){
            [UIViewController sm_replaceMethods];
        }
        self.enabled = enableGlobalTrack;
    }
#endif
}

- (void)onTap:(UITapGestureRecognizer *)sender{
    self.textLabel.hidden = !self.textLabel.hidden;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect rect = CGRectMake(self.bounds.size.width-50, 0, 50, 20);
    if (CGRectContainsPoint(rect, point)){
        return YES;
    }
    return NO;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
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

- (void)enterPage:(UIViewController *)c{
    UIViewController *curr = c;
    [self echo:NSStringFromClass(curr.class)];
}

- (void)exitPage:(UIViewController *)c{
    UIViewController *curr = [self getCurrentVC];
    if ([curr isKindOfClass:[UITabBarController class]]){
        curr = [(UITabBarController *)curr selectedViewController];
        if ([curr isKindOfClass:[UINavigationController class]]){
            curr = [(UINavigationController *)curr topViewController];
        }
    }
    [self echo:NSStringFromClass(curr.class)];
}

- (void)echo:(NSString *)text{
    _textLabel.text = text;
}

@end
