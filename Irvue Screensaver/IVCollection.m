//
//  IVCollection.m
//  Irvue
//
//  Created by Игорь Савельев on 12/07/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "IVCollection.h"
#import "NSArray+Utilities.h"
#import "IVPhoto.h"
#import "IVUser.h"
#import "LPUnsplashAPI.h"

@implementation IVCollection

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self updateWithJSON:json];
    }
    return self;
}

- (void)updateWithJSON:(NSDictionary *)json {
    if ([[json objectForKey:@"id"] isKindOfClass:NSNumber.class]) {
        self.uid = [json objectForKey:@"id"];
    }
    if ([[json objectForKey:@"title"] isKindOfClass:NSString.class]) {
        self.title = [json objectForKey:@"title"];
    }
    if ([[json objectForKey:@"description"] isKindOfClass:NSString.class]) {
        self.collectionDescription = [json objectForKey:@"description"];
    }
    if ([[json objectForKey:@"published_at"] isKindOfClass:NSString.class]) {
        NSString *publishedAtString = [json objectForKey:@"published_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssXXX"];
        self.publishedAt = [formatter dateFromString:publishedAtString];
    }
    if ([[json objectForKey:@"total_photos"] isKindOfClass:NSNumber.class]) {
        self.totalPhotos = [json objectForKey:@"total_photos"];
    }
    if ([[json objectForKey:@"curated"] isKindOfClass:NSNumber.class]) {
        self.curated = [[json objectForKey:@"curated"] boolValue];
    }
    if ([[json objectForKey:@"cover_photo"] isKindOfClass:NSDictionary.class]) {
        self.coverPhoto = [[IVPhoto alloc] initWithJSON:[json objectForKey:@"cover_photo"]];
    }
    if ([[json objectForKey:@"user"] isKindOfClass:NSDictionary.class]) {
        self.user = [[IVUser alloc] initWithJSON:[json objectForKey:@"user"]];
    }
}

+ (NSArray *)createObjectsFromJSON:(NSArray *)jsonObjects {
    return [jsonObjects mapWithBlock:^id(id obj) {
        return [[IVCollection alloc] initWithJSON:obj];
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
        IVUser *user = (IVUser *)object;
        return [user.uid isEqual:self.uid];
    }
    return NO;
}

@end
