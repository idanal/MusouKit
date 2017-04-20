//
//  MSImageView.h
//  MusouKit
//
//  Created by DANAL LUO on 2017/4/20.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Musou)

/** Set a new implementation for method setUrl:placeholder */
+ (void)replace_urlImplementation:(id)target sel:(SEL)targetSel;

/** Set image with an url and a optinal placeholder image */
- (void)setUrl:(NSString *)url placeholder:(UIImage *)placeholder;

@end
