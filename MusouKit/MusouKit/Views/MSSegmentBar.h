//
//  MSSegmentBar.h
//  
//
//  Created by danal-rich on 7/29/14.
//  Copyright (c) 2014 yz. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Segmented bar for text segment
 */
@interface MSSegmentBar : UIControl{
    BOOL _hasSetup;
}
@property (nonatomic,readonly, strong) UIView *indicator;       //Indicate the current segment
@property (nonatomic,readonly, strong) NSArray *buttons;         //Segmented buttons
@property (nonatomic, assign) CGFloat indicatorWidth;           //Default not set
@property (nonatomic, assign) CGFloat indicatorHeight;           //Default 2.f
@property (nonatomic, assign) NSInteger selectedIndex;          //The selected button index
@property (nonatomic, assign) BOOL indicatorHidden;             //Default NO

- (id)initWithFrame:(CGRect)frame buttons:(NSArray *)buttons;

//为适应特别需求
- (void)clearSelected;

@end


/**
 * The segment button
 */
typedef UIButton MSSegmentButton;


/**
 * The indicator under current segment button
 */
typedef UIImageView MSSegmentIndicator;


/**
 * Segmented view that can slide
 */
@interface MSSegmentView : UIView <UIScrollViewDelegate>{
    UIScrollView *_scroll;
}
@property (nonatomic, assign) IBOutlet id delegate;  /* MSSegmentViewDelegate */
@property (nonatomic, assign) IBOutlet MSSegmentBar *segmentBar;
@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger currentPage;
@end

@protocol MSSegmentViewDelegate <NSObject>
/**
 * Return number of total pages
 */
- (NSInteger)segmentViewNumberOfPages;
/**
 * Return the content view at the specified page
 */
- (UIView *)segmentView:(MSSegmentView *)segView contentViewAtPage:(NSInteger)page;
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
