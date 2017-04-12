//
//  ActionSheet.h
//  UMatch
//
//  Created by danal.luo on 7/6/14.
//  Copyright (c) 2014 danal. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ActionSheetDelegate;
@interface ActionSheet : UIView {
    UIScrollView *_scroll;
    UIView *_cancelButton;
    UIView *_mask;
}
@property (assign, nonatomic) id<ActionSheetDelegate> delegate;
@property (assign, nonatomic) id userData;
@property (assign, nonatomic) UILabel *titleLabel;
@property (readonly, nonatomic) NSArray *buttons;
@property (copy, nonatomic) void(^clickBlock)(ActionSheet *sheet, NSInteger buttonIndex);

/** Title sheet with titles */
- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSString *)other,...;
- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitleList:(NSArray *)others;

/** Icon sheet without a label below every button */
- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle buttonIcons:(NSString *)iconFile1,...;
/** Icon sheet with a label below every button */
- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle buttonTitlesAndIcons:(NSString *)buttonTitle1,...;  //buttonTitle1,iconFile1,...
- (id)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle buttonTitleAndIconList:(NSArray *)titleAndIconList;

/** Retrieve the index of cancel button */
- (NSInteger)cancelButtonIndex;

/** Retrieve a title at a index */
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

/** Show */
- (void)showInView:(UIView *)parent;
- (void)showInViewFromTop:(UIView *)parent;

/** Close */
- (void)dismiss;

@end

static const NSInteger ActionSheetMaxColumn = 3;

@protocol ActionSheetDelegate <NSObject>
- (void)onActionSheet:(ActionSheet *)sheet didClickAtButtonIndex:(NSInteger)buttonIndex;
@end
