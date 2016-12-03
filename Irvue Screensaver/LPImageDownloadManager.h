//
//  LPImageDownloadManager.h
//  Leonspok
//
//  Created by Игорь Савельев on 28/01/14.
//  Copyright (c) 2014 10tracks. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AppKit;

typedef enum {
    TTImageSizeOriginal,
    TTImageSize800px,
    TTImageSize500px,
    TTImageSize300px,
    TTImageSize100px,
    TTImageSize50px
} TTImageSize;

@interface LPImageDownloadManager : NSObject

@property (nonatomic, strong) NSString *pathToCacheFolder;

+ (instancetype)defaultManager;

- (void)clearCache;
- (void)clearOldCache;

- (NSURL *)urlToDownloadedImageFromURL:(NSString *)url
                                  size:(TTImageSize)size
                               rounded:(BOOL)rounded;

- (NSImage *)getImageForURL:(NSString *)url
                       size:(TTImageSize)size
                    rounded:(BOOL)rounded;
- (void)getImageForURL:(NSString *)url
                  size:(TTImageSize)size
               rounded:(BOOL)rounded
            completion:(void (^)(NSImage *image))completion;
- (BOOL)hasImageForURL:(NSString *)url
                  size:(TTImageSize)size
               rounded:(BOOL)rounded;

- (NSImage *)getImageForURL:(NSString *)url
                       size:(TTImageSize)size;
- (void)getImageForURL:(NSString *)url
                  size:(TTImageSize)size
            completion:(void (^)(NSImage *image))completion;
- (BOOL)hasImageForURL:(NSString *)url
                  size:(TTImageSize)size;

- (NSImage *)getImageForURL:(NSString *)url;
- (void)getImageForURL:(NSString *)url
            completion:(void (^)(NSImage *image))completion;
- (BOOL)hasImageForURL:(NSString *)url;

@end
