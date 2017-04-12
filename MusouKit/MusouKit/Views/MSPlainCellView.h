//
//  MSPlainCellView.h
//  iLove
//
//  Created by danal.luo on 15/7/28.
//  Copyright (c) 2015年 danal. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    LineAtTop = 0,
    LineAtBottom = 1,
    LineAtTopAndBottom = 2,
};

@interface MSPlainCellView : UIView
@property (assign, nonatomic) NSInteger linePos;    //0-top, 1-bottom, 2-top&bottom
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) CGFloat lineIndent;   //default 0
//Extensions
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@end


@interface MSPlainCellViewBottom : MSPlainCellView
@end


@interface MSPlainCellViewBoth : MSPlainCellView
@end
