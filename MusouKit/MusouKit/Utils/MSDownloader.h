//
//  MSDownloader.h
//  VGirl
//
//  Created by danal.luo on 2/26/14.
//  Copyright (c) 2014 danal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSTaskQueue.h"

@protocol MSDownloaderDelegate;
@interface MSDownloader : MSTask
@property (assign, nonatomic) id<MSDownloaderDelegate> delegate;
@property (copy, nonatomic) NSString *url;
@property (assign, nonatomic) NSInteger mark;
/** Request headers */
@property (strong, nonatomic) NSDictionary *headers;
/** Download directory path */
@property (copy, nonatomic) NSString *downloadDir;
/** Download filename */
@property (copy, nonatomic) NSString *downloadFilename;
@property (nonatomic) BOOL loading;


- (id)initWithUrl:(NSString *)httpUrl;

- (void)start;
- (void)cancel;

/**
 * The Received data
 */
- (NSData *)data;

/** The download file path */
- (NSString *)filePath;

/**
 * @param httpUrl The url to request
 * @param downloadDir The directory for saving files,Pass nil to use the default value
 * @return The data if has downloaded, else nil
 */
+ (NSData *)dataHasDownloaded:(NSString *)httpUrl inDir:(NSString *)downloadDir;
+ (NSData *)dataHasDownloaded:(NSString *)httpUrl;

+ (NSString *)cachedFilePath:(NSString *)httpUrl;

/** Clear the downloaded data */
+ (void)clearCaches:(void (^)(void))complete inDir:(NSString *)directory;
+ (void)clearCaches:(void(^)(void))complete;

@end

@protocol MSDownloaderDelegate <NSObject>
@optional
- (void)onDownloaderStart:(MSDownloader *)dl;
- (void)onDownloaderFinish:(MSDownloader *)dl error:(NSError *)error;
- (void)onDownloaderProgressUpdate:(MSDownloader *)dl progress:(float)progress;
@end