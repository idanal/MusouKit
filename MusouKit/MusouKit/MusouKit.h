//
//  MusouKit.h
//  MusouKit
//
//  Created by DANAL LUO on 2017/4/10.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "MSAdditions.h"
#import "MSJSONEntity.h"
#import "DLAutoLayout.h"

#import "MSDataSource.h"
#import "MSSimpleHttp.h"
#import "MSHttpRequest.h"

#import "MSActionPicker.h"
#import "MSActionSheet.h"
#import "MSCellView.h"
#import "MSHUDView.h"
#import "MSRangeSlider.h"
#import "MSBlockAlertView.h"
#import "MSImageView.h"
#import "MSAutoWebView.h"
#import "MSSegmentBar.h"
#import "MSTimerButton.h"
#import "MSAnimatedImageView.h"

#import "MSBaseViewController.h"
#import "MSCameraController.h"
#import "MSQRCodeController.h"
#import "MSSegmentController.h"



//Macros
#define kAppleLookupApi @"http://itunes.apple.com/lookup?id=%@"

//Declare a weak reference to self
#define MSWeakSelf __weak typeof(self) weakSelf = self

//Print log in the console
#ifdef DEBUG
#define MSLog(format,...) printf("%s(%d):%s\n", @(__FILE__).lastPathComponent.UTF8String, __LINE__, [[NSString alloc] initWithFormat:format,__VA_ARGS__].UTF8String)
#else
#define MSLog(format,...)
#endif
