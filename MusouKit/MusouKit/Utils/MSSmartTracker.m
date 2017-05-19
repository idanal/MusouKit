//
//  SmartTracker.m
//  
//
//  Created by DANAL LUO on 2016/12/12.
//  Copyright © 2016年 GREI. All rights reserved.
//

#import "MSSmartTracker.h"

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
        self.hidden = !_enabled;
    }
    
#endif
}

- (void)setEnableGlobalTrack:(BOOL)enableGlobalTrack{
#ifdef DEBUG
    if (_enableGlobalTrack != enableGlobalTrack){
        _enableGlobalTrack = enableGlobalTrack;
        self.enabled = enableGlobalTrack;
        
        if (_enableGlobalTrack){
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                
                //todo
                
            });
        }
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
