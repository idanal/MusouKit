//
//  ViewController.h
//  DLAutolayout
//  QQ: 290994669
//  Created by danal on 8/26/16.
//  Copyright © 2016 danal. All rights reserved.
//

#import <UIKit/UIKit.h>

//Void
typedef void (^ALVoidBlock)(void);
//Begin with parent view and a refer view to align
typedef UIView* (^ALViewBlock)(UIView *parent, UIView *toView);
//Value = multiplier * attribute + constant
typedef UIView* (^ALValueBlock)(CGFloat constant);
typedef UIView* (^ALReleationBlock)(NSLayoutRelation relation);


@interface UIView (DLAutoLayout)

/** First step: call begin */
@property (nonatomic, readonly) ALViewBlock dl_begin;
/** Last step: call end */
@property (nonatomic, readonly) ALVoidBlock dl_end;
/** Set width */
@property (nonatomic, readonly) ALValueBlock width;
/** Set height */
@property (nonatomic, readonly) ALValueBlock height;

/** Set margins */
@property (nonatomic, readonly) ALValueBlock leading;
@property (nonatomic, readonly) ALValueBlock trailing;
@property (nonatomic, readonly) ALValueBlock left;
@property (nonatomic, readonly) ALValueBlock right;
@property (nonatomic, readonly) ALValueBlock top;
@property (nonatomic, readonly) ALValueBlock bottom;
/** Shortcut for setting 4 margins */
@property (nonatomic, readonly) ALValueBlock edge;

/** Alignments */
@property (nonatomic, readonly) ALValueBlock alignLeft;
@property (nonatomic, readonly) ALValueBlock alignRight;
@property (nonatomic, readonly) ALValueBlock alignTop;
@property (nonatomic, readonly) ALValueBlock alignBottom;
@property (nonatomic, readonly) ALValueBlock alignCenterX;
@property (nonatomic, readonly) ALValueBlock alignCenterY;
@property (nonatomic, readonly) ALValueBlock alignBaseline;

/** Change the properties of the last added constraint */
@property (nonatomic, readonly) ALValueBlock priority;
@property (nonatomic, readonly) ALValueBlock multiplier;
@property (nonatomic, readonly) ALReleationBlock relation;

/** Quickly remove olds constraints */
- (instancetype)dl_reset;

/** All added constraints */
- (NSMutableDictionary *)dl_constraintInfo;

/** Find a added constraint by attribute */
- (NSLayoutConstraint *)dl_findConstraint:(NSLayoutAttribute)attr;

@end

/*
 Samples:
 
 lbl
 .dl_resetLayout
 .dl_begin(self.view, nil)
 .left(10)
 .right(-10)
 .relation(NSLayoutRelationLessThanOrEqual)
 .dl_end();
 
 lbl
 .dl_begin(self.view, box1)
 .top(10)
 .dl_end();
*/
