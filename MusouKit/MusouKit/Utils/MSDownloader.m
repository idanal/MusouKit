//
//  MSDownloader.m
//  VGirl
//
//  Created by danal.luo on 2/26/14.
//  Copyright (c) 2014 danal. All rights reserved.
//

#import "MSDownloader.h"

#define kDownloadPath [NSString stringWithFormat:@"%@/Library/Caches/Downloads",NSHomeDirectory()]

@interface MSDownloader ()<NSURLConnectionDelegate>
{
    int _activityCounter;
    long long _expectedLength;
}
@property (strong,nonatomic) NSMutableData *recvData;
@property (strong,nonatomic) NSURLConnection *conn;
@end

@implementation MSDownloader

- (void)dealloc{
#if !__has_feature(objc_arc)
    self.headers = nil;
    self.recvData = nil;
    self.conn = nil;
    self.url = nil;
    self.downloadDir = nil;
    self.downloadFilename = nil;
    [super dealloc];
#endif
}

- (id)init{
    self = [super init];
    if (self){
        if (![[NSFileManager defaultManager] fileExistsAtPath:kDownloadPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:kDownloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        self.downloadDir = kDownloadPath;
    }
    return self;
}

- (id)initWithUrl:(NSString *)httpUrl{
    self = [self init];
    if (self){
        self.url = httpUrl;
    }
    return self;
}

- (void)start{
    if (!self.url){
        NSLog(@"-------Downloader Url is nil-------");
        if (_delegate){
            NSError *err = [NSError errorWithDomain:NSURLErrorDomain code:-1000 userInfo:nil];
            [_delegate onDownloaderFinish:self error:err];
        }
        return;
    }
    if (self.loading) return;

        NSURL *URL = [NSURL URLWithString:_url];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.f];
        for (NSString *key in _headers){
            [req setValue:_headers[key] forHTTPHeaderField:key];
        }
        self.conn = [NSURLConnection connectionWithRequest:req delegate:self];
        self.loading = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onDownloaderStart:)]){
        [_delegate onDownloaderStart:self];
    }
    
    [super start];
}

- (void)cancel{
    [self.conn cancel];
    self.conn = nil;
    self.recvData = nil;
    [super cancel];
}

- (NSData *)data{
    return _recvData;
}

- (NSString *)filePath{
    return [self _fullCacheName];
}

- (NSString *)_cacheName{
    return _downloadFilename != nil ? _downloadFilename : [[self class] cacheNameForUrl:self.url];
}

- (NSString *)_fullCacheName{
    return [NSString stringWithFormat:@"%@/%@",self.downloadDir,[self _cacheName]];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    _activityCounter--;
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:_activityCounter > 0];
    if (_delegate){
        [_delegate onDownloaderFinish:self error:error];
    }
#ifdef DEBUG
    NSLog(@"%@",error.description);
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _activityCounter++;
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.loading = YES;
    self.recvData = [NSMutableData data];
    _expectedLength = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.recvData appendData:data];
    float progress = [self.recvData length]*1.f/_expectedLength;
    if (_delegate && [_delegate respondsToSelector:@selector(onDownloaderProgressUpdate:progress:)]) {
        [_delegate onDownloaderProgressUpdate:self progress:progress];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    _activityCounter--;
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:_activityCounter > 0];
    
    NSString *file = [self _fullCacheName];
    NSString *path = [file stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    [self.recvData writeToFile:file atomically:YES];
    
    if (_delegate){
        [_delegate onDownloaderFinish:self error:nil];
    }
    
    self.conn = nil;
    self.recvData = nil;
    self.loading = NO;
    [self onFinish];
}

#pragma mark -
+ (void)clearCaches:(void (^)(void))complete inDir:(NSString *)directory{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *path = directory != nil ? directory : kDownloadPath ;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *subpaths = [fm subpathsAtPath:path];
        for (NSString *f in subpaths) {
            [fm removeItemAtPath:[path stringByAppendingPathComponent:f] error:nil];
        }
        dispatch_sync(dispatch_get_main_queue(), complete);
    });
}

+ (void)clearCaches:(void (^)(void))complete{
    [self clearCaches:complete inDir:nil];
}

+ (NSData *)dataHasDownloaded:(NSString *)httpUrl inDir:(NSString *)downloadDir{
    NSString *path = downloadDir != nil ? downloadDir : kDownloadPath;
    NSString *file = [path stringByAppendingFormat:@"/%@",[self cacheNameForUrl:httpUrl]];
    return [NSData dataWithContentsOfFile:file];
}

+ (NSData *)dataHasDownloaded:(NSString *)httpUrl{
    return [self dataHasDownloaded:httpUrl inDir:kDownloadPath];
}

+ (NSString *)cachedFilePath:(NSString *)httpUrl{
    NSString *file = [kDownloadPath stringByAppendingFormat:@"/%@",[self cacheNameForUrl:httpUrl]];
    return file;
}

+ (NSString *)cacheNameForUrl:(NSString *)url{
    if ([url length] < 7) {
        return nil;
    }
    url = [url substringFromIndex:7];    //Remove http://
    NSRange range = [url rangeOfString:@"/"];
    if (range.length < 1) {
        return nil;
    }
    NSString *fileName = [url substringFromIndex:range.location];   //Remove domain
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/|\\?|\\*" withString:@"_" options:NSRegularExpressionSearch range:NSMakeRange(0, fileName.length)];
    return fileName;
}

+ (NSString *)thumbnailCacheNameForUrl:(NSString *)url{
    NSString *fileName = [[self class] cacheNameForUrl:url];
    NSString *extension = [fileName pathExtension];
    fileName = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", extension]
                                                   withString:[NSString stringWithFormat:@"_thumb.%@",extension]];
    return fileName;
}


@end
