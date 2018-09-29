//
//  LPUnsplashAPI.m
//  Irvue
//
//  Created by Игорь Савельев on 22/10/15.
//  Copyright © 2015 Leonspok. All rights reserved.
//

#import "LPUnsplashAPI.h"
#import "NSArray+Utilities.h"
#import "IVCollection.h"
#import "IVPhoto.h"
#import "IVUser.h"
#import "NSDictionary+NSURL.h"
#import "TTHTTPRequestSerializer.h"
#import "UnsplashCredentials.h"

#define REQUESTS_LIMIT 100

static NSString *const kUnsplashAPIBaseURL = @"https://api.unsplash.com";

@interface LPUnsplashAPI()
@property (nonatomic) NSUInteger requestsCount;
@property (nonatomic, strong) NSDate *lastCheckDate;
@end

@implementation LPUnsplashAPI {
    NSURLSession *session;
}

+ (instancetype)sharedInstance {
    static LPUnsplashAPI *__sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[LPUnsplashAPI alloc] init];
    });
    return __sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (NSMutableURLRequest *)createRequestWithURL:(NSURL *)url method:(NSString *)method params:(NSDictionary *)params {
	NSMutableURLRequest *request = [TTHTTPRequestSerializer requestWithMethod:method url:url params:params];
	[request setValue:[NSString stringWithFormat:@"Client-ID %@", [self unsplashAppIdToUse]] forHTTPHeaderField:@"Authorization"];
	[request setValue:@"v1" forHTTPHeaderField:@"Accept-Version"];
	return request;
}

- (NSString *)unsplashAppIdToUse {
    if (self.unsplashAppId.length == 0) {
        return UNSPLASH_APP_ID;
    }
    return self.unsplashAppId;
}

#pragma mark Photos

#pragma mark Photos / Random / Single

- (void)getRandomPhotoWithParams:(NSDictionary *)params
						 success:(void (^)(IVPhoto *photo))success
						 failure:(void (^)(NSError *error))failure {
    
    if (self.lastCheckDate && [[NSDate date] timeIntervalSinceDate:self.lastCheckDate] >= 3600) {
        self.requestsCount = 0;
    }
    
    if (self.requestsCount >= REQUESTS_LIMIT) {
        if (failure) {
            failure([NSError errorWithDomain:NSStringFromClass(self.class) code:3 userInfo:nil]);
        }
        return;
    }
    
    self.requestsCount += 1;
    self.lastCheckDate = [NSDate date];
    
	NSMutableDictionary *fullParams = [params mutableCopy];
	[fullParams addEntriesFromDictionary:@{@"orientation": @"landscape",
										   @"count": @1}];
	
	NSURLRequest *photoRequest = [self createRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/photos/random", kUnsplashAPIBaseURL]] method:@"GET" params:fullParams];
	[[session dataTaskWithRequest:photoRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			if (failure) {
				failure(error);
			}
			return;
		}
		
		NSError *jsonError;
		id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
		if (jsonError) {
			if (failure) {
				failure(jsonError);
			}
			return;
		}
		NSDictionary *photoJSON;
		if ([json isKindOfClass:(NSDictionary.class)]) {
			NSDictionary *errorJSON = json;
			if (failure) {
				failure([NSError errorWithDomain:NSStringFromClass(self.class) code:2 userInfo:@{@"json": errorJSON}]);
			}
			return;
		} else if ([json isKindOfClass:NSArray.class]) {
			photoJSON = [json firstObject];
		}
		
		IVPhoto *photo = [[IVPhoto alloc] initWithJSON:photoJSON];
		if (success) {
			success(photo);
		}
	}] resume];
}

- (void)getRandomPhotoFromFeaturedSuccess:(void (^)(IVPhoto *photo))success
								  failure:(void (^)(NSError *error))failure {
	[self getRandomPhotoWithParams:@{@"featured": @YES} success:success failure:failure];
}

- (void)getRandomPhotoFromCollectionWithID:(NSNumber *)collectionUID
								   success:(void (^)(IVPhoto *photo))success
								   failure:(void (^)(NSError *error))failure {
	[self getRandomPhotoWithParams:@{@"collections": collectionUID} success:success failure:failure];
}

