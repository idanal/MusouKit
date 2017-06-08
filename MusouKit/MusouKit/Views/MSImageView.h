//
//  MSImageView.h
//  MusouKit
//
//  Created by DANAL LUO on 2017/4/20.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MSImageTypeUnkown = 0,
    MSImageTypeJPEG,
    MSImageTypePNG,
    MSImageTypeGIF,
    MSImageTypeTIFF,
} MSImageType;


@interface UIImageView (Musou)

/** Set a new implementation for method setUrl:placeholder */
+ (void)replace_urlImplementation:(Class)targetCls sel:(SEL)targetSel;

/** Set image with an url and a optinal placeholder image */
- (void)setUrl:(NSURL *)url placeholder:(UIImage *)placeholder;

/**
 Load image with an url. 
 Generate a thumbnail and load it if thumbSize if non-zero

 @param url URL
 @param placeholder A placeholder image
 @param thumbSize Thumbnail size
 */
- (void)setUrl:(NSURL *)url placeholder:(UIImage *)placeholder thumbSize:(CGSize)thumbSize;

/** The cache directory */
+ (NSString *)cacheDir;

/** Local cached filename of an url */
+ (NSString *)filenameOfURL:(NSURL *)url;

/** Get the type of an image */
+ (MSImageType)typeOfImageDataFirstChar:(uint8_t)c;

@end
