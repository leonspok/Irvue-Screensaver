//
//  LPImageDownloadManager.m
//  Leonspok
//
//  Created by Игорь Савельев on 28/01/14.
//  Copyright (c) 2014 10tracks. All rights reserved.
//

#import "LPImageDownloadManager.h"
#import "NSString+MD5.h"
#import "LPFileDownloader.h"
#import "NSBezierPath+CGPath.h"
#import "NSImage+Effects.h"
#import "NSArray+Utilities.h"

@implementation LPImageDownloadManager {
    NSCache *imageCache;
    NSOperationQueue *renderOperationQueue;
}

+ (instancetype)defaultManager {
    static LPImageDownloadManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[LPImageDownloadManager alloc] init];
    });
    return manager;
}

- (id)init {
    self = [super init];
    if(self) {
        renderOperationQueue = [[NSOperationQueue alloc] init];
		if ([renderOperationQueue respondsToSelector:@selector(qualityOfService)]) {
			renderOperationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
		}
        renderOperationQueue.name = @"render images operation queue";
        
        imageCache = [[NSCache alloc] init];
        [imageCache setName:@"images"];
        [imageCache setTotalCostLimit:400];
        [imageCache setCountLimit:50];
        
        [self createFolderIfNeeded];
    }
    return self;
}

- (void)clearCache {
	[imageCache removeAllObjects];
	[[NSFileManager defaultManager] removeItemAtPath:self.pathToCacheFolder error:nil];
	[self createFolderIfNeeded];
}

- (void)createFolderIfNeeded {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    self.pathToCacheFolder = [[paths objectAtIndex:0] stringByAppendingPathComponent:NSStringFromClass(self.class)];
    BOOL isDirectory;
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.pathToCacheFolder isDirectory:&isDirectory]) {
        error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.pathToCacheFolder
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            abort();
        }
    } else if (!isDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:self.pathToCacheFolder error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.pathToCacheFolder
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            abort();
        }
    }
}

- (void)clearOldCache {
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.pathToCacheFolder] includingPropertiesForKeys:@[NSURLContentAccessDateKey,NSURLFileSizeKey] options:0 error:&error];
	contents = [contents sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		NSDate *date1, *date2;
		[obj1 getResourceValue:&date1 forKey:NSURLContentAccessDateKey error:nil];
		[obj2 getResourceValue:&date2 forKey:NSURLContentAccessDateKey error:nil];
		if (!date1) {
			[obj1 getResourceValue:&date1 forKey:NSURLContentModificationDateKey error:nil];
		}
		if (!date2) {
			[obj2 getResourceValue:&date2 forKey:NSURLContentModificationDateKey error:nil];
		}
		return [date1 compare:date2];
	}];
	contents = [contents filterWithBlock:^BOOL(id obj) {
		NSDate *date;
		[obj getResourceValue:&date forKey:NSURLContentAccessDateKey error:nil];
		return [date compare:[[NSDate date] dateByAddingTimeInterval:-2*60*60]] == NSOrderedAscending;
	}];
	
	for (NSURL *url in contents) {
		[[NSFileManager defaultManager] removeItemAtURL:url error:nil];
	}
}

- (NSString *)nameForURL:(NSString *)url size:(TTImageSize)size rounded:(BOOL)rounded {
    NSString *postFix = @"";
    switch (size) {
        case TTImageSizeOriginal:
            postFix = @"";
            break;
        case TTImageSize50px:
            postFix = @"50px";
            break;
        case TTImageSize100px:
            postFix = @"100px";
            break;
        case TTImageSize300px:
            postFix = @"300px";
            break;
        case TTImageSize500px:
            postFix = @"500px";
            break;
        case TTImageSize800px:
            postFix = @"800px";
            break;
            
        default:
            break;
    }
    
    NSString *name = [NSString stringWithFormat:@"%@%@%@.png", [url MD5String], postFix, rounded? @"rounded":@""];
    return name;
}

- (NSURL *)urlToDownloadedImageFromURL:(NSString *)url
                                  size:(TTImageSize)size
                               rounded:(BOOL)rounded {
    NSString *fileName = [self nameForURL:url size:size rounded:rounded];
    NSString *imagePath = [self.pathToCacheFolder stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return nil;
    }
    
    return [[NSURL alloc] initFileURLWithPath:imagePath];
}

- (NSImage *)renderImage:(NSImage *)image toSize:(NSSize)size rounded:(BOOL)rounded {
	return [image resizeWithAspectFillToSize:size rounded:rounded];
}

- (NSImage *)getImageForURL:(NSString *)url
                       size:(TTImageSize)size
                    rounded:(BOOL)rounded {
    NSString *fileName = [self nameForURL:url size:size rounded:rounded];
    NSString *imagePath = [self.pathToCacheFolder stringByAppendingPathComponent:fileName];
    
    NSImage *image;
    if ([imageCache objectForKey:fileName]) {
        image = [imageCache objectForKey:fileName];
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        image = [[NSImage alloc] initWithContentsOfFile:imagePath];
        if (image) {
            [imageCache setObject:image forKey:fileName];
        }
    }
    if (!image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if ([imageCache objectForKey:fileName]) {
                [imageCache removeObjectForKey:fileName];
            } else if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
            }
        });
        return nil;
    }
    return image;
}

