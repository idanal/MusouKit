//
//  RangeSlider.m
//  GoJobNow
//
//  Created by danal on 6/1/16.
//  Copyright © 2016 Sean. All rights reserved.
//

#import "DLRangeSlider.h"

@interface DLRangeSlider (){
    
    UIView *_bar1;
    UIView *_bar2;
    UIView *_ballLeft;
    UIView *_ballRight;
    
    CGPoint _prevPos;
    UIView *_movingBall;
    
    CGFloat _ballWidth;
}

@end

@implementation DLRangeSlider

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initialize];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self initialize];
    }
    return self;
}

//Create subviews
- (void)initialize{
    
    _startValue = 0.0;
    _endValue = 1.0;
    
    const CGFloat bh = 5.f;
    CGRect rect = CGRectMake(0, 0, bh, bh);
    _bar1 = [[UIView alloc] initWithFrame:rect];
    _bar1.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_bar1];
    _bar2 = [[UIView alloc] initWithFrame:rect];
    _bar2.backgroundColor = [UIColor colorWithRed:242.2f/255 green:109.f/255 blue:95.f/255 alpha:1.f];
    [self addSubview:_bar2];
    _bar1.clipsToBounds = _bar2.clipsToBounds = YES;
    _bar1.layer.cornerRadius = _bar2.layer.cornerRadius = bh/2;
    
    
    _ballWidth = 24.f;
    _ballLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _ballWidth, _ballWidth)];
    [self addSubview:_ballLeft];
    _ballRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _ballWidth, _ballWidth)];
    [self addSubview:_ballRight];
    
    _ballLeft.clipsToBounds = _ballRight.clipsToBounds = YES;
    _ballLeft.layer.cornerRadius = _ballRight.layer.cornerRadius = _ballWidth/2;
    _ballLeft.layer.borderColor = _ballRight.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _ballLeft.layer.borderWidth = _ballRight.layer.borderWidth = 1.f;
    _ballLeft.backgroundColor = _ballRight.backgroundColor = [UIColor whiteColor];

    UIPanGestureRecognizer *g = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onPan:)];
    [self addGestureRecognizer:g];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat bh = _bar1.bounds.size.height;

    CGRect rect = CGRectMake(bh, self.bounds.size.height/2-bh/2, self.bounds.size.width-2*bh, bh);
    _bar1.frame = rect;
    
    CGPoint center = CGPointMake(0, self.bounds.size.height/2);
    center.x = _bar1.frame.origin.x + _startValue*_bar1.frame.size.width;
    _ballLeft.center = center;
    center.x = _bar1.frame.origin.x + _endValue*_bar1.frame.size.width;
    _ballRight.center = center;
    
    _bar2.frame = CGRectMake(_ballLeft.center.x, _bar1.frame.origin.y,
                             _ballRight.center.x-_ballLeft.center.x, _bar2.frame.size.height);
    
}

- (void)_onPan:(UIGestureRecognizer *)g{
    CGPoint pos = [g locationInView:self];
    switch (g.state) {
        case UIGestureRecognizerStateBegan:{
            CGRect fingerRect = CGRectMake(pos.x-_ballWidth/2, pos.y-_ballWidth/2,
                                           _ballWidth, _ballWidth);
            if (CGRectIntersectsRect(_ballLeft.frame, fingerRect)){
                _movingBall = _ballLeft;
            } else if (CGRectIntersectsRect(_ballRight.frame, fingerRect)){
                _movingBall = _ballRight;
            }
            _prevPos = pos;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (_movingBall){
                CGFloat x = _movingBall.center.x+(pos.x-_prevPos.x);
                if (_movingBall == _ballLeft){
                    x = MAX(x, _bar1.frame.origin.x);
                    x = MIN(x, _ballRight.center.x);
                    _startValue = (x-_bar1.frame.origin.x)/_bar1.frame.size.width;
                } else {
                    x = MAX(x, _ballLeft.center.x);
                    x = MIN(x, _bar1.frame.origin.x+_bar1.frame.size.width);
                    _endValue = (x-_bar1.frame.origin.x)/_bar1.frame.size.width;
                }
                //_movingBall.center = CGPointMake(x, _movingBall.center.y);
                [self setNeedsLayout];
                if (_onValueChanged) _onValueChanged(self);
                else [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            _prevPos = pos;
        }
            break;
        default:
            _movingBall = nil;
            break;
    }
}

@end
