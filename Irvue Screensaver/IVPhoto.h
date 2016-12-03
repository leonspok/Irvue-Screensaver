//
//  IVPhoto.h
//  Irvue
//
//  Created by Игорь Савельев on 09/02/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPJSONConvertable.h"

@class IVPhotoCategory, IVPhotoExif, IVPhotoLocation, IVUser, IVCollection;

@interface IVPhoto : NSObject <LPJSONConvertable, NSCoding>

@property (nonatomic, strong) NSString *uid;
@property (nonatomic) NSSize size;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSURL *fullImageURL;
@property (nonatomic, strong) NSURL *regularImageURL;
@property (nonatomic, strong) NSURL *smallImageURL;
@property (nonatomic, strong) NSURL *thumbImageURL;
@property (nonatomic, strong) NSNumber *downloads;
@property (nonatomic, strong) NSNumber *likes;
@property (nonatomic, strong) IVPhotoExif *exif;
@property (nonatomic, strong) IVPhotoLocation *location;
@property (nonatomic, strong) IVUser *author;

@property (nonatomic, strong, readonly) NSURL *webpageURL;
@property (nonatomic, strong, readonly) NSURL *imageURLForDownload;

- (NSURL *)imageURLForSize:(NSSize)size;

@end
