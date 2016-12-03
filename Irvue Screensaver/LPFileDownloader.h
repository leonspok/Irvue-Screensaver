//
//  LPFileDownloader.h
//  Irvue
//
//  Created by Игорь Савельев on 26/10/15.
//  Copyright © 2015 Leonspok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPFileDownloader : NSObject

+ (instancetype)sharedDownloader;

- (void)downloadFileFromURL:(NSURL *)url
            destinationPath:(NSString *)destinationPath
              progressBlock:(void (^)(double totalBytesDownloaded, double totalBytesExpectedToDownload))progressBlock
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure;

@end
