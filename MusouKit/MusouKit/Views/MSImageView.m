//
//  MSImageView.m
//  MusouKit
//
//  Created by DANAL LUO on 2017/4/20.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSImageView.h"
#import <objc/runtime.h>

@implementation UIImageView (Musou)

+ (void)replace_urlImplementation:(id)target sel:(SEL)targetSel{
    SEL orig = @selector(setUrl:placeholder:);
    Method m = class_getInstanceMethod([target class], targetSel);
    class_replaceMethod(self, orig, method_getImplementation(m), method_getTypeEncoding(m));
}

- (void)setUrl:(NSString *)url placeholder:(UIImage *)placeholder{
    NSLog(@"Pls call 'replace_urlImplementation:sel' to set an Implementation.");
}

@end
