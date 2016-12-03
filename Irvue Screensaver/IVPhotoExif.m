//
//  IVPhotoExif.m
//  Irvue
//
//  Created by Игорь Савельев on 09/02/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "IVPhotoExif.h"
#import "NSArray+Utilities.h"

@implementation IVPhotoExif

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [self init];
	if (self) {
		self.make = [aDecoder decodeObjectForKey:@"make"];
		self.model = [aDecoder decodeObjectForKey:@"model"];
		self.exposureTime = [[aDecoder decodeObjectForKey:@"exposureTime"] doubleValue];
		self.aperture = [[aDecoder decodeObjectForKey:@"aperture"] doubleValue];
		self.focalLength = [[aDecoder decodeObjectForKey:@"focalLength"] doubleValue];
		self.iso = [[aDecoder decodeObjectForKey:@"iso"] unsignedIntegerValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.make forKey:@"make"];
	[aCoder encodeObject:self.model forKey:@"model"];
	[aCoder encodeObject:@(self.exposureTime) forKey:@"exposureTime"];
	[aCoder encodeObject:@(self.aperture) forKey:@"aperture"];
	[aCoder encodeObject:@(self.focalLength) forKey:@"focalLength"];
	[aCoder encodeObject:@(self.iso) forKey:@"iso"];
}

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self updateWithJSON:json];
    }
    return self;
}

- (void)updateWithJSON:(NSDictionary *)json {
    if ([[json objectForKey:@"make"] isKindOfClass:NSString.class]) {
        self.make = [json objectForKey:@"make"];
    }
    if ([[json objectForKey:@"model"] isKindOfClass:NSString.class]) {
        self.model = [json objectForKey:@"model"];
    }
    if ([[json objectForKey:@"exposure_time"] isKindOfClass:NSString.class]) {
        NSString *exposureTime = [json objectForKey:@"exposure_time"];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.exposureTime = [[numberFormatter numberFromString:exposureTime] floatValue];
    } else if ([[json objectForKey:@"exposure_time"] isKindOfClass:NSNumber.class]) {
        self.exposureTime = [[json objectForKey:@"exposure_time"] floatValue];
    }
    if ([[json objectForKey:@"aperture"] isKindOfClass:NSString.class]) {
        NSString *aperture = [json objectForKey:@"aperture"];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.aperture = [[numberFormatter numberFromString:aperture] doubleValue];
    } else if ([[json objectForKey:@"aperture"] isKindOfClass:NSNumber.class]) {
        self.aperture = [[json objectForKey:@"aperture"] doubleValue];
    }
    if ([[json objectForKey:@"focal_length"] isKindOfClass:NSString.class]) {
        NSString *focalLength = [json objectForKey:@"focal_length"];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.focalLength = [[numberFormatter numberFromString:focalLength] doubleValue];
    } else if ([[json objectForKey:@"focal_length"] isKindOfClass:NSNumber.class]) {
        self.focalLength = [[json objectForKey:@"focal_length"] doubleValue];
    }
    if ([[json objectForKey:@"iso"] isKindOfClass:NSNumber.class]) {
        self.iso = [[json objectForKey:@"iso"] unsignedIntegerValue];
    }
}

+ (NSArray *)createObjectsFromJSON:(NSArray *)jsonObjects {
    return [jsonObjects mapWithBlock:^id(id obj) {
        return [[IVPhotoExif alloc] initWithJSON:obj];
    }];
}

- (NSString *)exposureTimeString {
    if (1.0f/self.exposureTime > 1) {
        return [NSString stringWithFormat:@"1/%lds", (long)round(1.0f/self.exposureTime)];
    } else {
        return [NSString stringWithFormat:@"%.2fs", self.exposureTime];
    }
}

@end
