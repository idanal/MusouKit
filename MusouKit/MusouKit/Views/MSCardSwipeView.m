//
//  CardSwipeView.m
//
//
//  Created by DANAL LUO on 2017/5/11.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSCardSwipeView.h"

@interface MSCardSwipeView ()
@property (nonatomic, assign) CGPoint centerDiff;
//Latest view index on screen
@property (nonatomic, assign) NSInteger index;
//Current displaying view index
@property (nonatomic, assign) NSInteger displayingIndex;
//Visibile count of view. default 3
@property (nonatomic, assign) NSInteger visibleNumber;
//Views on screen
@property (nonatomic, strong) NSMutableArray *visibleViews;
//All views added to the container
@property (nonatomic, weak) UIView *containerView;
@end

@implementation MSCardSwipeView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setup];
    }
    return self;
}

- (void)setup{
    self.clipsToBounds = NO;
    _visibleNumber = 3;
    _visibleViews = [NSMutableArray new];
    
    UIView *container = [[UIView alloc] initWithFrame:self.bounds];
    container.backgroundColor = [UIColor clearColor];
    [self addSubview:container];
    _containerView = container;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tap];
}

- (void)setDelegate:(id<MSCardSwipeViewDelegate>)delegate{
    _delegate = delegate;
    [self setNeedsLayout];
}

- (void)onPan:(UIPanGestureRecognizer *)g{
    UIView *v = _visibleViews.firstObject;
    if (!v){
        return;
    }
    
    CGPoint pos = [g locationInView:self];
    switch (g.state) {
        case UIGestureRecognizerStateBegan:
            _centerDiff = CGPointMake(v.center.x - pos.x, v.center.y - pos.y);
            break;
        case UIGestureRecognizerStateChanged:
            v.center = CGPointMake(pos.x + _centerDiff.x, pos.y + _centerDiff.y);
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            
            CGRect rect = CGRectIntersection(self.bounds, v.frame);
            if (fabs(rect.size.width)/self.bounds.size.width < 0.7
                || fabs(rect.size.height)/self.bounds.size.height < 0.7){
                [self removeMovingView];
            } else {
                [self putbackMovingView];
            }
        }
            break;
        default:
            break;
    }
}

- (void)onTap:(UIGestureRecognizer *)g{
    if (self.displayingIndex < [_delegate cardSwipeViewTotalNumber]){
        [_delegate cardSwipeView:self didClickAtIndex:self.displayingIndex];
    }
}

- (void)reloadData:(BOOL)animated{
    self.index = 0;
    self.displayingIndex = 0;
    [self fillViews:animated];
}

- (void)removeMovingView{
    UIView *v = _visibleViews.firstObject;
    v.layer.anchorPoint = CGPointMake(0.5, 0.5);
    v.center = CGPointMake(v.center.x, v.center.y+v.bounds.size.height/2);
    
    self.userInteractionEnabled = NO;
    self.displayingIndex++;
    [self.visibleViews removeObject:v];
    
    [UIView animateWithDuration:.25 animations:^{
        
        v.alpha = 0;
        CGAffineTransform t = CGAffineTransformMakeRotation(M_PI);
        t = CGAffineTransformScale(t, 0.1, 0.1);
        v.transform = t;
        
    } completion:^(BOOL finished) {
        
        self.userInteractionEnabled = YES;
        [v removeFromSuperview];
        
        //To the end
        if (self.displayingIndex == [_delegate cardSwipeViewTotalNumber]){
            if ([_delegate respondsToSelector:@selector(cardSwipeViewDidSwipeToEnd:)]){
                [_delegate cardSwipeViewDidSwipeToEnd:self];
            }
        }
    }];
    
    [self fillViews:YES];
}

- (void)putbackMovingView{
    UIView *v = _visibleViews.firstObject;
    
    [UIView animateWithDuration:.25 animations:^{
        v.center = CGPointMake(self.bounds.size.width/2, 0);
    }];
}

- (void)fillViews:(BOOL)animated{
    while (_visibleViews.count < _visibleNumber){
        if (self.index < [self.delegate cardSwipeViewTotalNumber]){

            UIView *last = _visibleViews.lastObject;
            
            UIView *v = [self.delegate cardSwipeView:self viewAtIndex:self.index];
            v.frame = self.bounds;
            v.layer.anchorPoint = CGPointMake(0.5, 0);
            v.center = CGPointMake(self.bounds.size.width/2, 0);
            v.transform = CGAffineTransformMakeScale(0.8, 0.8);
            
            if (last){
                [_containerView insertSubview:v belowSubview:last];
            } else {
                [_containerView addSubview:v];
            }
            [self.visibleViews addObject:v];
            self.index++;
            
        } else {
            break;
        }
    }
    
    //Adjust layout
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        
        if (_visibleViews.count > 0){
            CGFloat scale = 1.;
            CGFloat y = 0;
            for (NSInteger i = 0; i < _visibleViews.count; i++){
                UIView *v = _visibleViews[i];
                CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);
                t = CGAffineTransformTranslate(t, 0, -y);
                v.transform = t;
                y += 6;
                scale -= 0.1;
                
            }
        }
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _containerView.frame = self.bounds;
    if (_delegate && self.visibleViews.count == 0){
        [self reloadData:NO];
    }
}

@end
