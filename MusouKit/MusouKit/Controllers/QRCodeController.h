//
//  QRCodeController.h
//  Demo
//
//  Created by danal on 7/7/15.
//  Copyright (c) 2015 danal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeController : UIViewController
@property (nonatomic, assign) UIView *overlay;  //Customized overlay view
@property (nonatomic, copy) void (^onScanComplete)(NSString *result, id controller);

- (void)scan;
- (void)stop;

/** Create a image with a qrcode string */
+ (UIImage *)createQRCodeImage:(NSString *)string;

/** Parse a qrcode image */
+ (NSString *)parseQRCodeImage:(UIImage *)image;

+ (NSString *)parseAction:(NSString *)string;
+ (NSString *)parseValue:(NSString *)string;

@end


//Default overlay view
@interface QRCodeOverlay : UIView
@property (nonatomic, assign) IBOutlet UIButton *cancelButton;
@end
