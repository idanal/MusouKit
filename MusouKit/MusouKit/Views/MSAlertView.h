//
//  MSAlertView.h
//  An AlertView like UIAlertView
//
//  Created by DANAL LUO on 30/06/2017.
//  Copyright © 2017 danal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSAlertView : UIView
/** Title label */
@property (nonatomic, weak) UILabel *titleLabel;
/** Message label */
@property (nonatomic, weak) UILabel *messageLabel;
/** Cancel button index. Allways 0 */
@property (nonatomic, assign, readonly) NSInteger cancelButtonIndex;
/** Click callback */
@property (nonatomic, copy) void(^clickBlock)(MSAlertView *a, NSInteger buttonIndex);

/** create an instance */
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message 
            cancelButtonTitle:(NSString *)cancelTitle
            otherButtonTitles:(NSArray *)otherTitles;

/** Show */
- (void)show;

/** dismiss */
- (void)dismiss;

@end
