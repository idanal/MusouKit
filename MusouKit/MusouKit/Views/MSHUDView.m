//
//  HUDView.m
//  SideMenuController
//
//  Created by danal on 13-1-3.
//  Copyright (c) 2013年 yz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MSHUDView.h"
#import "MSAdditions.h"

#define kHUDViewMargin 20.f

@implementation MSHUDView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        
        //container
        CGFloat margin = kHUDViewMargin, w = 220.f, h = 60.f;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - w)/2, (frame.size.height - h)/2, w, h)];
        _imageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
        _imageView.layer.cornerRadius = 5.f;
        _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _imageView.layer.shadowOpacity = 0.6f;
        _imageView.layer.shadowRadius = 5.f;
        _imageView.layer.shadowOffset = CGSizeMake(2, 2);
        [self addSubview:_imageView];
        
        //icon
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _iconView.frame = CGRectMake(margin, (_imageView.bounds.size.height - _iconView.bounds.size.height)/2,
                                     _iconView.bounds.size.width, _iconView.bounds.size.height);
        _iconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_imageView addSubview:_iconView];
        
        //title
        CGFloat x = _iconView.frame.origin.x + _iconView.frame.size.width + 10.f, y = margin;
        w = _imageView.frame.size.width - x - _iconView.frame.origin.x, h = 20.f;
        _textLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _textLbl.backgroundColor = [UIColor clearColor];
        _textLbl.textColor = [UIColor whiteColor];
        _textLbl.font = [UIFont systemFontOfSize:14.f];
        _textLbl.numberOfLines = 0;
        [_imageView addSubview:_textLbl];
        
        //subtitle
        y += h ;
        _subTextLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _subTextLbl.backgroundColor = [UIColor clearColor];
        _subTextLbl.textColor = [UIColor rgb:@"#cccccc"];
        _subTextLbl.font = [UIFont systemFontOfSize:13.f];
        _subTextLbl.numberOfLines = 0;
        _subTextLbl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_imageView addSubview:_subTextLbl];
        
        _touchToHide = YES;
    }
    return self;
}

- (void)showMessage:(NSString *)msg subtitle:(NSString *)subtitle loading:(BOOL)loading{
    
    _textLbl.text = msg;
    _subTextLbl.text = subtitle;
    _subTextLbl.hidden = subtitle == nil;
    
    //Resize
    CGFloat minWidth = 200.f;
    CGFloat maxWidth = self.bounds.size.width - 60.f;
    CGFloat lblMaxWidth = maxWidth - _textLbl.frame.origin.x - kHUDViewMargin*1.5f;
    CGRect rect = _textLbl.frame;
    CGSize size = CGSizeMake(lblMaxWidth, 10e3);
    size = [msg limitToSize:size font:_textLbl.font];
    rect.size.height = size.height;
    rect.size.width = size.width;
    _textLbl.frame = rect;
    
    rect = _subTextLbl.frame;
    size = CGSizeMake(lblMaxWidth, 10e3);
    size = [subtitle limitToSize:size font:_subTextLbl.font];
    rect.size.height = size.height;
    rect.size.width = size.width;
    _subTextLbl.frame = rect;
    
    CGFloat minHeight = 3.f*_iconView.bounds.size.height;
    rect = _imageView.bounds;
    rect.size.height = MAX(minHeight,
                           _textLbl.frame.origin.y*2 +  _textLbl.frame.size.height + _subTextLbl.frame.size.height
                           );
    _imageView.bounds = rect;
    
    //Re-layout
    if (subtitle){
        CGRect frame = _subTextLbl.frame;
        frame.origin.y = _imageView.bounds.size.height - _textLbl.frame.origin.y - frame.size.height;
        _subTextLbl.frame = frame;
    } else {
        CGRect frame = _textLbl.frame;
        frame.origin.y = (_imageView.bounds.size.height - frame.size.height)/2;
        _textLbl.frame = frame;
    }
    rect = _imageView.frame;
    rect.size.width = _textLbl.frame.origin.x + _textLbl.frame.size.width + kHUDViewMargin;
    rect.size.width = MAX(rect.size.width, minWidth);
    rect.origin.x = (self.bounds.size.width - rect.size.width)/2;
    _imageView.frame = rect;
    
    //Add shadow
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, _imageView.bounds);
    _imageView.layer.shadowPath = path;
    CGPathRelease(path);
    
    if (loading){
        /*
        _iconView.image = [UIImage imageNamed:@"ico-loading.png"];
        CAKeyframeAnimation *kfa = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        kfa.duration = 1.f;
        kfa.values = [NSArray arrayWithObjects:
                      [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 1.f)],
                      [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1.f)],
                      [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI*2, 0, 0, 1.f)]
                      , nil];
        kfa.repeatCount = 10e6;
        [_iconView.layer addAnimation:kfa forKey:@"Rotation"];
         */
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.center = _iconView.center;
        [indicator startAnimating];
        [_imageView addSubview:indicator];
        
    } else {
//        _iconView.image = [UIImage imageNamed:@"ico-tips.png"];
//        _iconView.contentMode = UIViewContentModeCenter;
        UILabel *tip = [[UILabel alloc] initWithFrame:_iconView.bounds];
        [_iconView addSubview:tip];
        tip.clipsToBounds = YES;
        tip.layer.cornerRadius = tip.bounds.size.width/2.0;
        tip.layer.borderColor = [UIColor whiteColor].CGColor;
        tip.layer.borderWidth = 1.0;
        tip.font = [UIFont boldSystemFontOfSize:14.0];
        tip.textAlignment = NSTextAlignmentCenter;
        tip.textColor = [UIColor whiteColor];
        tip.text = @"!";
    }
    
    //Animated show
    CAKeyframeAnimation *kfa = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    kfa.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.f)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.f, 1.f, 1.f)],
                  nil];
    kfa.duration = .2f;
    kfa.fillMode = kCAFillModeBackwards;
    kfa.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_imageView.layer addAnimation:kfa forKey:nil];
    
    [self delayHides:2.f];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag){
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1f];
    }
}

