//
//  IVPhotoLocation.h
//  Irvue
//
//  Created by Игорь Савельев on 09/02/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPJSONConvertable.h"

@import CoreLocation;

@class IVPhoto;

@interface IVPhotoLocation : NSObject <LPJSONConvertable, NSCoding>

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;

@end
