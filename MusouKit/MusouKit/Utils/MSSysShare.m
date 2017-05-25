//
//  SysShare.m
//  Musou
//
//  Created by DANAL LUO on 2017/5/25.
//  Copyright © 2017年 danal. All rights reserved.
//

#import "MSSysShare.h"
#import <Social/Social.h>

@interface MSWeiboActivity : UIActivity
@property (nonatomic, strong) NSArray *activityItems;
@end

@implementation MSWeiboActivity

- (NSString *)activityType{
    return UIActivityTypePostToWeibo;
}

- (NSString *)activityTitle{
    return @"Weibo";
}

- (UIImage *)activityImage{
    return nil;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    return YES;
}

- (void)performActivity{
    //Call social kit
    SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    
    for (id item in self.activityItems){      
        if ([item isKindOfClass:[NSString class]]){
            [compose setInitialText:item];
        } else if ([item isKindOfClass:[UIImage class]]){
            [compose addImage:item];
        } else if ([item isKindOfClass:[NSURL class]]){
            [compose addURL:item];
        }
    }

    [compose setCompletionHandler:^(SLComposeViewControllerResult result){
        [self activityDidFinish:result == SLComposeViewControllerResultDone];
    }];
    UIViewController *controller = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [controller presentViewController:compose animated:YES completion:nil];
    
}

@end



@implementation MSSysShare

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    static MSSysShare *_sysShare;
    dispatch_once(&onceToken, ^{
        _sysShare = [[self alloc] init];
    });
    return _sysShare;
}

- (id)init{
    self = [super init];
    if (self){
        self.excludedTypes = @[
                               //UIActivityTypeMail,
                               UIActivityTypeAssignToContact,
                               UIActivityTypeSaveToCameraRoll,
                               UIActivityTypeAddToReadingList,
                               UIActivityTypeAirDrop,
                               UIActivityTypeOpenInIBooks,
                               ];
        
        self.beforeShare = ^{
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                
                if (![MSSysShare isServiceAvailable:SLServiceTypeSinaWeibo]){
                    [MSSysShare alertTips:NSLocalizedString(@"如要分享到微博，请先到系统设置中登录您的微博账号", nil)];
                }
            });
        };
    }
    return self;
}

- (void)share:(NSString *)text image:(UIImage *)image link:(NSURL *)link completion:(void (^)(BOOL completed, NSError *error))completion{
    
    if (self.beforeShare){
        self.beforeShare();
        self.beforeShare = nil;
    }
    
    NSMutableArray *items = [NSMutableArray new];
    if (text) [items addObject:text];
    if (image) [items addObject:image];
    if (link) [items addObject:link];
    
    //Weibo icon will auto appear when you login weibo, which in the system settings
    //MSWeiboActivity *wb = [MSWeiboActivity new];
    
    UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                      applicationActivities:nil];
    act.excludedActivityTypes = self.excludedTypes;
    [act setCompletionWithItemsHandler:^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        
        if (completion) completion(completed, activityError);
    }];
    
    UIViewController *controller = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [controller presentViewController:act animated:YES completion:nil];
}

+ (BOOL)isServiceAvailable:(NSString *)serviceType{
    return [SLComposeViewController isAvailableForServiceType:serviceType];
}

+ (void)alertTips:(NSString *)tips{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:tips
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

@end

