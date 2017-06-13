//
//  MSSegmentBar.m
//  
//
//  Created by danal-rich on 7/29/14.
//  Copyright (c) 2014 yz. All rights reserved.
//

#import "MSSegmentBar.h"

@implementation MSSegmentBar

- (id)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles{
    self = [super initWithFrame:frame];
    if (self){
        NSMutableArray *buttons = [NSMutableArray new];
        for (NSString *t in titles){
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
            [butt setTitle:t forState:UIControlStateNormal];
            [butt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [butt setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [buttons addObject:butt];
            [self addSubview:butt];
        }
        _buttons = buttons;
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame buttons:(NSArray<UIButton *> *)buttons{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _buttons = [[NSArray alloc] initWithArray:buttons];
        [self setup];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    for (UIView *v in self.subviews){
        if ([v isKindOfClass:[MSSegmentButton class]]){
            v.backgroundColor = [UIColor clearColor];
            [buttons addObject:v];
        } else if ([v isKindOfClass:[MSSegmentIndicator class]]){
            _indicator = v;
        }
    }
    [buttons sortUsingComparator:^NSComparisonResult(UIButton * _Nonnull obj1, UIButton *  _Nonnull obj2) {
        return obj1.frame.origin.x < obj2.frame.origin.x ? NSOrderedAscending : NSOrderedDescending;
    }];
    _buttons = buttons;
    [self setup];
}

- (void)setup{
    _indicatorWidth = 0.0;
    _indicatorHeight = 2.0;
    
    UIButton *previous = nil;
    for (NSInteger i = 0; i < _buttons.count; ++i){
        UIButton *view = _buttons[i];
        view.userInteractionEnabled = NO;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        if (previous == nil){
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(self, view)]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(self, view)]];
        } else {
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view(==previous)]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(previous, view)]];
            if (i == _buttons.count-1){
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previous][view(==previous)]-0-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(previous, view)]];
            } else {
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previous][view(==previous)]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(previous, view)]];
            }
        }
        previous = view;

    }
    
    if (!_line){
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRed:0xd1/255.0 green:0xd1/255.0 blue:0xd1/255.0 alpha:1.0];
        [self addSubview:_line];
        _line.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_line]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_line)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_line(0.5)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_line)]];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_indicator){
        _indicator = [[MSSegmentIndicator alloc] initWithFrame:CGRectZero];
        _indicator.clipsToBounds = YES;
        [self addSubview:_indicator];
        _indicator.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *view = _indicator;
        UIView *current = _buttons[_selectedIndex];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==h)]-0-|"
                                                                     options:0
                                                                     metrics:@{@"h":@(_indicatorHeight)}
                                                                       views:NSDictionaryOfVariableBindings(view)]];
        if (_indicatorWidth > 0){
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_indicatorWidth]];
        } else {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:current attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        }
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:current attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0];
        [self addConstraint:centerX];
        _indicatorCenterX = centerX;
        
    }
    _indicator.backgroundColor = [UIColor redColor];
}

- (void)clearSelected{
    _selectedIndex = -1;
    for (NSInteger i = 0; i < _buttons.count; i++) {
        MSSegmentButton *butt = _buttons[i];
        butt.selected = NO;
    }
}

- (void)moveIndicatorTo:(NSInteger)idx animated:(BOOL)animated{
    [UIView animateWithDuration:animated ? .2f : 0.f animations:^{
        
        _indicator.hidden = _indicatorHidden;
        
        UIView *view = _indicator;
        [self removeConstraint:_indicatorCenterX];
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_buttons[idx] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0];
        [self addConstraint:centerX];
        _indicatorCenterX = centerX;
        
        [self layoutIfNeeded];
        
    }];

}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if (_selectedIndex != selectedIndex){
        _selectedIndex = selectedIndex;
        
        [self moveIndicatorTo:selectedIndex animated:YES];
        
        for (NSInteger i = 0; i < _buttons.count; i++){
            MSSegmentButton *butt = _buttons[i];
            butt.selected = i == _selectedIndex;
            if (_onButtonConfig){
                _onButtonConfig(butt, butt.selected);
            }
        }
        [self _buttonClick:selectedIndex];
    } else {
        [self _buttonClickAgain:selectedIndex];
    }
}

- (void)_buttonClick:(NSInteger)atIdx{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_buttonClickAgain:(NSInteger)atIdx{
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches anyObject];
    CGPoint pos = [t locationInView:self];
    for (NSInteger i = 0; i < _buttons.count; i++){
        MSSegmentButton *butt = _buttons[i];
        if (CGRectContainsPoint(butt.frame, pos)){
            self.selectedIndex = i;
            break;
        }
    }
}

@end


@implementation MSSegmentView

