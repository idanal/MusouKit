//
//  MSGuideView.h
//  引导图视图
//
//  Created by DANAL LUO on 29/06/2017.
//
//

#import <UIKit/UIKit.h>

@interface MSGuideView : UIView
/** The page control */
@property (nonatomic, weak, readonly) UIPageControl *pageControl;
/** Enter button show at the last page */
@property (nonatomic, strong) UIButton *enterButton;
/** Images to show */
@property (nonatomic, strong) NSArray<UIImage *> *images;

/** Show on screen */
- (void)show;

@end
