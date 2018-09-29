//
//  LPFileDownloader.m
//  Irvue
//
//  Created by Игорь Савельев on 26/10/15.
//  Copyright © 2015 Leonspok. All rights reserved.
//

#import "LPFileDownloader.h"

@interface LPFileDownloader()<NSURLSessionDownloadDelegate>
@property(nonatomic, strong) NSMutableDictionary *successBlocks;
@property(nonatomic, strong) NSMutableDictionary *failureBlocks;
@property(nonatomic, strong) NSMutableDictionary *progressBlocks;
@property(nonatomic, strong) NSMutableDictionary *destinationPaths;
@end

@implementation LPFileDownloader {
    NSOperationQueue *sessionQueue;
    NSURLSession *session;
}

+ (instancetype)sharedDownloader {
    static LPFileDownloader *__sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedDownloader = [[LPFileDownloader alloc] init];
    });
    return __sharedDownloader;
}

- (id)init {
    self = [super init];
    if (self) {
        sessionQueue = [[NSOperationQueue alloc] init];
		if ([sessionQueue respondsToSelector:@selector(qualityOfService)]) {
			sessionQueue.qualityOfService = NSQualityOfServiceUserInitiated;
		}
        sessionQueue.name = NSStringFromClass(self.class);
        
        self.successBlocks = [NSMutableDictionary dictionary];
        self.failureBlocks = [NSMutableDictionary dictionary];
        self.progressBlocks = [NSMutableDictionary dictionary];
        self.destinationPaths = [NSMutableDictionary dictionary];
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:sessionQueue];
    }
    return self;
}

- (void)downloadFileFromURL:(NSURL *)url
            destinationPath:(NSString *)destinationPath
              progressBlock:(void (^)(double totalBytesDownloaded, double totalBytesExpectedToDownload))progress
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure {
    if (!url) {
        if (failure) {
            failure([NSError errorWithDomain:NSStringFromClass(self.class) code:1 userInfo:@{@"message": @"no url"}]);
        }
        return;
    }
    
    if (!destinationPath || destinationPath.length == 0) {
        if (failure) {
            failure([NSError errorWithDomain:NSStringFromClass(self.class) code:1 userInfo:@{@"message": @"no destinationPath"}]);
        }
        return;
    }
    
    void (^successBlock)() = ^{
        if (success) {
            success();
        }
    };
    
    void (^failureBlock)(NSError *error) = ^(NSError *error) {
        if (failure) {
            failure(error);
        }
    };
    
    void (^progressBlock)(double, double) = ^(double totalBytesDownloaded, double totalBytesExpectedToDownload) {
        if (progress) {
            progress(totalBytesDownloaded, totalBytesExpectedToDownload);
        }
    };
    
    BOOL shouldDownload = NO;
    
    @synchronized(self) {
        if ([self.successBlocks objectForKey:url] &&
            [self.failureBlocks objectForKey:url] &&
            [self.progressBlocks objectForKey:url] &&
            [self.destinationPaths objectForKey:url]) {
            NSMutableArray *successBlocksForURL = [self.successBlocks objectForKey:url];
            [successBlocksForURL addObject:successBlock];
            
            NSMutableArray *failureBlocksForURL = [self.failureBlocks objectForKey:url];
            [failureBlocksForURL addObject:failureBlock];
            
            NSMutableArray *progressBlocksForURL = [self.progressBlocks objectForKey:url];
            [progressBlocksForURL addObject:progressBlock];
            
            NSMutableArray *destinationPathsForURL = [self.destinationPaths objectForKey:url];
            [destinationPathsForURL addObject:destinationPath];
        } else {
            NSMutableArray *successBlocksForURL = [NSMutableArray array];
            [successBlocksForURL addObject:successBlock];
            [self.successBlocks setObject:successBlocksForURL forKey:url];
            
            NSMutableArray *failureBlocksForURL = [NSMutableArray array];
            [failureBlocksForURL addObject:failureBlock];
            [self.failureBlocks setObject:failureBlocksForURL forKey:url];
            
            NSMutableArray *progressBlocksForURL = [NSMutableArray array];
            [progressBlocksForURL addObject:progressBlock];
            [self.progressBlocks setObject:progressBlocksForURL forKey:url];
            
            NSMutableArray *destinationPathsForURL = [NSMutableArray array];
            [destinationPathsForURL addObject:destinationPath];
            [self.destinationPaths setObject:destinationPathsForURL forKey:url];
            
            shouldDownload = YES;
        }
    }
    
    if (shouldDownload) {
        [[session downloadTaskWithURL:url] resume];
    }
}

#pragma mark NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSError *error = downloadTask.error;
    NSURL *url = downloadTask.originalRequest.URL;
    
    NSArray *destinationPathsForURL;
    NSArray *failureBlocks;
    NSArray *successBlocks;
    @synchronized(self) {
        destinationPathsForURL = [NSArray arrayWithArray:[self.destinationPaths objectForKey:url]];
        failureBlocks = [NSArray arrayWithArray:[self.failureBlocks objectForKey:url]];
        successBlocks = [NSArray arrayWithArray:[self.successBlocks objectForKey:url]];
        
        [self.successBlocks removeObjectForKey:url];
        [self.failureBlocks removeObjectForKey:url];
        [self.progressBlocks removeObjectForKey:url];
        [self.destinationPaths removeObjectForKey:url];
    }
    
    if (error) {
        for (void (^block)(NSError *error) in failureBlocks) {
            block(error);
        }
    } else {
        NSError *error;
        for (NSString *path in destinationPathsForURL) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:&error];
        }
        [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
        if (error) {
            for (void (^block)(NSError *error) in failureBlocks) {
                block(error);
            }
        } else {
            for (void (^block)() in successBlocks) {
                block();
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSArray *blocks;
    @synchronized(self) {
        blocks = [NSArray arrayWithArray:[self.progressBlocks objectForKey:downloadTask.originalRequest.URL]];
    }
    
    for (void (^block)(double totalBytesDownloaded, double totalBytesExpectedToDownload) in blocks) {
        block((double)totalBytesWritten, (double)totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSURL *url = task.originalRequest.URL;
    
    NSArray *failureBlocks;
    @synchronized(self) {
        failureBlocks = [NSArray arrayWithArray:[self.failureBlocks objectForKey:url]];
        [self.successBlocks removeObjectForKey:url];
        [self.failureBlocks removeObjectForKey:url];
        [self.progressBlocks removeObjectForKey:url];
        [self.destinationPaths removeObjectForKey:url];
    }
    
    if (error) {
        for (void (^block)(NSError *error) in failureBlocks) {
            block(error);
        }
    }
}

@end