- (NSImage *)processImage:(NSImage *)source size:(TTImageSize)size rounded:(BOOL)rounded cost:(NSUInteger *)c {
    NSImage *renderedImage;
    NSUInteger cost = 0;
    switch (size) {
        case TTImageSize50px:
            renderedImage = [self renderImage:source toSize:NSMakeSize(50, 50) rounded:rounded];
            cost = 1;
            break;
        case TTImageSize100px:
            renderedImage = [self renderImage:source toSize:NSMakeSize(100, 100) rounded:rounded];
            cost = 1;
            break;
        case TTImageSize300px:
            renderedImage = [self renderImage:source toSize:NSMakeSize(300, 300) rounded:rounded];
            cost = 9;
            break;
        case TTImageSize500px:
            renderedImage = [self renderImage:source toSize:NSMakeSize(500, 500) rounded:rounded];
            cost = 25;
            break;
        case TTImageSize800px:
            renderedImage = [self renderImage:source toSize:NSMakeSize(800, 800) rounded:rounded];
            cost = 64;
            break;
        case TTImageSizeOriginal:
            if (rounded) {
                renderedImage = [self renderImage:source toSize:source.size rounded:YES];
                cost = 100;
            }
            break;
            
        default:
            break;
    }
    *c = cost;
    return renderedImage;
}

- (void)getImageForURL:(NSString *)url
                  size:(TTImageSize)size
               rounded:(BOOL)rounded
            completion:(void (^)(NSImage *image))completion {
    if (!url || url.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil);
            }
        });
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fileName = [self nameForURL:url size:size rounded:rounded];
        NSString *imagePath = [self.pathToCacheFolder stringByAppendingPathComponent:fileName];
        
        if ([imageCache objectForKey:fileName]) {
            NSImage *image = [imageCache objectForKey:fileName];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(image);
                }
            });
        } else if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(image);
                }
            });
        } else {
            NSImage *image;
            NSUInteger cost = 0;
            if ([self hasImageForURL:url size:TTImageSizeOriginal]) {
                image = [self getImageForURL:url size:TTImageSizeOriginal];
                cost = 100;
            }
            for (TTImageSize s = size; s <= TTImageSize800px; s++) {
                if ([self hasImageForURL:url size:s]) {
                    image = [self getImageForURL:url size:s];
                    cost = 64;
                    break;
                }
            }
            
            if (image && (size != TTImageSizeOriginal || rounded)) {
                [renderOperationQueue addOperationWithBlock:^{
                    NSUInteger cost;
                    NSImage *renderedImage = [self processImage:image size:size rounded:rounded cost:&cost];
                    
                    if (renderedImage) {
                        if (fileName) {
                            [imageCache setObject:renderedImage forKey:fileName cost:cost];
                        }
						NSData *imageData = [[renderedImage bitmapImageRepresentation] representationUsingType:NSPNGFileType properties:@{}];
                        [imageData writeToFile:imagePath atomically:YES];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(renderedImage);
                        }
                    });
                }];
                return;
            }
            
            NSString *originalFileName = [self nameForURL:url size:TTImageSizeOriginal rounded:NO];
            NSString *originalImagePath = [self.pathToCacheFolder stringByAppendingPathComponent:originalFileName];
            [[LPFileDownloader sharedDownloader] downloadFileFromURL:[NSURL URLWithString:url] destinationPath:originalImagePath progressBlock:nil success:^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSImage *image = [[NSImage alloc] initWithContentsOfFile:originalImagePath];
                    if (image) {
                        [imageCache setObject:image forKey:originalFileName cost:100];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(nil);
                            }
                        });
                        return;
                    }
                    
                    if (size != TTImageSizeOriginal || rounded) {
                        [renderOperationQueue addOperationWithBlock:^{
                            NSUInteger cost;
                            NSImage *renderedImage = [self processImage:image size:size rounded:rounded cost:&cost];
                            
                            if (renderedImage) {
                                if (fileName) {
                                    [imageCache setObject:renderedImage forKey:fileName cost:cost];
                                }
								NSData *imageData = [[renderedImage bitmapImageRepresentation] representationUsingType:NSPNGFileType properties:@{}];
								[imageData writeToFile:imagePath atomically:YES];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (completion) {
                                    completion(renderedImage);
                                }
                            });
                        }];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(image);
                            }
                        });
                    }
                });
            } failure:^(NSError *error) {
                NSLog(@"ERROR DOWNLOADING IMAGE: %@", [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil);
                    }
                });
            }];
        }
    });
}

- (BOOL)hasImageForURL:(NSString *)url
                  size:(TTImageSize)size
               rounded:(BOOL)rounded {
    
    if (!url || url == (id)[NSNull null]) {
        return NO;
    }
    
    NSString *fileName = [self nameForURL:url size:size rounded:rounded];
    NSString *imagePath = [self.pathToCacheFolder stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return NO;
    }
    
    return YES;
}

- (NSImage *)getImageForURL:(NSString *)url size:(TTImageSize)size {
    return [self getImageForURL:url size:size rounded:NO];
}

- (void)getImageForURL:(NSString *)url size:(TTImageSize)size completion:(void (^)(NSImage *))completion {
    [self getImageForURL:url size:size rounded:NO completion:completion];
}

- (BOOL)hasImageForURL:(NSString *)url size:(TTImageSize)size {
    return [self hasImageForURL:url size:size rounded:NO];
}

- (NSImage *)getImageForURL:(NSString *)url {
    return [self getImageForURL:url size:TTImageSizeOriginal];
}

- (void)getImageForURL:(NSString *)url completion:(void (^)(NSImage *image))completion {
    [self getImageForURL:url size:TTImageSizeOriginal completion:completion];
}

- (BOOL)hasImageForURL:(NSString *)url {
    return [self hasImageForURL:url size:TTImageSizeOriginal];
}

@end

