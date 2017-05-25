//
//  SysShare.h
//  Musou
//
//  Created by DANAL LUO on 2017/5/25.
//  Copyright © 2017年 danal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 * 调用系统分享组件进行分享，无须导入第三方组件.
 * 注意：
 * 1.Weibo的icon必须要在设置中登录了微博账号才会出现
 * 2.Facebook、Twitter等同上
 * 3.微信分享必须要带有link参数，否则会提示不支持的类型
 */
@interface MSSysShare : NSObject
/** Will be called before share */
@property (nonatomic, copy) void (^beforeShare)(void);
/** Excluded activity types */
@property (nonatomic, strong) NSArray<UIActivityType> *excludedTypes;

/** Singleton */
+ (instancetype)shared;

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

/**
 * Check if the service is logined
 * @param serviceType e.g. SLServiceTypeSinaWeibo, see SLServiceTypes
 */
+ (BOOL)isServiceAvailable:(NSString *)serviceType;

@end
