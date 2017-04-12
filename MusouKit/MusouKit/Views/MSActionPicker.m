//
//  ActionPicker.m
//  
//
//  Created by danal on 11-11-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MSActionPicker.h"

@interface MSActionPicker ()<UIPickerViewDataSource, UIPickerViewDelegate>
@end

@implementation MSActionPicker

- (id)initWithTitle:(NSString *)title datePicker:(BOOL)isDatePicker{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if ((self = [super initWithFrame:frame])) {
        
        static CGFloat kToolBarHeight = 44.f;
        
        self.backgroundColor = [UIColor clearColor];
        
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kToolBarHeight)];
        _toolbar.barStyle = UIBarStyleDefault;
        _toolbar.translucent = NO;
        _toolbar.barTintColor = [UIColor whiteColor];
        _toolbar.tintColor = [UIColor darkGrayColor];
        
        //        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, kToolBarHeight)];
        //        titleLabel.backgroundColor = [UIColor clearColor];
        //        titleLabel.font = [UIFont systemFontOfSize:17];
        //        titleLabel.textColor = [UIColor whiteColor];
        //        titleLabel.text = title;
        
        //        UIBarButtonItem *bbtTitle = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        
        UIBarButtonItem *bbtSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *bbtOK = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"确定", nil) style:UIBarButtonItemStylePlain target:self action:@selector(OK)];
        bbtOK.width = 60.f;
        UIBarButtonItem *bbtCancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self action:@selector(Cancel)];
        bbtCancel.width = 60.f;
        
        _toolbar.items = [NSArray arrayWithObjects:bbtCancel,bbtSpace,bbtOK, nil];
        
        CGRect rect = CGRectMake(0, kToolBarHeight, frame.size.width, 200);
        if (isDatePicker) {
            
            _picker = [[UIDatePicker alloc] initWithFrame:rect];
            [(UIDatePicker *)_picker setDatePickerMode:UIDatePickerModeDate];
            [(UIDatePicker *)_picker setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
        }else{
            
            UIPickerView *picker = [[UIPickerView alloc] initWithFrame:rect];
            picker.showsSelectionIndicator = YES;
            picker.dataSource = self;
            picker.delegate = self;
            _picker = picker;
        }
        _picker.backgroundColor = [UIColor whiteColor];
        _picker.clipsToBounds = YES;
        [self addSubview:_toolbar];
        [self addSubview:_picker];
        
        self.clipsToBounds = YES;
        self.frame = CGRectMake(0, 0, frame.size.width, _toolbar.bounds.size.height+_picker.bounds.size.height);
        
    }
    return self;
}

#pragma mark - Actions

- (void)setDateMode:(UIDatePickerMode)dateMode{
    _dateMode = dateMode;
    self.datePicker.datePickerMode = dateMode;
    if (dateMode == UIDatePickerModeDateAndTime){
        self.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    } else {
        self.dateFormat = @"yyyy-MM-dd";
    }
}

- (NSString *)dateStr{
    if ([_picker isKindOfClass:[UIDatePicker class]]){
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = _dateFormat ? _dateFormat : @"yyyy-MM-dd";
        return [df stringFromDate:[(UIDatePicker *)_picker date]];
    }
    return nil;
}

- (NSTimeInterval)dateTimestamp{
    if ([_picker isKindOfClass:[UIDatePicker class]]){
        return [(UIDatePicker *)_picker date].timeIntervalSince1970;
    }
    return 0;
}

- (id)picker{
    return _picker;
}

- (UIDatePicker *)datePicker{
    if ([_picker isKindOfClass:[UIDatePicker class]]){
        return (UIDatePicker *)_picker;
    }
    return nil;
}

- (void)setBarStyle:(UIBarStyle)barStyle{
    _toolbar.barStyle = barStyle;
}

- (void)dismiss{
    __block CGRect frame = self.frame;
    frame.origin = CGPointMake(0, [UIScreen mainScreen].bounds.size.height);
    [UIView animateWithDuration:.25f animations:^{
        
        self.frame = frame;
        _mask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.0f];
        
    } completion:^(BOOL finished) {
        
        [_mask removeFromSuperview];
        [self removeFromSuperview];
        
    }];
}

- (void)showInView:(UIView *)_view{
    if (self.superview) [self removeFromSuperview];
    
    UIButton *mask = [UIButton buttonWithType:UIButtonTypeCustom];
    mask.frame = _view.bounds;
    [mask addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_view addSubview:mask];
    _mask = mask;
    
    __block CGRect frame = self.frame;
    frame.origin = CGPointMake(0, _view.bounds.size.height);
    self.frame = frame;
    [_view addSubview:self];
    [UIView animateWithDuration:.25f animations:^{
        
        _mask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.0f];
        frame.origin.y = _view.bounds.size.height - frame.size.height;
        self.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)OK{
    [self dismiss];
    if (_onComplete){
        _onComplete(self,NO);
    }
}

- (IBAction)Cancel{
    [self dismiss];
    if (_onComplete){
        _onComplete(self,YES);
    }
}

#pragma mark - data source & delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return _totalColumns();
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _totalRowsInColumn(component);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _titleForRowInColumn(component, row);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _didSelectRowInColumn(component, row);
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *l = (UILabel *)view;
    if (!l){
        l = [[UILabel alloc] init];
        l.font = [UIFont systemFontOfSize:15];
        l.minimumScaleFactor = 0.5;
        l.adjustsFontSizeToFitWidth = YES;
        l.textAlignment = NSTextAlignmentCenter;
    }
    l.text = _titleForRowInColumn(component, row);
    return l;
}

@end
