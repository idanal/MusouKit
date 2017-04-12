//
//  ActionPicker.h
//  iDemo
//
//  Created by danal on 11-11-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A Picker support Date or List
 */
@interface ActionPicker : UIView<UIActionSheetDelegate> {
    UIToolbar   *_toolbar;
    UIView      *_picker;
    UIView      *_mask;
}
//Set a customized date format if it's a date picker
@property (nonatomic, copy) NSString *dateFormat;
@property (nonatomic, assign) UIDatePickerMode dateMode;    //default date

//Callback when selection confirmed
@property (nonatomic, copy) void (^onComplete)(ActionPicker *p, BOOL canceled);

//Data source for common picker use blocks
@property (nonatomic, copy) NSInteger (^totalColumns)(void);
@property (nonatomic, copy) NSInteger (^totalRowsInColumn)(NSInteger col);
@property (nonatomic, copy) NSString* (^titleForRowInColumn)(NSInteger col, NSInteger row);
@property (nonatomic, copy) void (^didSelectRowInColumn)(NSInteger col, NSInteger row);

/** Initializer */
- (id)initWithTitle:(NSString *)title datePicker:(BOOL)isDatePicker;

/** Bar Style */
- (void)setBarStyle:(UIBarStyle)barStyle;

/** Access to the picker */
- (UIPickerView *)picker;
- (UIDatePicker *)datePicker;

/** Selected date string, likes 1990-01-01 */
- (NSString *)dateStr;
- (NSTimeInterval)dateTimestamp;

/** Dismiss */
- (void)dismiss;

/** Show */
- (void)showInView:(UIView *)_view;

@end
