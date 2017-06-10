//
//  MSSegmentController.h
//  带标题的分段控制器
//
//  Created by DANAL LUO on 2017/6/7.
//
//

#import <UIKit/UIKit.h>

//选中一项controller时的通知，noti.object=选中的controller
extern NSString * const MSSegmentControllerNotificationOnSelected;


@interface MSSegmentController : UIViewController
/** 分段标题，必须与controllers一一对应 */
@property (nonatomic, strong) NSArray<NSString *> *titles;
/** 分段控制器，会自动被调用addChildViewController */
@property (nonatomic, strong) NSArray<UIViewController *> *controllers;
/** Title分段宽度，默认为80，如controllers数量n<=4，值为父视宽的1/n */
@property (nonatomic, assign) CGFloat segmentWidth;
/** Title指示器宽度，默认为与段同宽 */
@property (nonatomic, assign) CGFloat indicatorWidth;
/** 选中title时是否动画滑动切换到controller, 默认YES */
@property (nonatomic) BOOL animatedSelectController;
/** 当前选中项 */
@property (nonatomic, assign, readonly) NSInteger selectedIndex;
//Title样式
@property (nonatomic, strong) UIFont *selectedTitleFont;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIFont *normalTitleFont;
@property (nonatomic, strong) UIColor *normalTitleColor;

/**
 更新显示，更改了参数必须调用reloadData
 */
- (void)reloadData;

/** 
 选中某一项
 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;

/**
 Title指示器
 */
- (UIView *)indicatorView;

/**
 Title分段视图Cell生成方法, 默认生成包含一个Label的Cell
 子类可覆盖此方法来实现自定义样式
 
 @param collectionView Collection view for title
 @param indexPath IndexPath
 @return Cell
 */
- (UICollectionViewCell *)titleView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
