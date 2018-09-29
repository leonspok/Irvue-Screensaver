//
//  IVUser.m
//  Irvue
//
//  Created by Игорь Савельев on 09/02/16.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "IVUser.h"
#import "NSArray+Utilities.h"
#import "LPUnsplashAPI.h"

@implementation IVUser

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [self init];
	if (self) {
		self.uid = [aDecoder decodeObjectForKey:@"uid"];
		self.username = [aDecoder decodeObjectForKey:@"username"];
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
		self.lastName = [aDecoder decodeObjectForKey:@"lastName"];
		self.portfolioURL = [aDecoder decodeObjectForKey:@"portfolioURL"];
		self.smallProfileImage = [aDecoder decodeObjectForKey:@"smallProfileImage"];
		self.mediumProfileImage = [aDecoder decodeObjectForKey:@"mediumProfileImage"];
		self.largeProfileImage = [aDecoder decodeObjectForKey:@"largeProfileImage"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.uid forKey:@"uid"];
	[aCoder encodeObject:self.username forKey:@"username"];
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeObject:self.firstName forKey:@"firstName"];
	[aCoder encodeObject:self.lastName forKey:@"lastName"];
	[aCoder encodeObject:self.portfolioURL forKey:@"portfolioURL"];
	[aCoder encodeObject:self.smallProfileImage forKey:@"smallProfileImage"];
	[aCoder encodeObject:self.mediumProfileImage forKey:@"mediumProfileImage"];
	[aCoder encodeObject:self.largeProfileImage forKey:@"largetProfileImage"];
}

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
    if ([[json objectForKey:@"username"] isKindOfClass:NSString.class]) {
        self.username = [json objectForKey:@"username"];
    }
    if ([[json objectForKey:@"name"] isKindOfClass:NSString.class]) {
        self.name = [json objectForKey:@"name"];
    }
    if ([[json objectForKey:@"first_name"] isKindOfClass:NSString.class]) {
        self.firstName = [json objectForKey:@"first_name"];
    }
    if ([[json objectForKey:@"last_name"] isKindOfClass:NSString.class]) {
        self.lastName = [json objectForKey:@"last_name"];
    }
    if ([[json objectForKey:@"portfolio_url"] isKindOfClass:NSString.class]) {
        self.portfolioURL = [NSURL URLWithString:[json objectForKey:@"portfolio_url"]];
    }
    if ([[json objectForKey:@"downloads"] isKindOfClass:NSNumber.class]) {
        self.downloads = [json objectForKey:@"downloads"];
    }
    if ([[json objectForKey:@"profile_image"] isKindOfClass:NSDictionary.class]) {
        NSDictionary *images = [json objectForKey:@"profile_image"];
        if ([[images objectForKey:@"small"] isKindOfClass:NSString.class]) {
            self.smallProfileImage = [NSURL URLWithString:[images objectForKey:@"small"]];
        }
        if ([[images objectForKey:@"medium"] isKindOfClass:NSString.class]) {
            self.mediumProfileImage = [NSURL URLWithString:[images objectForKey:@"medium"]];
        }
        if ([[images objectForKey:@"large"] isKindOfClass:NSString.class]) {
            self.largeProfileImage = [NSURL URLWithString:[images objectForKey:@"large"]];
        }
        self.username = [json objectForKey:@"username"];
    }
}

+ (NSArray *)createObjectsFromJSON:(NSArray *)jsonObjects {
    return [jsonObjects mapWithBlock:^id(id obj) {
        return [[IVUser alloc] initWithJSON:obj];
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
