//
//  IVCollection.h
//  Irvue
//
//  Created by Игорь Савельев on 12/07/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPJSONConvertable.h"

@class IVPhoto, IVUser;

@interface IVCollection : NSObject <LPJSONConvertable>

@property (nonatomic, strong) NSNumber *uid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *collectionDescription;
@property (nonatomic, strong) NSDate *publishedAt;
@property (nonatomic, strong) NSNumber *totalPhotos;
@property (nonatomic, strong) IVPhoto *coverPhoto;
@property (nonatomic, strong) IVUser *user;
@property (nonatomic) BOOL curated;

@property (nonatomic, strong, readonly) NSURL *webpageURL;

@end
