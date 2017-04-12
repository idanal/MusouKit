//
//  BlockAlertView.m
//  WeiboFun
//
//  Created by luo danal on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MSBlockAlertView.h"



@implementation MSBlockAlertView

- (void)dealloc{
    self.clickBlock = nil;
    self.userData = nil;
    self.delegate = nil;

}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil];
    if (self){
        va_list arg;
        va_start(arg, otherButtonTitles);
        NSString *buttonTitle = nil;
        while ((buttonTitle = va_arg(arg, NSString*))) {
            [self addButtonWithTitle:buttonTitle];
        }
        va_end(arg);
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitleList:(NSArray *)otherButtonTitleList{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil,nil];
    if (self){
        for (NSString *t in otherButtonTitleList){
            [self addButtonWithTitle:t];
        }
    }
    return self;
}

#pragma mark - Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (_clickBlock != NULL) {
        _clickBlock(self, buttonIndex);
    }
}

@end



@implementation MSBlockActionSheet

- (void)dealloc{
    self.clickBlock = nil;
    self.userData = nil;

}

- (id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
    
        if (otherButtonTitles != nil) { //Generally in this case
            va_list apList;
            va_start(apList, otherButtonTitles);
            NSString *ttl = nil;
            while ((ttl = va_arg(apList, NSString*))) {
                [self addButtonWithTitle:ttl];
            }
            if (cancelButtonTitle != nil) {
                [self addButtonWithTitle:cancelButtonTitle];
                [self setCancelButtonIndex:self.numberOfButtons - 1];
            }
            va_end(apList);
        }
        self.delegate = self;
    } 
    return self;
}

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitleList:(NSArray *)otherTitleList{
    
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil, nil];
    if (self){
        for (NSString *other in otherTitleList) {
            [self addButtonWithTitle:other];
        }
        if (cancelButtonTitle != nil) {
            [self addButtonWithTitle:cancelButtonTitle];
            [self setCancelButtonIndex:self.numberOfButtons - 1];
        }
        self.delegate = self;
    }
    return self;
}

#pragma mark - delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (_clickBlock != NULL) {
        _clickBlock(self,buttonIndex);
    }
}

@end


@implementation UIAlertView (Musou)

+ (void)alert:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end

@implementation MSBlockPickerView

+ (id)stringPicker{
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, w, 200)];
    return [[self alloc] initWithPicker:picker];
}

+ (id)datetimePicker:(BOOL)withDate withTime:(BOOL)withTime{
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, w, 200)];
    picker.datePickerMode = UIDatePickerModeDateAndTime;
    if (!withDate) picker.datePickerMode = UIDatePickerModeTime;
    if (!withTime) picker.datePickerMode = UIDatePickerModeDate;
    return [[self alloc] initWithPicker:picker];
}

- (id)initWithPicker:(UIView *)picker{
    CGFloat barh = 40;
    CGRect rect = CGRectMake(0, 0, picker.bounds.size.width, picker.bounds.size.height+barh);
    
    self = [super initWithFrame:rect];
    if (self){
        _container = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_container];
        
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, barh)];
        bar.barTintColor = [UIColor whiteColor];
        bar.translucent = NO;
        [_container addSubview:bar];
        
        _textLabel = [[UILabel alloc] initWithFrame:bar.bounds];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:16];
        [bar addSubview:_textLabel];
        
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(rect.size.width-50, 0, 50, 40);
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmButton setTitle:@"确定" forState:0];
        [_confirmButton setTitleColor:[UIColor darkGrayColor] forState:0];
        [_confirmButton addTarget:self action:@selector(_onConfirm) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:_confirmButton];
        
        UIView *line = [[UILabel alloc] initWithFrame:CGRectMake(0, barh-0.5f, rect.size.width, 0.5f)];
        line.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1f];
        [bar addSubview:line];
        
        picker.frame = CGRectMake(0, barh, picker.bounds.size.width, picker.bounds.size.height);
        _picker = picker;
        [_container addSubview:_picker];
        [self picker].delegate = self;
        [self picker].dataSource = self;
        [self picker].backgroundColor = [UIColor whiteColor];

    }
    return self;
}

- (UIPickerView *)picker{
    if ([_picker isKindOfClass:[UIPickerView class]]) return _picker;
    return nil;
}

- (UIDatePicker *)datePicker{
    if ([_picker isKindOfClass:[UIDatePicker class]]) return _picker;
    return nil;
}

- (void)showInView:(UIView *)view{
    if (_onScreen) return;
    
    _onScreen = YES;
    [view addSubview:self];
    self.frame = view.bounds;
    
    UIView *picker = _container;
    __block CGRect rect = picker.frame;
    rect.origin = CGPointMake(0, self.bounds.size.height);
    picker.frame = rect;
    
    [UIView animateWithDuration:.25f animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
        rect.origin = CGPointMake(0, self.bounds.size.height-picker.bounds.size.height);
        picker.frame = rect;
        
    } completion:^(BOOL finished) {
    }];
    
     self.userInteractionEnabled = YES;
}

- (void)showInWindow{
    UIWindow *win = [[UIApplication sharedApplication].windows firstObject];
    [self showInView:win];
}

- (void)dismiss{
    UIView *picker = _container;
    __block CGRect rect = picker.frame;
    
    [UIView animateWithDuration:.25f animations:^{
        rect.origin = CGPointMake(0, self.bounds.size.height);
        picker.frame = rect;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

- (void)_onConfirm{
    if ([self picker])  _onConfirmBlock(self, _dataList[_selectedRow]);
    else if ([self datePicker]) _onConfirmDatetimeBlock(self, [self datePicker].date);
    [self dismiss];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches anyObject];
    if ( !CGRectContainsPoint(_container.frame, [t locationInView:self]) ){
        [self dismiss];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _dataList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _dataList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _selectedRow = row;
}

@end
