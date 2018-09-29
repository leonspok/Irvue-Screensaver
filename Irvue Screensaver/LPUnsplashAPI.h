//
//  LPUnsplashAPI.h
//  Irvue
//
//  Created by Игорь Савельев on 22/10/15.
//  Copyright © 2015 Leonspok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVPhoto.h"
#import "IVUser.h"
#import "IVCollection.h"

@interface LPUnsplashAPI : NSObject

@property (nonatomic, strong) NSString *unsplashAppId;

+ (instancetype)sharedInstance;

#pragma mark Photos

#pragma mark Photos / Random / Single

- (void)getRandomPhotoFromFeaturedSuccess:(void (^)(IVPhoto *photo))success
								  failure:(void (^)(NSError *error))failure;

- (void)getRandomPhotoFromCollectionWithID:(NSNumber *)collectionUID
								   success:(void (^)(IVPhoto *photo))success
								   failure:(void (^)(NSError *error))failure;

- (void)getRandomPhotoFromUserWithName:(NSString *)username
							   success:(void (^)(IVPhoto *photo))success
							   failure:(void (^)(NSError *error))failure;

- (void)getRandomPhotoFromSearchQuery:(NSString *)query
							  success:(void (^)(IVPhoto *photo))success
							  failure:(void (^)(NSError *error))failure;

#pragma mark Photos / Random / Multiple

- (void)getRandomPhotosFromFeaturedCount:(NSUInteger)count
								 success:(void (^)(NSArray<IVPhoto *> *photos))success
								 failure:(void (^)(NSError *error))failure;

- (void)getRandomPhotosFromCollectionWithID:(NSNumber *)collectionUID
									  count:(NSUInteger)count
									success:(void (^)(NSArray<IVPhoto *> *photos))success
									failure:(void (^)(NSError *error))failure;

- (void)getRandomPhotosFromUserWithName:(NSString *)username
								  count:(NSUInteger)count
								success:(void (^)(NSArray<IVPhoto *> *photos))success
								failure:(void (^)(NSError *error))failure;

- (void)getRandomPhotosFromSearchQuery:(NSString *)query
								 count:(NSUInteger)count
							   success:(void (^)(NSArray<IVPhoto *> *photos))success
							   failure:(void (^)(NSError *error))failure;

@end
