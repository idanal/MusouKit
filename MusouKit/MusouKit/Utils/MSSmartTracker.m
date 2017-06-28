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
    __weak UILabel *_vcHierarchyLbl;
    __weak UILabel *_viewHierarchyLbl;
    __weak UIViewController *_currentVC;
    
    dispatch_block_t _hideBlock;
    
    //Fps
    int  _framesPerSecond;
    CFTimeInterval _lastTimestamp;
    __weak UILabel *_fpsLbl;
    __weak CADisplayLink *_displayLink;
}
@property (nonatomic, weak) UILabel *viewTracker;
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
        
        self.simpleViewTrackerInfo = YES;
        self.userInteractionEnabled = YES;
        self.windowLevel = UIWindowLevelStatusBar;
        
        UILabel *viewTracker = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        viewTracker.center = CGPointMake(self.bounds.size.width/2, 20);
        viewTracker.text = @"+";
        viewTracker.font = [UIFont boldSystemFontOfSize:20];
        viewTracker.textColor = [UIColor redColor];
        viewTracker.textAlignment = NSTextAlignmentCenter;
        viewTracker.clipsToBounds = YES;
        viewTracker.layer.borderWidth = 2.0;
        viewTracker.layer.borderColor = [UIColor redColor].CGColor;
        viewTracker.layer.cornerRadius = viewTracker.bounds.size.width/2;
        viewTracker.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:.3];
        viewTracker.hidden = YES;
        [self addSubview:viewTracker];
        _viewTracker = viewTracker;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled{
    if (_enabled != enabled){
        _enabled = enabled;
        
        if (_enabled){
            [UIViewController sm_replaceMethods];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.hidden = !_enabled;
        });
    }
}

- (void)setEnableFpsTracker:(BOOL)enableFpsTracker{
    if (!self.enabled){
        NSLog(@"SmartTracker is not enabled");
        return;
    }
    if (_enableFpsTracker != enableFpsTracker){
        _enableFpsTracker = enableFpsTracker;
        
        if (_enableFpsTracker){
            
            UILabel *fpsLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 60, 12)];
            [self addSubview:fpsLbl];
            _fpsLbl = fpsLbl;
            _fpsLbl.font = [UIFont systemFontOfSize:12];
            _fpsLbl.textColor = [UIColor redColor];
            _fpsLbl.textAlignment = NSTextAlignmentCenter;
            _fpsLbl.center = CGPointMake(self.bounds.size.width/2, fpsLbl.center.y);
            
            CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
            [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            _displayLink = displayLink;
            
        } else {
            
            [_displayLink invalidate];
            [_fpsLbl removeFromSuperview];
            
        }
    }
}

- (void)tick:(CADisplayLink *)displayLink{
    if (_lastTimestamp == 0.0){
        _lastTimestamp = displayLink.timestamp;
        return;
    }
    _framesPerSecond++;
    double interval = displayLink.timestamp - _lastTimestamp;
    if (interval >= 1.0){
        
        _fpsLbl.text = [NSString stringWithFormat:@"fps:%d", _framesPerSecond];
        _lastTimestamp = displayLink.timestamp;
        _framesPerSecond = 0;
    }
    
}

- (void)onTap:(UITapGestureRecognizer *)sender{
    if ([sender locationOfTouch:0 inView:self].x > (self.bounds.size.width-50)){ //Tap at right
        
        _vcHierarchyLbl.hidden = !_vcHierarchyLbl.hidden;
        if (!_vcHierarchyLbl){
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 320, 100)];
            lbl.numberOfLines = 0;
            lbl.font = [UIFont systemFontOfSize:14];
            lbl.opaque = YES;
            lbl.backgroundColor = [UIColor whiteColor];
            lbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
            lbl.layer.borderWidth = 1.0;
            lbl.alpha = 0.9;
            [self addSubview:lbl];
            _vcHierarchyLbl = lbl;
        }
        [self printVCHierarchy];
        
    } else if ([sender locationOfTouch:0 inView:self].x < 50){ //Tap at left
        
        _enableViewTracker = !_enableViewTracker;
        _viewTracker.hidden = !_enableViewTracker;
        _viewHierarchyLbl.hidden = YES;
    }
}

