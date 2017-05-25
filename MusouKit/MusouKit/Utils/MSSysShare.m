//
//  SysShare.m
//  Musou
//
//  Created by DANAL LUO on 2017/5/25.
//  Copyright © 2017年 danal. All rights reserved.
//

#import "MSSysShare.h"

@implementation MSSysShare

- (void)share:(NSString *)text image:(UIImage *)image link:(NSURL *)link completion:(void (^)(BOOL completed, NSError *error))completion{
    
    NSMutableArray *items = [NSMutableArray new];
    if (text) [items addObject:text];
    if (image) [items addObject:image];
    if (link) [items addObject:link];
    
    UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    act.excludedActivityTypes = @[
                                  //UIActivityTypeMail,
                                  UIActivityTypePrint,
                                  UIActivityTypeOpenInIBooks,
                                  UIActivityTypeAssignToContact,
                                  UIActivityTypeAddToReadingList
                                  ];
    [act setCompletionWithItemsHandler:^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        NSLog(@"completed:%d,%@,%@", completed, returnedItems, activityError);
        if (completion) completion(completed, activityError);
    }];
    
    UIViewController *controller = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [controller presentViewController:act animated:YES completion:^{
        
    }];
}

@end