- (void)reloadWithParentController:(UIViewController *)parentController titles:(NSArray<NSString *> *)titles controllers:(NSArray<UIViewController *> *)controllers{
    
    if (!_segmentBar){
        MSSegmentBar *segmentBar = [[MSSegmentBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44) titles:titles];
        [self addSubview:segmentBar];
        _segmentBar = segmentBar;
        _segmentBar.translatesAutoresizingMaskIntoConstraints = NO;
        _segmentBar.backgroundColor = [UIColor whiteColor];
        [_segmentBar addTarget:self action:@selector(onSegmentBarClick:) forControlEvents:UIControlEventValueChanged];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_segmentBar]-0-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_segmentBar)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_segmentBar(44)]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_segmentBar)]];
    }
    
    if (!_scroll){
        UIScrollView *scroll = [[UIScrollView alloc] init];
        [self addSubview:scroll];
        _scroll = scroll;
        _scroll.pagingEnabled = YES;
        _scroll.delegate = self;
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_scroll]-0-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_scroll)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[_scroll]-0-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_scroll)]];
    }
    
    UIView *previous = nil;
    for (NSInteger i = 0; i < controllers.count; i++) {
        UIViewController *c = controllers[i];
        if (parentController){
            [parentController addChildViewController:c];
        }
        UIView *view = c.view;
        view.tag = 100+i;
        [view removeFromSuperview];
        [_scroll addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
  
        if (previous == nil){
     
            [_scroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view(==_scroll)]-0-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_scroll, view)]];
            [_scroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view(==_scroll)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_scroll, view)]];
        } else {
            
            [_scroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view(==previous)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(previous, view)]];
            if (i == controllers.count-1){
                [_scroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previous][view(==previous)]-0-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(previous, view)]];
            } else {
                [_scroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previous][view(==previous)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(previous, view)]];
            }
        }
        previous = view;
    }

}

- (void)onSegmentBarClick:(MSSegmentBar *)sender{
    self.currentPage = sender.selectedIndex;
}

- (void)setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
    [_scroll setContentOffset:CGPointMake(currentPage*_scroll.bounds.size.width, 0) animated:YES];
    if (_delegate){
        [_delegate segmentViewDidScrollToPage:self page:currentPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _currentPage = ceilf(scrollView.contentOffset.x/scrollView.bounds.size.width);
    if (_segmentBar){
        _segmentBar.selectedIndex = _currentPage;
    }
    if (_delegate){
        [_delegate segmentViewDidScrollToPage:self page:_currentPage];
    }
}

@end



@implementation MSFilterSegmentBar

- (void)_buttonClickAgain:(NSInteger)atIdx{
    if (_optionView){
        [_optionView dismiss];
        _optionView = nil;
    } else if (_onButtonClickAgain){
        _onButtonClickAgain(atIdx, self);
    }
}

- (void)_buttonClick:(NSInteger)atIdx{
    [super _buttonClick:atIdx];
    if (_optionView){
        [_optionView dismiss];
        _optionView = nil;
    }
    _onButtonClickAgain(atIdx, self);
}

- (MSFilterOptionView *)showOptionView:(NSArray<NSString *> *)items{
    if (_itemFilterSelectedRows == nil){
        _itemFilterSelectedRows = [NSMutableDictionary new];
    }
    NSNumber *idx = [_itemFilterSelectedRows objectForKey:@(self.selectedIndex)];
    MSFilterOptionView *ov = [[MSFilterOptionView alloc] initWithFrame:CGRectZero];
    ov.items = items;
    ov.selectedIndex = idx != nil ?  [idx integerValue] : -1;
    [ov showIn:self.superview bellow:self];
    self.optionView = ov;
//    [ov addObserver:self forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionNew context:nil];
    return ov;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    NSLog(@"%@", change);
//    if ([keyPath isEqualToString:@"selectedIndex"]){
//        _itemFilterSelectedRows[@(self.selectedIndex)] = [change objectForKey:keyPath];
//    }
}

@end



@implementation MSFilterSegmentButton

- (void)layoutSubviews{
    [super layoutSubviews];
    self.userInteractionEnabled = NO;

    if (self.imageView.image){
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGFloat w = self.titleLabel.bounds.size.width + 20.f;
        CGFloat x = (self.bounds.size.width - w)/2.f;
        self.titleLabel.frame = CGRectMake(x, 0, self.titleLabel.bounds.size.width, self.bounds.size.height);
        CGFloat imgw = MIN(16, self.imageView.bounds.size.width);
        self.imageView.frame = CGRectMake(x + self.titleLabel.bounds.size.width + 4, 0, imgw, self.bounds.size.height);
        
        self.imageView.transform = _descend ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
    }

}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
//    [self setNeedsLayout];
}

@end


@implementation MSFilterOptionView

- (void)dealloc{
    NSLog(@"MSFilterOptionView: %s",__func__);
}

- (void)setup{
    self.dataSource = self;
    self.delegate = self;
    self.tableFooterView = [UIView new];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setup];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    cell.textLabel.text = _items[indexPath.row];
    cell.accessoryType = _selectedIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //record the selected row
    if (_onSelect) _onSelect(indexPath.row);
    [self dismiss];
}

- (void)showIn:(UIView *)parent bellow:(UIView *)view{
    UIButton *mask = [UIButton buttonWithType:UIButtonTypeCustom];
    [mask addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    CGFloat y = view.bounds.size.height-view.frame.origin.y;
    CGRect frame = CGRectMake(0, y, parent.bounds.size.width, parent.bounds.size.height-y);
    mask.frame = frame;
    mask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [parent addSubview:mask];
    _maskView = mask;
    
    frame.size.height = 1.f;
    self.frame = frame;
    self.backgroundColor = [UIColor whiteColor];
    [parent addSubview:self];
    
    frame.size.height = MIN(320.f, self.contentSize.height);
    
    [UIView animateWithDuration:.1f animations:^{
        
        self.frame = frame;
        
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss{
    NSLog(@"%s", __func__);
    [_maskView removeFromSuperview];
    [self removeFromSuperview];
}

+ (instancetype)getInstance:(MSFilterSegmentBar *)bar{
    return bar.optionView;
}

@end
