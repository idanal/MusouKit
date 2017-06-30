//
//  MSAlertView.m
//  MusouSample
//
//  Created by DANAL LUO on 30/06/2017.
//  Copyright © 2017 danal. All rights reserved.
//

#import "MSAlertView.h"
#import "Masonry.h"


@interface MSAlertView (){
    UIWindow *_win;
}
@end

@implementation MSAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSArray *)otherTitles{
    
    self = [super init];
    if (self){
        
        self.backgroundColor = [UIColor whiteColor];
        
        //Title
        if (title){
            UILabel *titleLbl = [UILabel new];
            titleLbl.numberOfLines = 0;
            titleLbl.font = [UIFont boldSystemFontOfSize:16];
            [self addSubview:titleLbl];
            titleLbl.text = title;
            [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@15);
                make.centerX.equalTo(@0);
            }];
            _titleLabel = titleLbl;
        }
        
        //Message
        UILabel *msgLbl = [UILabel new];
        [self addSubview:msgLbl];
        msgLbl.numberOfLines = 0;
        msgLbl.font = [UIFont systemFontOfSize:14];
        msgLbl.textColor = [UIColor darkGrayColor];
        msgLbl.text = message;
        [msgLbl mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerX.equalTo(@0);
            if (_titleLabel){
                make.top.equalTo(_titleLabel.mas_bottom).offset(8);
            } else {
                make.top.equalTo(@15);
            }
        }];
        _messageLabel = msgLbl;
        
        //Buttons
        NSMutableArray *titles = [NSMutableArray new];
        if (otherTitles.count > 1){
            [titles addObjectsFromArray:otherTitles];
            if (cancelTitle) [titles addObject:cancelTitle];
        } else {
            if (cancelTitle) [titles addObject:cancelTitle];
            [titles addObjectsFromArray:otherTitles];
        }
        
        const CGFloat btnh = 44.0;
        if (titles.count == 0){     //no buttons
            
            [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@(-15));
            }];
            
        }
        else if (titles.count <= 2){    //horizontal layout
            
            UIView *line = [self makeLineView];
            [self addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_messageLabel.mas_bottom).offset(15);
                make.leading.trailing.equalTo(@0);
                make.height.equalTo(@0.5);
            }];
            
            UIView *prev = nil;
            for (NSInteger i = 0; i < titles.count; i++){
                
                if (i > 0){
                    UIView *vline = [self makeLineView];
                    [self addSubview:vline];
                    [vline mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(line.mas_bottom);
                        make.height.equalTo(@(btnh));
                        make.width.equalTo(@0.5);
                        make.leading.equalTo(prev.mas_trailing).offset(0);
                    }];
                    prev = vline;
                }
                
                UIButton *btn = [self makeButton];
                btn.tag = i;
                [self addSubview:btn];
                [btn setTitle:titles[i] forState:UIControlStateNormal];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                   
                        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.top.equalTo(line.mas_bottom);
                            make.height.equalTo(@(btnh));
                            make.width.equalTo(self.mas_width).multipliedBy(1.0/titles.count);
                            if (i == 0){
                                make.leading.equalTo(@0);
                                make.bottom.equalTo(@0);
                            } else {
                                make.leading.equalTo(prev.mas_trailing).offset(0);
                            }
                        }];
                }];
                
                prev = btn;
            }
            
        } else if (titles.count > 2) {  //vertical layout
            
            UIView *prev = nil;
            for (NSInteger i = 0; i < titles.count; i++){
                
                UIView *line = [self makeLineView];
                [self addSubview:line];
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (i == 0){
                        make.top.equalTo(_messageLabel.mas_bottom).offset(15);
                    } else {
                        make.top.equalTo(prev.mas_bottom);
                    }
                    make.leading.trailing.equalTo(@0);
                    make.height.equalTo(@0.5);
                }];
                
                UIButton *btn = [self makeButton];
                btn.tag = i == titles.count-1 ? 0 : i+1;
                [self addSubview:btn];
                [btn setTitle:titles[i] forState:UIControlStateNormal];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(line.mas_bottom);
                        make.height.equalTo(@(btnh));
                        make.width.equalTo(self.mas_width);
                        make.centerX.equalTo(@0);
                        if (i == titles.count-1){
                            make.bottom.equalTo(@0);
                        }
                    }];
                }];
                
                prev = btn;
            }

        }
        
    }
    return self;
}

- (void)show{
    
    _win = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _win.windowLevel = UIWindowLevelAlert;
    _win.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3];
    [_win addSubview:self];
    _win.hidden = NO;
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leadingMargin.equalTo(@50);
        make.centerX.centerY.equalTo(@0);
    }];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 3);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    scale.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    scale.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = @0.0;
    opacity.toValue = @1.0;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.25;
    group.animations = @[scale, opacity];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.layer addAnimation:group forKey:nil];
    
}

- (void)dismiss{
    [self removeFromSuperview];
}

#pragma mark - Privates
- (UIView *)makeLineView{
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:225/255.0 alpha:1.0];
    return line;
}

- (UIButton *)makeButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(onButtonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [btn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)onButtonTouchDown:(UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:0xf1/255.0 green:0xf1/255.0 blue:0xf1/255.0 alpha:1.0];
}

- (void)onButtonTouchUp:(UIButton *)sender{
    sender.backgroundColor = [UIColor whiteColor];
}

- (void)onButtonClick:(UIButton *)sender{
    sender.backgroundColor = [UIColor whiteColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self dismiss];
        if (_clickBlock){
            _clickBlock(self, sender.tag);
        }
    });
    
}

@end
