//
//  SmartTracker.m
//  
//
//  Created by DANAL LUO on 2016/12/12.
//  Copyright © 2016年 GREI. All rights reserved.
//

#import "MSSmartTracker.h"
#import <objc/runtime.h>


#pragma mark - UIViewController Extensions

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



#pragma mark - MSSmartTracker

@interface MSSmartTracker(){
    __weak UILabel *_hierarchyLbl;
    __weak UIViewController *_currentVC;
}
@property (nonatomic) BOOL enabled;
@property (nonatomic, weak) UILabel *textLabel;
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
        self.backgroundColor = [UIColor clearColor];
        
#ifdef DEBUG
        self.userInteractionEnabled = YES;
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
#endif
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
    if ([sender locationOfTouch:0 inView:self].x > 50){ //Tap at right
        
        self.textLabel.hidden = !self.textLabel.hidden;
        _hierarchyLbl.hidden = self.textLabel.hidden;
        
    } else if (!self.textLabel.hidden) {    //Tap at left
        
        _hierarchyLbl.hidden = !_hierarchyLbl.hidden;
        if (!_hierarchyLbl){
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 320, 100)];
            lbl.numberOfLines = 0;
            lbl.font = [UIFont systemFontOfSize:14];
            lbl.opaque = YES;
            lbl.backgroundColor = [UIColor whiteColor];
            lbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
            lbl.layer.borderWidth = 1.0;
            [self addSubview:lbl];
            _hierarchyLbl = lbl;
        }
        [self printVCHierarchy];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
#ifdef DEBUG
    CGRect rightRect = CGRectMake(self.bounds.size.width-50, 0, 50, 20);
    CGRect leftRect = CGRectMake(0, 0, 50, 20);
    if (CGRectContainsPoint(rightRect, point)){
        return YES;
    } else if (CGRectContainsPoint(leftRect, point)){
        return YES;
    }
    return NO;
#else
    return NO;
#endif
}

- (UIViewController *)getCurrentVC{
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
    _currentVC = c;
    [self echo:NSStringFromClass(c.class)];
    [self printVCHierarchy];
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

- (void)printVCHierarchy{
    NSMutableString *str = [NSMutableString new];
    NSMutableArray *vcs = [NSMutableArray new];
    UIViewController *cur = _currentVC;
    while (cur) {
        [vcs insertObject:[NSString stringWithFormat:@"%@", cur.class] atIndex:0];
        cur = cur.parentViewController;
    }
    char buff[32];
    bzero(buff, sizeof(buff));
    int i = 0;
    for (NSString *vc in vcs){
        memset(buff, '-', i);
        [str appendFormat:@" %s|%@\n", buff, vc];
        i += 4;
    }
    _hierarchyLbl.text = str;
    [_hierarchyLbl sizeToFit];
    CGRect frame = _hierarchyLbl.frame;
    frame.size.width = self.bounds.size.width;
    _hierarchyLbl.frame = frame;
}

@end
