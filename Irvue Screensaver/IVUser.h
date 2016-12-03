//
//  IVUser.h
//  Irvue
//
//  Created by Игорь Савельев on 09/02/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPJSONConvertable.h"

@class IVPhoto, IVCollection;

@interface IVUser : NSObject <LPJSONConvertable, NSCoding>

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSURL *portfolioURL;
@property (nonatomic, strong) NSNumber *downloads;
@property (nonatomic, strong) NSURL *largeProfileImage;
@property (nonatomic, strong) NSURL *mediumProfileImage;
@property (nonatomic, strong) NSURL *smallProfileImage;

@property (nonatomic, strong, readonly) NSURL *webpageURL;

@end
