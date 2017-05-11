//
//  CardSwipeView.h
//  
//
//  Created by DANAL LUO on 2017/5/11.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol MSCardSwipeViewDelegate;

@interface MSCardSwipeView : UIView
@property (nonatomic, weak) id<MSCardSwipeViewDelegate> delegate;

/** Reload data from index 0 */
- (void)reloadData;

@end


/** Data Source Delegate */
@protocol MSCardSwipeViewDelegate <NSObject>

/** Total number of cards */
- (NSInteger)cardSwipeViewTotalNumber;
/** A view at the specified index */
- (UIView *)cardSwipeView:(MSCardSwipeView *)cardView viewAtIndex:(NSInteger)idx;

@end