- (void)onPan:(UIGestureRecognizer *)g{
    CGPoint pos = [g locationInView:self];
    if (_enableViewTracker){
        _viewTracker.center = pos;
    }
    if (g.state == UIGestureRecognizerStateEnded){
        
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        UIView *outView = nil;
//        NSMutableArray *hierarchy = [NSMutableArray new];
//        [self hitTest:pos inView:window outView:&outView hierarchy:hierarchy];
//        NSLog(@"%@", hierarchy);
        outView = [window hitTest:pos withEvent:nil];
        NSArray *hierarchy = [self recursiveViewsOf:outView atHitPoint:pos];
        if (!_viewHierarchyLbl){
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 320, 100)];
            lbl.numberOfLines = 0;
            lbl.font = [UIFont systemFontOfSize:14];
            lbl.opaque = YES;
            lbl.backgroundColor = [UIColor whiteColor];
            lbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
            lbl.layer.borderWidth = 1.0;
            lbl.alpha = 0.9;
            [self addSubview:lbl];
            _viewHierarchyLbl = lbl;
        }

        _viewHierarchyLbl.text = hierarchy.description;
        [_viewHierarchyLbl sizeToFit];
        _viewHierarchyLbl.hidden = NO;
        [self bringSubviewToFront:_viewHierarchyLbl];
        CGRect frame = _viewHierarchyLbl.frame;
        frame.size.width = self.bounds.size.width;
        _viewHierarchyLbl.frame = frame;
        
        if (_hideBlock){
            dispatch_block_cancel(_hideBlock);
            _hideBlock = nil;
        }
        _hideBlock = dispatch_block_create(0, ^{
            _viewHierarchyLbl.hidden = YES;
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), _hideBlock);
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
    } else if (_enableViewTracker && CGRectContainsPoint(_viewTracker.frame, point)){
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
    //_textLbl.text = text;
}

- (void)printVCHierarchy{
    NSMutableString *str = [NSMutableString new];
    NSMutableArray *vcs = [NSMutableArray new];
    UIViewController *cur = _currentVC;
    while (cur) {
        [vcs insertObject:[NSString stringWithFormat:@"%@", cur.class] atIndex:0];
        cur = cur.parentViewController;
    }
    char buff[64];
    bzero(buff, sizeof(buff));
    int i = 0;
    for (NSString *vc in vcs){
        memset(buff, ' ', i);
        [str appendFormat:@" %s|%@\n", buff, vc];
        i += 4;
    }
    _vcHierarchyLbl.text = str;
    [_vcHierarchyLbl sizeToFit];
    CGRect frame = _vcHierarchyLbl.frame;
    frame.size.width = self.bounds.size.width;
    _vcHierarchyLbl.frame = frame;
}

/**
 Get the fastest child and hierarchy tapped
 
 @param pt A point tap at the view
 @param parent Parent view to test
 @param outView The fastest child tapped
 @param hierarchy View hierarchy tapped
 */
- (void)hitTest:(CGPoint)pt inView:(UIView *)parent outView:(UIView **)outView hierarchy:(NSMutableArray<NSString *> *)hierarchy{
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    char buff[512]; //max levels=128
    bzero(buff, sizeof(buff));
    
    for (UIView *v in parent.subviews){
        CGRect rect = [window convertRect:v.frame fromView:parent];
        if (v.hidden == NO && CGRectContainsPoint(rect, pt)){
            if (![NSStringFromClass(v.class) hasPrefix:@"_"]){  //private class
                
                *outView = v;
                int level = 0;
                UIView *tmp = v.superview;
                while (tmp != window) {
                    tmp = tmp.superview;
                    ++level;
                }
                tmp = nil;
                memset(buff, ' ', level*4);
                
                NSString *prefix = [NSString stringWithFormat:@"|%s%@", buff, (strlen(buff) == 0 ? @"" : @"|")];
                if ([v.nextResponder isKindOfClass:[UIViewController class]]){
                    [hierarchy addObject:[NSString stringWithFormat:@"%@%@", prefix, _simpleViewTrackerInfo ? v.nextResponder.class : v.nextResponder]];
                }
                [hierarchy addObject:[NSString stringWithFormat:@"%@%@", prefix, _simpleViewTrackerInfo ? v.class : v.description]];
                [self hitTest:pt inView:v outView:outView hierarchy:hierarchy];
            }
        }
    }
}


/**
 Recursive finding its superviews

 @param view View to recursive
 @param pt Hit point
 @return hierarchy array
 */
- (NSArray<NSString *> *)recursiveViewsOf:(UIView *)view atHitPoint:(CGPoint)pt{
    NSMutableArray *hierarchy = [NSMutableArray new];
    [hierarchy addObject:[NSString stringWithFormat:@"%@", _simpleViewTrackerInfo ? view.class : view.description]];
    UIView *v = view.superview;
    while (v) {
        if ([v.nextResponder isKindOfClass:[UIViewController class]]){
            [hierarchy addObject:[NSString stringWithFormat:@"%@", _simpleViewTrackerInfo ? v.nextResponder.class : v.nextResponder.description]];
        } else {
            [hierarchy addObject:[NSString stringWithFormat:@"%@", _simpleViewTrackerInfo ? v.class : v.description]];
        }
        v = v.superview;
    }
    
    //print
    char buff[512];
    bzero(buff, sizeof(buff));
    int level = 0;
    NSMutableString *str = [NSMutableString new];
    for (NSInteger i = hierarchy.count-1; i >= 0; --i){
        memset(buff, ' ', level*4);
        NSString *prefix = [NSString stringWithFormat:@"|%s%@", buff, (strlen(buff) == 0 ? @"" : @"|")];
        [str appendFormat:@"%@%@\n", prefix, hierarchy[i]];
        ++level;
    }
    NSLog(@"\n%@", str);
    return [[hierarchy reverseObjectEnumerator] allObjects];
    
}

@end