- (void)getRandomPhotoFromUserWithName:(NSString *)username
							   success:(void (^)(IVPhoto *photo))success
							   failure:(void (^)(NSError *error))failure {
	[self getRandomPhotoWithParams:@{@"username": username} success:success failure:failure];
}

- (void)getRandomPhotoFromSearchQuery:(NSString *)query
							  success:(void (^)(IVPhoto *photo))success
							  failure:(void (^)(NSError *error))failure {
	[self getRandomPhotoWithParams:@{@"query": query} success:success failure:failure];
}

#pragma mark Photos / Random / Multiple

- (void)loadRandomPhotosCount:(NSUInteger)count params:(NSDictionary *)params
					  success:(void (^)(NSArray<IVPhoto *> *photos))success
					  failure:(void (^)(NSError *error))failure {
	if (count == 0) {
		if (failure) {
			failure([NSError errorWithDomain:NSStringFromClass(self.class) code:1 userInfo:@{@"message": @"count parameter is zero"}]);
		}
		return;
	}
    
    if (self.lastCheckDate && [[NSDate date] timeIntervalSinceDate:self.lastCheckDate] >= 3600) {
        self.requestsCount = 0;
    }
    
    if (self.requestsCount >= REQUESTS_LIMIT) {
        if (failure) {
            failure([NSError errorWithDomain:NSStringFromClass(self.class) code:3 userInfo:nil]);
        }
        return;
    }
    
    self.requestsCount += 1;
    self.lastCheckDate = [NSDate date];
	
	NSMutableDictionary *fullParams = [params mutableCopy];
	[fullParams addEntriesFromDictionary:@{@"orientation": @"landscape",
										   @"count": @(count)}];
	
	NSURLRequest *photosRequest = [self createRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/photos/random", kUnsplashAPIBaseURL]] method:@"GET" params:fullParams];
	[[session dataTaskWithRequest:photosRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			if (failure) {
				failure(error);
			}
			return;
		}
		
		NSError *jsonError;
		id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
		if (jsonError) {
			if (failure) {
				failure(jsonError);
			}
			return;
		}
		if (![json isKindOfClass:NSArray.class]) {
			if (failure) {
				failure([NSError errorWithDomain:NSStringFromClass(self.class) code:2 userInfo:@{@"json": json}]);
			}
			return;
		}
		NSArray *photosJSON = json;
		if (photosJSON.count == 0) {
			if (failure) {
				failure([NSError errorWithDomain:NSStringFromClass(self.class) code:1 userInfo:@{@"message": @"no photos"}]);
			}
			return;
		}
		
		NSArray *__block photosToReturn = [photosJSON mapWithBlock:^id(id obj) {
			return [[IVPhoto alloc] initWithJSON:obj];
		}];
		
		if (success) {
			success(photosToReturn);
		}
	}] resume];
}

- (void)getRandomPhotosFromFeaturedCount:(NSUInteger)count
								 success:(void (^)(NSArray<IVPhoto *> *photos))success
								 failure:(void (^)(NSError *error))failure {
	[self loadRandomPhotosCount:count params:@{@"featured": @YES} success:success failure:failure];
}

- (void)getRandomPhotosFromCollectionWithID:(NSNumber *)collectionUID
									  count:(NSUInteger)count
									success:(void (^)(NSArray<IVPhoto *> *photos))success
									failure:(void (^)(NSError *error))failure {
	[self loadRandomPhotosCount:count params:@{@"collections": collectionUID} success:success failure:failure];
}

- (void)getRandomPhotosFromUserWithName:(NSString *)username
								  count:(NSUInteger)count
								success:(void (^)(NSArray<IVPhoto *> *photos))success
								failure:(void (^)(NSError *error))failure {
	[self loadRandomPhotosCount:count params:@{@"username": username} success:success failure:failure];
}

- (void)getRandomPhotosFromSearchQuery:(NSString *)query
								 count:(NSUInteger)count
							   success:(void (^)(NSArray<IVPhoto *> *photos))success
							   failure:(void (^)(NSError *error))failure {
	[self loadRandomPhotosCount:count params:@{@"query": query} success:success failure:failure];
}

@end
