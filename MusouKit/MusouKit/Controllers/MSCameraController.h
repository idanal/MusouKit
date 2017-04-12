//
//  MSCameraController.h
//  MusouKit
//
//  Created by LYL on 5/1/13.
//  Copyright (c) 2013 danal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSCameraController : UIImagePickerController
<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (copy, nonatomic) void(^completionBlock)(UIImage *image);
@property (copy, nonatomic) void(^cancelBlock)(void);

- (void)presentTo:(UIViewController *)controller;


@end
