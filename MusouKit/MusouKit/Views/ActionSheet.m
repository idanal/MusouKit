//
//  ActionSheet.m
//  UMatch
//
//  Created by danal.luo on 7/6/14.
//  Copyright (c) 2014 danal. All rights reserved.
//

#import "ActionSheet.h"
#import "MSAdditions.h"

static const CGFloat _kButtonSize = 52.f;

@interface ActionSheet ()
@property (strong, nonatomic) NSMutableArray *buttonList;
@end

@implementation ActionSheet

- (void)dealloc{
#if !__has_feature(objc_arc)
    self.buttonList = nil;
    self.clickBlock = nil;
    [super dealloc];
#endif
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0xf6/255.f green:0xf6/255.f blue:0xf6/255.f alpha:1.f];
        self.buttonList = [NSMutableArray array];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSString *)other, ...{
    NSMutableArray *others = [NSMutableArray array];
    NSString *buttTitle = other;
    va_list ap;
    va_start(ap, other);
    do {
        [others addObject:buttTitle];
    } while ((buttTitle = va_arg(ap, NSString *)));
    va_end(ap);
   
    return [self initWithTitle:title cancelTitle:cancelTitle otherTitleList:others];
}
//Way 1
- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitleList:(NSArray *)others{
    self = [self initWithFrame:CGRectMake(0, 0, 0, 0)];
    if (self){
        
        CGFloat mar = 5.f, x = 20.f, y = 10.f, h = 40.f, w = [UIScreen mainScreen].bounds.size.width-2*x;
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLbl.text = title;
        titleLbl.numberOfLines = 0;
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.font = [UIFont systemFontOfSize:14.f];
        titleLbl.textColor = [UIColor darkGrayColor];
        [self addSubview:titleLbl];
        CGSize size = [title limitToSize:CGSizeMake(w, w) font:titleLbl.font];
        titleLbl.frame = CGRectMake(x, y, w, size.height);
        _titleLabel = titleLbl;
        
        _scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 2*mar + _titleLabel.bounds.size.height, w, h)];
        [self addSubview:_scroll];
#if !__has_feature(objc_arc)
        [_scroll release];
