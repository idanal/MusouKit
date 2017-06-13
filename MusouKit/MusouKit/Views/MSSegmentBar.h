//
//  MSSegmentBar.h
//  
//
//  Created by danal-rich on 7/29/14.
//  Copyright (c) 2014 yz. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * The segment button
 */
typedef UIButton MSSegmentButton;


/**
 * The indicator under current segment button
 */
typedef UIImageView MSSegmentIndicator;


/**
 * Segmented bar for text segment
 */
@interface MSSegmentBar : UIControl{
    BOOL _hasSetup;
    UIView *_line;
    UIView *_indicator;
    __weak NSLayoutConstraint *_indicatorCenterX;
}
@property (nonatomic, readonly, strong) NSArray<UIButton *> *buttons;         //Segmented buttons
@property (nonatomic, assign) CGFloat indicatorWidth;           //Default not set
@property (nonatomic, assign) CGFloat indicatorHeight;           //Default 2.f
@property (nonatomic, assign) NSInteger selectedIndex;          //The selected button index
@property (nonatomic, assign) BOOL indicatorHidden;             //Default NO
@property (nonatomic, copy) void (^onButtonConfig)(UIButton *button, BOOL selected);    //Config

- (id)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles;
- (id)initWithFrame:(CGRect)frame buttons:(NSArray<UIButton *> *)buttons;

//为适应特别需求
- (void)clearSelected;

@end


/**
 * Segmented view that can slide, using auto layout
 */
@interface MSSegmentView : UIView <UIScrollViewDelegate>{
    __weak UIScrollView *_scroll;
}
/** MSSegmentViewDelegate */
@property (nonatomic, weak) IBOutlet id delegate;
/** Could be nil */
@property (nonatomic, weak) IBOutlet MSSegmentBar *segmentBar;
/** Read current page index */
@property (nonatomic, assign) NSInteger currentPage;

/**
 Reload
 
 @param parentController Parent Controller
 @param titles Titles
 @param controllers Controllers
 */
- (void)reloadWithParentController:(UIViewController *)parentController
                            titles:(NSArray<NSString *> *)titles
                       controllers:(NSArray<UIViewController *> *)controllers;
@end

@protocol MSSegmentViewDelegate <NSObject>
/**
 * Callback when scroll to a new page
 */
- (void)segmentViewDidScrollToPage:(MSSegmentView *)view page:(NSInteger)page;
@end


/**
 * Segmented bar that can filter
 */
@class MSFilterOptionView;

@interface MSFilterSegmentBar : MSSegmentBar
@property (nonatomic, copy) void (^onButtonClickAgain)(NSInteger idx, MSFilterSegmentBar* bar);
@property (nonatomic, weak) MSFilterOptionView *optionView;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber*> *itemFilterSelectedRows;
- (MSFilterOptionView *)showOptionView:(NSArray<NSString *> *)items;
@end

@interface MSFilterSegmentButton : MSSegmentButton
@property (nonatomic) BOOL descend;
@end

@interface MSFilterOptionView : UITableView
<UITableViewDataSource, UITableViewDelegate> {
    UIView *_maskView;
}
@property (nonatomic, weak) MSFilterSegmentBar *segBar;
@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) void (^onSelect)(NSInteger row);

- (void)showIn:(UIView *)parent bellow:(UIView *)view;
- (void)dismiss;
+ (instancetype)getInstance:(MSFilterSegmentBar *)bar;
@end
