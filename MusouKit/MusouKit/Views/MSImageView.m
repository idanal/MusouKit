//
//  MSImageView.m
//  MusouKit
//
//  Created by DANAL LUO on 2017/4/20.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <objc/runtime.h>
#import "MSImageView.h"
#import "MSAdditions.h"


@implementation UIImageView (Musou)

+ (void)replace_urlImplementation:(Class)targetCls sel:(SEL)targetSel{
    SEL orig = @selector(setUrl:placeholder:);
    Method m = class_getInstanceMethod(targetCls, targetSel);
    class_replaceMethod(self, orig, method_getImplementation(m), method_getTypeEncoding(m));
}

- (void)setUrl:(NSURL *)url placeholder:(UIImage *)placeholder{
    [self setUrl:url placeholder:placeholder thumbSize:CGSizeZero];
}

- (void)setUrl:(NSURL *)url placeholder:(UIImage *)placeholder thumbSize:(CGSize)thumbSize{
    
    if (url == nil) return;
    
    NSString *dest = [NSString stringWithFormat:@"%@/%@", [self.class cacheDir], [self.class filenameOfURL:url]];
    if (thumbSize.width > 1){
        NSString *thumbDest = [dest stringByAppendingString:@"thumb"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:thumbDest]){
            self.image = [[UIImage alloc] initWithContentsOfFile:thumbDest];
            return;
        }
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:dest]){
        self.image = [[UIImage alloc] initWithContentsOfFile:dest];
        return;
    }
    
    self.image = placeholder;
    
    [[self task] cancel];
    [self setTask:nil];
    
    dispatch_semaphore_t sema = [self.class sharedSemaphore];
 
    NSURLSessionTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url
                                                             completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //Send a signal for next loading
        dispatch_semaphore_signal(sema);
                                                                 
        if (error || location == nil) {
            //NSLog(@"%@", error);
            return;
        }
        //NSLog(@"start");
        
        NSString *path = @(location.fileSystemRepresentation);
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        NSNumber *fileSize = [attrs objectForKey:NSFileSize];
        
        //Move to cache dir If download full completed
        if (fileSize.longLongValue == response.expectedContentLength){
            
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:dest] error:nil];
            if (thumbSize.width > 1){
                //Generate a thumbnail
                UIImage *source = [[UIImage alloc] initWithContentsOfFile:dest];
                UIImage *thumb = [source scaleByFactor:MIN(thumbSize.width/source.size.width, 1.0)];
                
                FILE *f = fopen(dest.UTF8String, "r");
                uint8_t c;
                fread(&c, 1, 1, f);
                fclose(f);
                
                NSData *thumbData;
                switch ([self.class typeOfImageDataFirstChar:c]) {
                    case MSImageTypePNG:{
                        thumbData = UIImagePNGRepresentation(thumb);
                    }
                        break;
                    case MSImageTypeJPEG:
                    default:{
                        thumbData = UIImageJPEGRepresentation(thumb, 0.8);
                    }
                        break;
                }
                NSString *thumbDest = [dest stringByAppendingString:@"thumb"];
                [thumbData writeToFile:thumbDest atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = [[UIImage alloc] initWithContentsOfFile:thumbDest];
                });
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = [[UIImage alloc] initWithContentsOfFile:dest];
                });
            }
        }
        
    }];
    [self setTask:task];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //NSLog(@"waiting");
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        [task resume];
    });
}

static const char * MSImageViewTaskKey = "MSImageViewTaskKey";

- (NSURLSessionTask *)task{
    return objc_getAssociatedObject(self, &MSImageViewTaskKey);
}

- (void)setTask:(NSURLSessionTask *)task{
    objc_setAssociatedObject(self, &MSImageViewTaskKey, task, OBJC_ASSOCIATION_ASSIGN);
}

+ (dispatch_semaphore_t)sharedSemaphore{
    static dispatch_semaphore_t sema = nil;
    if (!sema){
        //Max concurrent = 5
        sema = dispatch_semaphore_create(5);
    }
    return sema;
}

+ (NSString *)cacheDir{
    static NSString *dir = nil;
    if (!dir){
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"com.danal.MusouKit.imageCache"];
        dir = path;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir]){
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return dir;
}

+ (NSString *)filenameOfURL:(NSURL *)url{
    return url.absoluteString.md5;
}

+ (MSImageType)typeOfImageDataFirstChar:(uint8_t)c{
//    uint8_t c;
//    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return MSImageTypeJPEG;
        case 0x89:
            return MSImageTypePNG;
        case 0x47:
            return MSImageTypeGIF;
        case 0x49:
        case 0x4D:
            return MSImageTypeTIFF;
    }
    return MSImageTypeUnkown;
}

@end
