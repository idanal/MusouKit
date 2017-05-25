//
//  SysShare.h
//  Musou
//
//  Created by DANAL LUO on 2017/5/25.
//  Copyright © 2017年 danal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MSSysShare : NSObject

/**
 * Share with text, image and link
 * @param text Text
 * @param image UIImage
 * @param link NSURL
 * @param completion Callback
 */
- (void)share:(NSString *)text
        image:(UIImage *)image
         link:(NSURL *)link
   completion:(void (^)(BOOL completed, NSError *error))completion;

@end