- (void)delayHides:(NSInteger)delay{
    if (_timer){
        [_timer invalidate];
        _timer = NULL;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void)hide{
    if (_timer)
        [_timer invalidate];
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_touchToHide) {
        [self hide];
    }
}

+ (MSHUDView *)showMessageToView:(UIView *)superview msg:(NSString *)msg subtitle:(NSString *)subtitle{
    MSHUDView *hud = [[MSHUDView alloc] initWithFrame:superview.bounds];
    [superview addSubview:hud];
    [hud showMessage:msg subtitle:subtitle loading:NO];
    return hud;
}

+ (MSHUDView *)showLoadingToView:(UIView *)superview msg:(NSString *)msg subtitle:(NSString *)subtitle{
    MSHUDView *hud = [[MSHUDView alloc] initWithFrame:superview.bounds];
    [superview addSubview:hud];
    [hud showMessage:msg subtitle:subtitle loading:YES];
    return hud;
}

+ (MSHUDView *)showLoadingToView:(UIView *)superview msg:(NSString *)msg subtitle:(NSString *)subtitle touchToHide:(BOOL)touchToHide
{
    MSHUDView *hud = [[MSHUDView alloc] initWithFrame:superview.bounds];
    hud.touchToHide = touchToHide;
    [superview addSubview:hud];
    [hud showMessage:msg subtitle:subtitle loading:YES];
    
    return hud;
}

+ (MSHUDView *)showLoading:(UIView *)superview{
    return [self showLoadingToView:superview msg:NSLocalizedString(@"Loading...", nil) subtitle:nil];
}

+ (void)hideHUD:(UIView *)superview{
    for (UIView *v in superview.subviews){
        if ([v isKindOfClass:[MSHUDView class]]){
            [(MSHUDView *)v hide];
            break;
        }
    }
}

@end


@implementation UIView (HUD)

- (void)showToast:(NSString *)msg{
    [MSHUDView showMessageToView:self msg:msg subtitle:nil];
}

- (void)showLoading:(NSString *)msg{
    [MSHUDView showLoadingToView:self msg:msg ? msg : @"加载中，请稍候..." subtitle:nil];
}

- (void)hideHUD{
    [MSHUDView hideHUD:self];
}

@end
