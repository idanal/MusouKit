//
//  MSSegmentBar.m
//  
//
//  Created by danal-rich on 7/29/14.
//  Copyright (c) 2014 yz. All rights reserved.
//

#import "MSSegmentBar.h"

@implementation MSSegmentBar

- (id)initWithFrame:(CGRect)frame buttons:(NSArray *)buttons
{
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
            v.userInteractionEnabled = NO;
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
    CGFloat indicatorH = _indicatorHeight;
    CGFloat w = self.bounds.size.width/_buttons.count, h = self.bounds.size.height - indicatorH;
    for (NSInteger i = 0; i < _buttons.count; i++) {
        MSSegmentButton *butt = _buttons[i];
        butt.frame = CGRectMake(i*w, 0, w, h);
    }
    if (!_indicator){
        _indicator = [[MSSegmentIndicator alloc] initWithFrame:CGRectZero];
        _indicator.clipsToBounds = YES;
        [self addSubview:_indicator];
    }
    _indicator.backgroundColor = [UIColor redColor];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_hasSetup){
        _hasSetup = YES;
        [self moveIndicatorTo:_selectedIndex animated:NO];
    }
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
    
        CGFloat sw = self.bounds.size.width/_buttons.count;
        _indicatorWidth = 50;
        if (_indicatorWidth == 0) _indicatorWidth = sw;
        if (_indicatorHeight == 0) _indicatorHeight = 2.f;
        
        CGFloat x = idx*sw + (sw-_indicatorWidth)/2;
        _indicator.frame = CGRectMake(x,
                                      self.bounds.size.height - _indicatorHeight,
                                      _indicatorWidth,
                                      _indicatorHeight
                                      );
        _indicator.hidden = _indicatorHidden;
    }];

}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if (_selectedIndex != selectedIndex){
        _selectedIndex = selectedIndex;
        
        [self moveIndicatorTo:selectedIndex animated:YES];
        
        for (NSInteger i = 0; i < _buttons.count; i++){
            MSSegmentButton *butt = _buttons[i];
            butt.selected = i == _selectedIndex;
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

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scroll.pagingEnabled = YES;
    _scroll.delegate = self;
    _scroll.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scroll];
}

- (void)layoutSubviews{
    if (_delegate){
        _pageNum = [_delegate segmentViewNumberOfPages];
        _scroll.contentSize = CGSizeMake(self.bounds.size.width*_pageNum, self.bounds.size.height);
        for (NSInteger i = 0; i < _pageNum; i++) {
            UIView *view = [_delegate segmentView:self contentViewAtPage:i];
            view.tag = 100+i;
            view.frame = CGRectMake(_scroll.bounds.size.width*i, 0, _scroll.bounds.size.width, _scroll.bounds.size.height);
            [_scroll addSubview:view];
        }
    }
    if (_segmentBar){
        [_segmentBar addTarget:self action:@selector(onSegmentBarClick:) forControlEvents:UIControlEventValueChanged];
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
