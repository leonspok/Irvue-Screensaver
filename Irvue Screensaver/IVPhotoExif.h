//
//  IVPhotoExif.h
//  Irvue
//
//  Created by Игорь Савельев on 09/02/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPJSONConvertable.h"

@class IVPhoto;

@interface IVPhotoExif : NSObject <LPJSONConvertable, NSCoding>

@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;
@property (nonatomic) NSTimeInterval exposureTime;
@property (nonatomic, strong, readonly) NSString *exposureTimeString;
@property (nonatomic) double aperture;
@property (nonatomic) double focalLength;
@property (nonatomic) NSUInteger iso;

@end
