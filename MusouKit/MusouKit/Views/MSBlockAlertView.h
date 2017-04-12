//
//  BlockAlertView.h
//  
//
//  Created by danal on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSBlockAlertView : UIAlertView <UIAlertViewDelegate>
@property (assign, nonatomic) id userData;
@property (copy, nonatomic) void(^clickBlock)(MSBlockAlertView *a,NSInteger buttonIndex);

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
otherButtonTitleList:(NSArray *)otherButtonTitleList;

@end

@interface MSBlockActionSheet : UIActionSheet <UIActionSheetDelegate>
@property (assign, nonatomic) id userData;
@property (copy, nonatomic) void(^clickBlock)(MSBlockActionSheet *s,NSInteger buttonIndex);

- (id)initWithTitle:(NSString *)title
  cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
otherButtonTitleList:(NSArray *)otherTitleList;

@end

@interface UIAlertView (Musou)
+ (void)alert:(NSString *)msg;
@end


@interface MSBlockPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
{
    id _picker;
    BOOL _onScreen;
    UIView *_container;
}
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UIButton *confirmButton;
@property (nonatomic, strong) NSArray<NSString *> *dataList;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, copy) void (^onConfirmBlock)(MSBlockPickerView *pickerView, NSString *result);
@property (nonatomic, copy) void (^onConfirmDatetimeBlock)(MSBlockPickerView *pickerView, NSDate *result);

+ (id)stringPicker;
+ (id)datetimePicker:(BOOL)withDate withTime:(BOOL)withTime;

- (void)showInView:(UIView *)view;
- (void)showInWindow;
- (void)dismiss;

@end
