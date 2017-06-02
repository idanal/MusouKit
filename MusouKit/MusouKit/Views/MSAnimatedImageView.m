//
//  AnimatedImageView.m
//  
//
//  Created by DANAL LUO on 2017/6/1.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSAnimatedImageView.h"
#import <objc/runtime.h>

@interface MSAnimatedImageView ()
@property (nonatomic, weak) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger frameIndex;
@end

@implementation MSAnimatedImageView

- (void)removeFromSuperview{
    [self.displayLink invalidate];
    [super removeFromSuperview];
}

- (void)startAnimating{
    [self setup];
    if (self.displayLink.paused){
        self.displayLink.paused = NO;
    }
}

- (void)stopAnimating{
    self.displayLink.paused = YES;
    if (self.animationImages){
        self.image = self.animationImages[self.frameIndex];
    }
}

- (void)setAnimationImages:(NSArray<UIImage *> *)animationImages{
    [super setAnimationImages:animationImages];
    self.frameIndex = 0;
}

- (void)setup{
    if (!_displayLink){
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_tick:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = displayLink;
    }
    
    if (self.animationDuration > 0.0){
        CGFloat fps = self.animationDuration/self.animationImages.count;
        self.displayLink.preferredFramesPerSecond = MIN(1.0/fps, 60);
    }
}

- (void)_tick:(CADisplayLink *)l{
    self.image = self.animationImages[self.frameIndex];
    ++self.frameIndex;
    if (self.frameIndex == self.animationImages.count){
        self.frameIndex = 0;
    }
}

@end
