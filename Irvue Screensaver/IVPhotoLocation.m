//
//  IVPhotoLocation.m
//  Irvue
//
//  Created by Игорь Савельев on 09/02/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "IVPhotoLocation.h"
#import "NSArray+Utilities.h"

@implementation IVPhotoLocation

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [self init];
	if (self) {
		self.city = [aDecoder decodeObjectForKey:@"city"];
		self.country = [aDecoder decodeObjectForKey:@"country"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.city forKey:@"city"];
	[aCoder encodeObject:self.country forKey:@"country"];
}

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self updateWithJSON:json];
    }
    return self;
}

- (void)updateWithJSON:(NSDictionary *)json {
    if ([[json objectForKey:@"city"] isKindOfClass:NSString.class]) {
        self.city = [json objectForKey:@"city"];
    }
    if ([[json objectForKey:@"country"] isKindOfClass:NSString.class]) {
        self.country = [json objectForKey:@"country"];
    }
}

+ (NSArray *)createObjectsFromJSON:(NSArray *)jsonObjects {
    return [jsonObjects mapWithBlock:^id(id obj) {
        return [[IVPhotoLocation alloc] initWithJSON:obj];
    }];
}

@end
