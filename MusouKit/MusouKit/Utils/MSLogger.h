//
//  MSLogger.h
//  MusouKit
//
//  Created by DANAL LUO on 2017/5/12.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSLogger : NSObject

+ (instancetype)shared;

/** Write log content */
- (void)logd:(NSString *)content;

/** Read log content */
- (NSString *)readLog;

/** Read log size in byte */
- (NSNumber *)logSize;

/** Clear log */
- (void)clear;

@end