#endif
        x = 20.f;
        //Buttons
        for (NSInteger tag = 0; tag < others.count; tag++){
            NSString *buttTitle = others[tag];

            UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
            butt.tag = tag;
            butt.frame = CGRectMake(x, y, w, h);
            butt.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [butt setTitle:buttTitle forState:UIControlStateNormal];
            [butt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [butt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [butt addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_scroll addSubview:butt];
            [_buttonList addObject:butt];
            butt.backgroundColor = [UIColor colorWithRed:100/255.f green:165/255.f blue:253/255.f alpha:1.f];
            butt.layer.cornerRadius = 3.f;
            y += h + mar;
        }
        y -= mar;
        _scroll.contentSize = CGSizeMake(_scroll.bounds.size.width, y);
        
        {   //Cancel button
            y += mar;
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
            butt.tag = -1;
            butt.frame = CGRectMake(x, self.bounds.size.height - h - 15.f, w, h);
            butt.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            butt.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [butt setTitle:cancelTitle forState:UIControlStateNormal];
            [butt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [butt addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:butt];
            butt.layer.cornerRadius = 3.f;
            _cancelButton = butt;
            
        }
    }
    return self;
}


- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle buttonTitlesAndIcons:(NSString *)buttonTitle1, ...{

    NSMutableArray *others = [NSMutableArray array];
    NSString *buttTitle = buttonTitle1;
    va_list ap;
    va_start(ap, buttonTitle1);
    do {
        [others addObject:buttTitle];
    } while ((buttTitle = va_arg(ap, NSString *)));
    va_end(ap);
    
    return [self initWithTitle:title cancelTitle:cancelTitle buttonTitleAndIconList:others];
}
//Way 2
- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle buttonTitleAndIconList:(NSArray *)titleAndIconList{
    self = [self initWithFrame:CGRectZero];
    if (self){
        CGFloat mar = 5.f, x = 20.f, y = 10.f, h = 40.f, w = [UIScreen mainScreen].bounds.size.width-2*x;
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLbl.text = title;
        titleLbl.numberOfLines = 0;
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.font = [UIFont systemFontOfSize:14.f];
        titleLbl.textColor = [UIColor darkGrayColor];
        [self addSubview:titleLbl];
        CGSize size = [title limitToSize:CGSizeMake(w, w) font:titleLbl.font];
        titleLbl.frame = CGRectMake(x, y, w, size.height);
        _titleLabel = titleLbl;
        
        _scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 2*mar + _titleLabel.bounds.size.height,
                                                                 [UIScreen mainScreen].bounds.size.width, h)];
        [self addSubview:_scroll];
#if !__has_feature(objc_arc)
        [_scroll release];
#endif
        x = 20.f;
        CGFloat w1 = 0, h1 = 0;
        CGFloat marY = 10.f, marX = 20.f; //marX = (280.f - ActionSheetMaxColumn*w1)/(ActionSheetMaxColumn+1) ;
        w1 = h1 = (_scroll.bounds.size.width - ActionSheetMaxColumn*marX - marX)/ActionSheetMaxColumn;
        w1 = h1 = MIN(w1, _kButtonSize);
        marX = (_scroll.bounds.size.width - ActionSheetMaxColumn*w1)/(ActionSheetMaxColumn+1);
        NSInteger tag = 0, row = 0, col = 0;
        //Buttons
        for (NSInteger i = 0; i < titleAndIconList.count; i+=2, tag++){
            row = tag/ActionSheetMaxColumn;
            col = tag%ActionSheetMaxColumn;
            
            NSString *buttTitle = titleAndIconList[i];
            NSString *iconFile = titleAndIconList[i+1];
            
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
            butt.tag = tag;
            butt.frame = CGRectMake(col*(marX+w1)+marX, row*(marY+h1+20.f)+marY, w1, h1);   //20.f for buttLbl
            [butt setImage:[UIImage imageNamed:iconFile] forState:UIControlStateNormal];
            [butt addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_scroll addSubview:butt];
            [_buttonList addObject:butt];

            UILabel *buttLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, butt.bounds.size.height + 5.f, w1, 15.f)];
            buttLbl.text = buttTitle;
            buttLbl.textColor = [UIColor darkGrayColor];
            buttLbl.backgroundColor = [UIColor clearColor];
            buttLbl.textAlignment = NSTextAlignmentCenter;
            buttLbl.font = [UIFont systemFontOfSize:12.f];
            [butt addSubview:buttLbl];
        }
        _scroll.contentSize = CGSizeMake(_scroll.bounds.size.width, ceilf(tag*1.f/ActionSheetMaxColumn)*(marY+h1+20.f)+marY);
        
        if (cancelTitle) {   //Cancel button
            y += mar;
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
            butt.tag = -1;
            butt.frame = CGRectMake(x, self.bounds.size.height - h - 15.f, w, h);
            butt.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            butt.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [butt setTitle:cancelTitle forState:UIControlStateNormal];
            [butt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [butt addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:butt];
            butt.layer.cornerRadius = 3.f;
            _cancelButton = butt;
            
        }

    }
    return self;
}
//Way 3
- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle buttonIcons:(NSString *)iconFile1, ...{
    self = [self initWithFrame:CGRectZero];
    if(self){
        CGFloat mar = 10.f, x = 20.f, y = mar, h = 36.f, w = [UIScreen mainScreen].bounds.size.width-2*x;
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLbl.text = title;
        titleLbl.numberOfLines = 0;
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.font = [UIFont systemFontOfSize:15.f];
        titleLbl.textColor = [UIColor darkGrayColor];
        [self addSubview:titleLbl];
        CGSize size = [title limitToSize:CGSizeMake(w, w) font:titleLbl.font];
        titleLbl.frame = CGRectMake(x, y, w, size.height);
        _titleLabel = titleLbl;
        
        _scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(x, 2*mar + _titleLabel.bounds.size.height, w, h)];
        [self addSubview:_scroll];
#if !__has_feature(objc_arc)
        [_scroll release];
#endif
        //Buttons
        NSString *icon = iconFile1;
        CGFloat w1 = 0, h1 = 0;
        CGFloat marY = 10.f, marX = 20.f;
        w1 = h1 = (_scroll.bounds.size.width - ActionSheetMaxColumn*marX - marX)/ActionSheetMaxColumn;
        w1 = h1 = MIN(w1, _kButtonSize);
        marX = (_scroll.bounds.size.width - ActionSheetMaxColumn*w1)/(ActionSheetMaxColumn+1);
        NSInteger i = 0, row = 0, col = 0;
        va_list ap;
        va_start(ap, iconFile1);
        do {
            row = i/ActionSheetMaxColumn;
            col = i%ActionSheetMaxColumn;
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
            butt.tag = i++;
            butt.frame = CGRectMake(col*(marX+w1)+marX, row*(marY+h1)+marY, w1, h1);
            butt.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [butt setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
            [butt addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_scroll addSubview:butt];
            [_buttonList addObject:butt];
            
        } while ((icon = va_arg(ap, NSString *)));
        va_end(ap);
        
        {   //Cancel button
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
            butt.tag = -1;
            butt.frame = CGRectMake(x, self.bounds.size.height - h - 15.f, w, h);
            butt.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            butt.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [butt setTitle:cancelTitle forState:UIControlStateNormal];
            [butt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [butt addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:butt];
            _cancelButton = butt;
        }
        _scroll.contentSize = CGSizeMake(_scroll.bounds.size.width, ceilf(i*1.f/ActionSheetMaxColumn)*(marY+h1)+marY);
    }
    return self;
}

- (IBAction)buttonAction:(UIButton *)sender{
    if (_delegate){
        [_delegate onActionSheet:self didClickAtButtonIndex:sender.tag];
    }
    else if (_clickBlock){
        _clickBlock(self, sender.tag);
    }
    [self dismiss];
}

- (NSArray *)buttons{
    return [NSArray arrayWithArray:_buttonList];
}

- (NSInteger)cancelButtonIndex{
    return -1;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [self cancelButtonIndex]){
        return [(UIButton *)_cancelButton titleForState:UIControlStateNormal];
    } else {
        UIButton *butt = _buttonList[buttonIndex];
        return [butt titleForState:UIControlStateNormal];
    }
}

