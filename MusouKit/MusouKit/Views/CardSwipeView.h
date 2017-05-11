//
//  CardSwipeView.h
//  CollectionLayoutKit
//
//  Created by DANAL LUO on 2017/5/11.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol CardSwipeViewDelegate;

@interface CardSwipeView : UIView
@property (nonatomic, weak) id<CardSwipeViewDelegate> delegate;
- (UIView *)dequeueResuableView;
@end


@protocol CardSwipeViewDelegate <NSObject>

- (NSInteger)cardSwipeViewTotalNumber;
- (UIView *)cardSwipeView:(CardSwipeView *)cardView viewAtIndex:(NSInteger)idx;

@end
