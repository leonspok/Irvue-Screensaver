//
//  IVPhoto.m
//  Irvue
//
//  Created by Игорь Савельев on 09/02/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "IVPhoto.h"
#import "IVPhotoExif.h"
#import "IVPhotoLocation.h"
#import "IVUser.h"
#import "NSArray+Utilities.h"
#import "NSDictionary+NSURL.h"
#import "LPUnsplashAPI.h"

@interface IVPhoto()
@property (nonatomic, readwrite) BOOL placeholder;
@end

@implementation IVPhoto

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [self init];
	if (self) {
		self.uid = [aDecoder decodeObjectForKey:@"uid"];
		self.fullImageURL = [aDecoder decodeObjectForKey:@"fullImageURL"];
		self.regularImageURL = [aDecoder decodeObjectForKey:@"regularImageURL"];
		self.smallImageURL = [aDecoder decodeObjectForKey:@"smalleImageURL"];
		self.thumbImageURL = [aDecoder decodeObjectForKey:@"thumbImageURL"];
		self.exif = [aDecoder decodeObjectForKey:@"exif"];
		self.location = [aDecoder decodeObjectForKey:@"location"];
		self.author = [aDecoder decodeObjectForKey:@"author"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.uid forKey:@"uid"];
	[aCoder encodeObject:self.fullImageURL forKey:@"fullImageURL"];
	[aCoder encodeObject:self.regularImageURL forKey:@"regularImageURL"];
	[aCoder encodeObject:self.smallImageURL forKey:@"smallImageURL"];
	[aCoder encodeObject:self.thumbImageURL forKey:@"thumbImageURL"];
	[aCoder encodeObject:self.exif forKey:@"exif"];
	[aCoder encodeObject:self.location forKey:@"location"];
	[aCoder encodeObject:self.author forKey:@"author"];
}

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self updateWithJSON:json];
    }
    return self;
}

- (void)updateWithJSON:(NSDictionary *)json {
    if ([[json objectForKey:@"id"] isKindOfClass:NSString.class]) {
        self.uid = [json objectForKey:@"id"];
    }
    if ([[json objectForKey:@"width"] isKindOfClass:NSNumber.class] && [[json objectForKey:@"height"] isKindOfClass:NSNumber.class]) {
        NSNumber *width = [json objectForKey:@"width"];
        NSNumber *height = [json objectForKey:@"height"];
        self.size = NSMakeSize(width.floatValue, height.floatValue);
    }
    if ([[json objectForKey:@"color"] isKindOfClass:NSString.class]) {
        self.color = [json objectForKey:@"color"];
    }
    if ([[json objectForKey:@"urls"] isKindOfClass:NSDictionary.class]) {
        NSDictionary *imageURLs = [json objectForKey:@"urls"];
        if ([imageURLs objectForKey:@"full"]) {
            self.fullImageURL = [NSURL URLWithString:[imageURLs objectForKey:@"full"]];
        }
        if ([imageURLs objectForKey:@"regular"]) {
            self.regularImageURL = [NSURL URLWithString:[imageURLs objectForKey:@"regular"]];
        }
        if ([imageURLs objectForKey:@"small"]) {
            self.smallImageURL = [NSURL URLWithString:[imageURLs objectForKey:@"small"]];
        }
        if ([imageURLs objectForKey:@"thumb"]) {
            self.thumbImageURL = [NSURL URLWithString:[imageURLs objectForKey:@"thumb"]];
        }
    }
    if ([[json objectForKey:@"downloads"] isKindOfClass:NSNumber.class]) {
        self.downloads = [json objectForKey:@"downloads"];
    }
    if ([[json objectForKey:@"likes"] isKindOfClass:NSNumber.class]) {
        self.likes = [json objectForKey:@"likes"];
    }
    if ([[json objectForKey:@"exif"] isKindOfClass:NSDictionary.class]) {
        self.exif = [[IVPhotoExif alloc] initWithJSON:[json objectForKey:@"exif"]];
    }
    if ([[json objectForKey:@"location"] isKindOfClass:NSDictionary.class]) {
        self.location = [[IVPhotoLocation alloc] initWithJSON:[json objectForKey:@"location"]];
    }
    if ([[json objectForKey:@"user"] isKindOfClass:NSDictionary.class]) {
        self.author = [[IVUser alloc] initWithJSON:[json objectForKey:@"user"]];
    }
}

+ (NSArray *)createObjectsFromJSON:(NSArray *)jsonObjects {
    return [jsonObjects mapWithBlock:^id(id obj) {
        return [[IVPhoto alloc] initWithJSON:obj];
    }];
}

- (NSUInteger)hash {
    return self.uid.hash;
}

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (object == self) {
        return YES;
    }
    if ([object class] == self.class) {
        IVPhoto *photo = (IVPhoto *)object;
        return [photo.uid isEqual:self.uid];
    }
    return NO;
}

- (NSURL *)imageURLForSize:(NSSize)size {
    NSString *urlString = [self.fullImageURL absoluteString];
    NSMutableDictionary *params = [[NSDictionary dictionaryWithURL:self.fullImageURL] mutableCopy];
	if (!NSEqualSizes(self.size, NSZeroSize)) {
		CGFloat sourceRatio = self.size.width/self.size.height;
		CGFloat targetRatio = size.width/size.height;
		if (sourceRatio > targetRatio) {
			NSString *height = [NSString stringWithFormat:@"%ld", (long)size.height];
			[params setObject:height forKey:@"h"];
		} else {
			NSString *width = [NSString stringWithFormat:@"%ld", (long)size.width];
			[params setObject:width forKey:@"w"];
		}
	} else {
		NSString *width = [NSString stringWithFormat:@"%ld", (long)size.width];
		[params setObject:width forKey:@"w"];
	}
    [params setObject:@"jpg" forKey:@"fm"];
    [params setObject:@"90" forKey:@"q"];
    [params setObject:@"entropy" forKey:@"crop"];
    [params setObject:@"max" forKey:@"fit"];
    NSURL *url = [params urlWithBase:[urlString substringWithRange:NSMakeRange(0, [urlString rangeOfString:@"?"].location != NSNotFound? [urlString rangeOfString:@"?"].location : urlString.length)]];
    return url;
}

#pragma mark Placeholder

+ (instancetype)placeholderPhoto {
	IVPhoto *photo = [IVPhoto new];
	photo.uid = @"YadCgbsLHcE";
	photo.placeholder = YES;
	IVUser *user = [IVUser new];
	user.username = @"willpower";
	user.name = @"William Stitt";
	photo.author = user;
	return photo;
}

@end
