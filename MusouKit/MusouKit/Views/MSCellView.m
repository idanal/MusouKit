//
//  MSCellView.m
//  
//
//  Created by danal.luo on 15/7/28.
//  Copyright (c) 2015年 danal. All rights reserved.
//

#import "MSCellView.h"

@implementation MSCellView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeRedraw;
    self.lineColor = [UIColor colorWithRed:200/255.f green:199/255.f blue:204/255.f alpha:1.f];
    self.textField.placeholder = @"请输入";
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self awakeFromNib];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGFloat h_2 = 1.f/[UIScreen mainScreen].scale/2;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, h_2*2);
    CGContextSetAllowsAntialiasing(c, false);
    CGContextSetShouldAntialias(c, false);
    
    [self.lineColor set];
    switch (_linePos) {
        case LineAtTop:
        {
            CGContextMoveToPoint(c, 0, h_2);
            CGContextAddLineToPoint(c, rect.size.width, h_2);
            CGContextStrokePath(c);
        }
            break;
        case LineAtBottom:
        {
            CGContextMoveToPoint(c, 0, rect.size.height-h_2);
            CGContextAddLineToPoint(c, rect.size.width, rect.size.height-h_2);
            CGContextStrokePath(c);
        }
            break;
        case LineAtTopAndBottom:
        {
            CGContextMoveToPoint(c, 0, h_2);
            CGContextAddLineToPoint(c, rect.size.width, h_2);
            CGContextMoveToPoint(c, 0, rect.size.height-h_2);
            CGContextAddLineToPoint(c, rect.size.width, rect.size.height-h_2);
            CGContextStrokePath(c);
        }
            break;
        default:
            break;
    }
}

@end


@implementation MSCellViewBottom

- (void)awakeFromNib{
    [super awakeFromNib];
    self.linePos = LineAtBottom;
}

@end


@implementation MSCellViewBoth

- (void)awakeFromNib{
    [super awakeFromNib];
    self.linePos = LineAtTopAndBottom;
}

@end

