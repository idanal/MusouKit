//
//  MSCameraController.m
//  MusouKit
//
//  Created by LYL on 5/1/13.
//  Copyright (c) 2013 danal. All rights reserved.
//

#import "MSCameraController.h"

@implementation MSCameraController
@synthesize completionBlock = _completionBlock, cancelBlock = _cancelBlock;

- (void)dealloc{
    self.completionBlock = nil;
    self.cancelBlock = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)presentTo:(UIViewController *)controller{
    [controller presentViewController:self animated:YES completion:NULL];
}

- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ImagePicker Delegates

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self cancel];
    if (_cancelBlock) {
        _cancelBlock();
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self cancel];
    if (_completionBlock) {
        UIImage *image = self.allowsEditing
        ? [info objectForKey:@"UIImagePickerControllerEditedImage"]
        : [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        _completionBlock(image);
    }
}
@end