- (void)showInView:(UIView *)parent{
    [parent addSubview:self];
    
    //Add a mask
    UIButton *mask = [UIButton buttonWithType:UIButtonTypeCustom];
    mask.frame = parent.bounds;
    [mask addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    mask.alpha = 0.f;
    mask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
    _mask = mask;
    [parent insertSubview:_mask belowSubview:self];

    _cancelButton.backgroundColor = [UIColor colorWithRed:0xd1/255.f green:0xd1/255.f blue:0xd1/255.f alpha:1.f];
    __block CGRect frame = CGRectMake(0, parent.frame.size.height + 64.f, parent.bounds.size.width,
                             _scroll.frame.origin.y + _scroll.contentSize.height + _cancelButton.bounds.size.height + 20.f + 5.f);
   
    
    if (frame.size.height > parent.bounds.size.height - 64.f){
        CGFloat diff = frame.size.height - parent.bounds.size.height + 64.f;
        _scroll.frame = CGRectMake(_scroll.frame.origin.x, _scroll.frame.origin.y,
                                   frame.size.width, _scroll.contentSize.height - diff);
        frame.size.height -= diff;
    } else {
        _scroll.frame = CGRectMake(_scroll.frame.origin.x, _scroll.frame.origin.y,
                                   frame.size.width, _scroll.contentSize.height);
    }
    self.frame = frame;
//    _scroll.delaysContentTouches = NO;  //ios 7 fix
    
    [UIView animateWithDuration:.25f animations:^{
        frame.origin.y = parent.frame.size.height - frame.size.height;
        self.frame = frame;
        _mask.alpha = 1.f;
    } completion:^(BOOL finished) {
    }];
}

- (void)showInViewFromTop:(UIView *)parent{
    [parent addSubview:self];
    
    //Add a mask
    UIButton *mask = [UIButton buttonWithType:UIButtonTypeCustom];
    mask.frame = parent.bounds;
    [mask addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    mask.alpha = 0.f;
    mask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
    _mask = mask;
    [parent insertSubview:_mask belowSubview:self];
    
    __block CGRect frame = CGRectMake(0, parent.frame.size.height + 64.f, parent.bounds.size.width,
                                      _scroll.frame.origin.y + _scroll.contentSize.height + _cancelButton.bounds.size.height + 20.f + 5.f);
    _scroll.frame = CGRectMake(_scroll.frame.origin.x, _scroll.frame.origin.y,
                               frame.size.width, _scroll.contentSize.height);
    self.frame = frame;
    [UIView animateWithDuration:.25f animations:^{
        frame.origin.y = parent.frame.size.height - frame.size.height;
        self.frame = frame;
        _mask.alpha = 1.f;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:.25f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = self.superview.frame.size.height + 64.f;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [_mask removeFromSuperview];
        [self removeFromSuperview];
    }];
}

@end
