//
//  Irvue_ScreensaverView.m
//  Irvue Screensaver
//
//  Created by Игорь Савельев on 30/11/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "Irvue_ScreensaverView.h"
#import "LPUnsplashAPI.h"
#import "LPImageDownloadManager.h"
#import "NSImage+Effects.h"
#import "LPUnsplashPhotoView.h"
#import "NSArray+Utilities.h"
#import "NSString+MD5.h"
#import "TTOfflineChecker.h"

typedef enum {
	SwitchDirectionLeft		= 0,
	SwitchDirectionRight	= 1,
	SwitchDirectionTop		= 2,
	SwitchDirectionBottom	= 3
} SwitchDirection;

@import QuartzCore;

static NSString *const kPhotosCacheKey = @"photos_cached";
static NSString *const kUpdateIntervalKey = @"update_interval";
static NSString *const kPhotosSourceKey = @"photos_source";
static NSString *const kCollectionURLKey = @"collection_url";
static NSString *const kCollectionUIDKey = @"collection_uid";
static NSString *const kUsernameKey = @"username";
static NSString *const kSearchQueryKey = @"search_query";
static NSString *const kAppIdKey = @"app_id";

@interface Irvue_ScreensaverView()
@property (nonatomic, strong) NSView *containerView;
@property (nonatomic, strong) LPUnsplashPhotoView *photoView;

@property (weak) IBOutlet NSButton *featuredRadioButton;
@property (weak) IBOutlet NSButton *collectionRadioButton;
@property (weak) IBOutlet NSTextField *collectionURLTextField;
@property (weak) IBOutlet NSButton *userRadioButton;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSButton *searchRadioButton;
@property (weak) IBOutlet NSTextField *searchQueryTextField;
@property (weak) IBOutlet NSTextField *appIdTextField;

@property (weak) IBOutlet NSSlider *updateIntervalSlider;
@property (weak) IBOutlet NSTextField *updateIntervalLabel;

@property (strong) IBOutlet NSWindow *configSheet;

@end

@implementation Irvue_ScreensaverView {
	IVPhoto *testPhoto;
	NSTimer *changeImageTimer;
	SwitchDirection previousDirection;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		[[LPImageDownloadManager defaultManager] clearOldCache];
		self.defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"com.leonspok.osx.Irvue-Screensaver.defaults"];
        
        [[LPUnsplashAPI sharedInstance] setUnsplashAppId:[self.defaults objectForKey:kAppIdKey]];
		
		self.containerView = [[NSView alloc] initWithFrame:[self bounds]];
		[self.containerView setWantsLayer:YES];
		[self.containerView.layer setBackgroundColor:[NSColor blackColor].CGColor];
		[self addSubview:self.containerView];
		
		if ([self cachedPhotosFromSource:self.source].count == 0) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self replaceCurrentPhotoViewWith:[[LPUnsplashPhotoView alloc] initWithPhoto:[IVPhoto placeholderPhoto]] animated:YES];
				[self changeImage];
			});
		} else {
			[self changeImage];
		}
		
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

#pragma mark Getters And Setters

- (void)setUpdateInterval:(NSTimeInterval)updateInterval {
	if (updateInterval < 5.0f) {
		return;
	}
	[self.defaults setObject:@(updateInterval) forKey:kUpdateIntervalKey];
	[self.defaults synchronize];
}

- (NSTimeInterval)updateInterval {
	NSNumber *number = [self.defaults objectForKey:kUpdateIntervalKey];
	if (!number) {
		[self setUpdateInterval:60.0f];
		return [self updateInterval];
	}
	return [number doubleValue];
}

- (void)setSource:(PhotosSource)source {
	[self.defaults setObject:@(source) forKey:kPhotosSourceKey];
	[self.defaults synchronize];
}

- (PhotosSource)source {
	NSNumber *number = [self.defaults objectForKey:kPhotosSourceKey];
	if (!number) {
		[self setSource:PhotosSourceFeatured];
		return [self source];
	}
	return [number doubleValue];
}

#pragma mark Data

- (void)loadImagesCount:(NSUInteger)count success:(void (^)(NSArray<IVPhoto *> *photos))success failure:(void (^)(NSError *error))failure {
	switch(self.source) {
		case PhotosSourceFeatured:
			[[LPUnsplashAPI sharedInstance] getRandomPhotosFromFeaturedCount:count success:success failure:failure];
			break;
		case PhotosSourceCollection: {
			NSNumber *collectionUID = [self.defaults objectForKey:kCollectionUIDKey];
			if (collectionUID) {
				[[LPUnsplashAPI sharedInstance] getRandomPhotosFromCollectionWithID:collectionUID count:count success:success failure:failure];
			} else {
				if (failure) {
					failure([NSError errorWithDomain:NSStringFromClass(self.class) code:1 userInfo:@{@"message": @"no collection id"}]);
				}
			}
			break;
		}
		case PhotosSourceUser: {
			NSString *username = [self.defaults objectForKey:kUsernameKey];
			if (username.length > 0) {
				[[LPUnsplashAPI sharedInstance] getRandomPhotosFromUserWithName:username count:count success:success failure:failure];
			} else {
				if (failure) {
					failure([NSError errorWithDomain:NSStringFromClass(self.class) code:1 userInfo:@{@"message": @"no username"}]);
				}
			}
			break;
		}
		case PhotosSourceSearch: {
			NSString *query = [self.defaults objectForKey:kSearchQueryKey];
			if (query.length > 0) {
				[[LPUnsplashAPI sharedInstance] getRandomPhotosFromSearchQuery:query count:count success:success failure:failure];
			} else {
				if (failure) {
					failure([NSError errorWithDomain:NSStringFromClass(self.class) code:1 userInfo:@{@"message": @"no query"}]);
				}
			}
			break;
		}
	}
}

- (void)getNextImageSuccess:(void (^)(IVPhoto *photo))success failure:(void (^)(NSError *))failure {
	PhotosSource source = self.source;
	NSArray<IVPhoto *> *photos = [self cachedPhotosFromSource:source];
	if (photos.count == 0) {
		[self loadImagesCount:30 success:^(NSArray<IVPhoto *> *photos) {
			if (photos.count == 0) {
				if (failure) {
					failure([NSError errorWithDomain:NSStringFromClass(self.class) code:1 userInfo:@{@"message": @"no photos"}]);
				}
			} else {
				[self saveToCachePhotos:photos fromSource:source];
				IVPhoto *nextPhoto = [photos firstObject];
				if (success) {
					success(nextPhoto);
				}
				[self removeFromCachePhoto:nextPhoto fromSource:source];
			}
		} failure:failure];
	} else {
		IVPhoto *nextPhoto = [photos firstObject];
		if (success) {
			success(nextPhoto);
		}
		[self removeFromCachePhoto:nextPhoto fromSource:source];
	}
}

- (NSArray<IVPhoto *> *)cachedPhotosFromSource:(PhotosSource)source {
	NSData *data = [self.defaults objectForKey:kPhotosCacheKey];
	NSDictionary *cache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSString *key = [@(source) stringValue];
	if (source == PhotosSourceCollection) {
		if (![self.defaults objectForKey:kCollectionUIDKey]) {
			return @[];
		}
		key = [NSString stringWithFormat:@"%@_%@", key, [[[self.defaults objectForKey:kCollectionUIDKey] stringValue] MD5String]];
	} else if (source == PhotosSourceUser) {
		if (![self.defaults objectForKey:kUsernameKey]) {
			return @[];
		}
		key = [NSString stringWithFormat:@"%@_%@", key, [[self.defaults objectForKey:kUsernameKey] MD5String]];
	} else if (source == PhotosSourceSearch) {
		if (![self.defaults objectForKey:kSearchQueryKey]) {
			return @[];
		}
		key = [NSString stringWithFormat:@"%@_%@", key, [[self.defaults objectForKey:kSearchQueryKey] MD5String]];
	}
	return [cache objectForKey:key];
}

- (void)removeFromCachePhoto:(IVPhoto *)photo fromSource:(PhotosSource)source {
	NSArray *cached = [self cachedPhotosFromSource:source];
	cached = [cached filterWithBlock:^BOOL(id obj) {
		return ![obj isEqual:photo];
	}];
	[self saveToCachePhotos:cached fromSource:source];
}

- (void)saveToCachePhotos:(NSArray<IVPhoto *> *)photos fromSource:(PhotosSource)source {
	NSData *data = [self.defaults objectForKey:kPhotosCacheKey];
	NSDictionary *cache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (cache) {
		cache = [NSDictionary dictionary];
	}
	
	NSString *key = [@(source) stringValue];
	if (source == PhotosSourceCollection) {
		if (![self.defaults objectForKey:kCollectionUIDKey]) {
			return;
		}
		key = [NSString stringWithFormat:@"%@_%@", key, [[[self.defaults objectForKey:kCollectionUIDKey] stringValue] MD5String]];
	} else if (source == PhotosSourceUser) {
		if (![self.defaults objectForKey:kUsernameKey]) {
			return;
		}
		key = [NSString stringWithFormat:@"%@_%@", key, [[self.defaults objectForKey:kUsernameKey] MD5String]];
	} else if (source == PhotosSourceSearch) {
		if (![self.defaults objectForKey:kSearchQueryKey]) {
			return;
		}
		key = [NSString stringWithFormat:@"%@_%@", key, [[self.defaults objectForKey:kSearchQueryKey] MD5String]];
	}
	
	NSMutableDictionary *mutableCache = [cache mutableCopy];
	if (photos) {
		[mutableCache setObject:photos forKey:key];
	} else {
		[mutableCache removeObjectForKey:key];
	}
	if (source == PhotosSourceCollection ||
		source == PhotosSourceUser ||
		source == PhotosSourceSearch) {
		for (NSString *k in [mutableCache allKeys]) {
			if ([k hasPrefix:[@(source) stringValue]] && ![k isEqualToString:key]) {
				[mutableCache removeObjectForKey:k];
			}
		}
	}
	
	cache = [NSDictionary dictionaryWithDictionary:mutableCache];
	data = [NSKeyedArchiver archivedDataWithRootObject:cache];
	[self.defaults setObject:data forKey:kPhotosCacheKey];
	[self.defaults synchronize];
}

#pragma mark Animations

- (void)changeImage {
	if ([[TTOfflineChecker defaultChecker] isOffline]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			changeImageTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
		});
		return;
	}
	
	[changeImageTimer invalidate];
	changeImageTimer = nil;
	[self getNextImageSuccess:^(IVPhoto *photo) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self replaceCurrentPhotoViewWith:[[LPUnsplashPhotoView alloc] initWithPhoto:photo] animated:YES];
		});
	} failure:^(NSError *error) {
		NSLog(@"%@", error);
		dispatch_async(dispatch_get_main_queue(), ^{
			changeImageTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
		});
	}];
}

- (NSArray<NSValue *> *)transformsForDirection:(SwitchDirection)direction {
	switch(direction) {
		case SwitchDirectionTop:
			return @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, [self bounds].size.height, 0)],
					 [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -[self bounds].size.height, 0)]];
		case SwitchDirectionBottom:
			return @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -[self bounds].size.height, 0)],
					 [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, [self bounds].size.height, 0)]];
		case SwitchDirectionLeft:
			return @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-[self bounds].size.width, 0, 0)],
					 [NSValue valueWithCATransform3D:CATransform3DMakeTranslation([self bounds].size.width, 0, 0)]];
		case SwitchDirectionRight:
			return @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation([self bounds].size.width, 0, 0)],
					 [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-[self bounds].size.width, 0, 0)]];
	}
}

- (void)replaceCurrentPhotoViewWith:(LPUnsplashPhotoView *)photoView animated:(BOOL)animated {
	[photoView setupCompletion:^(BOOL success) {
		if (success) {
			
			[photoView setFrame:[self bounds]];
			[photoView setNeedsLayout:YES];
			[photoView layoutSubtreeIfNeeded];
			if (animated) {
				SwitchDirection direction;
				do {
					direction = arc4random()%4;
				} while(direction == previousDirection ||
						(direction == SwitchDirectionLeft && previousDirection == SwitchDirectionRight) ||
						(direction == SwitchDirectionRight && previousDirection == SwitchDirectionLeft) ||
						(direction == SwitchDirectionTop && previousDirection == SwitchDirectionBottom) ||
						(direction == SwitchDirectionBottom && previousDirection == SwitchDirectionTop));
				previousDirection = direction;
				
				NSArray *transforms = [self transformsForDirection:direction];
				
				[photoView.layer setTransform:[[transforms firstObject] CATransform3DValue]];
				[self addSubview:photoView positioned:NSWindowAbove relativeTo:nil];
				
				CABasicAnimation *newPhotoAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
				newPhotoAnimation.fromValue = [transforms firstObject];
				newPhotoAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
				newPhotoAnimation.duration = 1.0f;
				newPhotoAnimation.fillMode = kCAFillModeForwards;
				newPhotoAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.6 :0 :0.4 :1.0];
				newPhotoAnimation.removedOnCompletion = NO;
				[photoView.layer addAnimation:newPhotoAnimation forKey:@"animation"];
				
				CABasicAnimation *oldPhotoAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
				oldPhotoAnimation.toValue = [transforms lastObject];
				oldPhotoAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
				oldPhotoAnimation.duration = 1.0f;
				oldPhotoAnimation.fillMode = kCAFillModeForwards;
				oldPhotoAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.6 :0 :0.4 :1.0];
				oldPhotoAnimation.removedOnCompletion = NO;
				[self.photoView.layer addAnimation:oldPhotoAnimation forKey:@"animation"];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(newPhotoAnimation.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self.photoView removeFromSuperview];
					self.photoView = photoView;
					changeImageTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
				});
			} else {
				[self addSubview:photoView positioned:NSWindowAbove relativeTo:nil];
				[self.photoView removeFromSuperview];
				self.photoView = photoView;
				changeImageTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
			}
		} else {
			changeImageTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
		}
	}];
}

- (void)layoutSubtreeIfNeeded {
	[super layoutSubtreeIfNeeded];
	[self.containerView setFrame:[self bounds]];
	[self.photoView setFrame:[self.containerView bounds]];
	[self.photoView setNeedsLayout:YES];
	[self.photoView layoutSubtreeIfNeeded];
}

- (void)viewWillStartLiveResize {
	[super viewWillStartLiveResize];
	[self setNeedsLayout:YES];
	[self layoutSubtreeIfNeeded];
}

- (void)viewDidEndLiveResize {
	[super viewDidEndLiveResize];
	[self setNeedsLayout:YES];
	[self layoutSubtreeIfNeeded];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
}

- (void)animateOneFrame
{
	[self setNeedsLayout:YES];
	[self.containerView setNeedsDisplay:YES];
	[self.containerView displayIfNeeded];
	[self.photoView setNeedsDisplay:YES];
	[self.photoView displayIfNeeded];
}

#pragma mark - Configure Sheet

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow *)configureSheet {
	if (!self.configSheet) {
		if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) {
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}
	}
	
	[self.featuredRadioButton setState:(self.source == PhotosSourceFeatured)? NSOnState: NSOffState];
	[self.collectionRadioButton setState:(self.source == PhotosSourceCollection)? NSOnState: NSOffState];
	[self.userRadioButton setState:(self.source == PhotosSourceUser)? NSOnState: NSOffState];
	[self.searchRadioButton setState:(self.source == PhotosSourceSearch)? NSOnState: NSOffState];
	self.collectionURLTextField.stringValue = [self.defaults stringForKey:kCollectionURLKey]? : @"";
	self.usernameTextField.stringValue = [self.defaults stringForKey:kUsernameKey]? : @"";
	self.searchQueryTextField.stringValue = [self.defaults stringForKey:kSearchQueryKey]? : @"";
	self.updateIntervalSlider.doubleValue = self.updateInterval/60.0;
    [self.appIdTextField setStringValue:[LPUnsplashAPI sharedInstance].unsplashAppId? : @""];
	[self updateIntervalChanged:nil];
	
    return self.configSheet;
}

- (IBAction)selectedSource:(id)sender {
	if (sender == self.featuredRadioButton) {
		[self selectedFeatured:sender];
	} else if (sender == self.collectionRadioButton) {
		[self selectedCollection:sender];
	} else if (sender == self.userRadioButton) {
		[self selectedUser:sender];
	} else if (sender == self.searchRadioButton) {
		[self selectedSearch:sender];
	}
}

- (IBAction)selectedFeatured:(id)sender {
	self.source = PhotosSourceFeatured;
}

- (NSNumber *)collectionUIDFromTextField {
	NSString *str = self.collectionURLTextField.stringValue;
	NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
	NSArray *urlMatches = [linkDetector matchesInString:str options:0 range:NSMakeRange(0, [str length])];
	NSArray<NSURL *> *urls = [urlMatches mapWithBlock:^id(NSTextCheckingResult *obj) {
		return [obj URL];
	}];
	if (urls.count == 0) {
		return nil;
	}
	NSURL *url = [urls firstObject];
	if ([[url host] isEqualToString:@"unsplash.com"]) {
		NSArray<NSString *> *pathComponents = url.pathComponents;
		if (pathComponents.count >= 2) {
			if ([[pathComponents objectAtIndex:1] isEqualToString:@"collections"]) {
				if (pathComponents.count >= 3) {
					if ([[pathComponents objectAtIndex:2] isEqualToString:@"curated"]) {
						if (pathComponents.count >= 4) {
							NSString *collectionUID = [pathComponents objectAtIndex:3];
							NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
							numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
							NSNumber *uid = [numberFormatter numberFromString:collectionUID];
							return uid;
						}
					} else {
						NSString *collectionUID = [pathComponents objectAtIndex:2];
						NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
						numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
						NSNumber *uid = [numberFormatter numberFromString:collectionUID];
						return uid;
					}
				}
			}
		}
	}
	return nil;
}

- (NSString *)collectionURLFromTextField {
	NSString *str = self.collectionURLTextField.stringValue;
	NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
	NSArray *urlMatches = [linkDetector matchesInString:str options:0 range:NSMakeRange(0, [str length])];
	NSArray<NSURL *> *urls = [urlMatches mapWithBlock:^id(NSTextCheckingResult *obj) {
		return [obj URL];
	}];
	if (urls.count == 0) {
		return nil;
	}
	NSURL *url = [urls firstObject];
	return [url absoluteString];
}

- (IBAction)selectedCollection:(id)sender {
	void (^abortBlock)() = ^{
		self.source = PhotosSourceFeatured;
	};
	
	if (self.collectionURLTextField.stringValue.length > 0) {
		NSNumber *uid = [self collectionUIDFromTextField];
		NSString *url = [self collectionURLFromTextField];
		if (!uid || url.length == 0) {
			abortBlock();
			return;
		}
		[self.defaults setObject:uid forKey:kCollectionUIDKey];
		[self.defaults setObject:url forKey:kCollectionURLKey];
		[self.defaults synchronize];
		self.source = PhotosSourceCollection;
	} else {
		abortBlock();
	}
}

- (IBAction)selectedUser:(id)sender {
	if (self.usernameTextField.stringValue.length > 0) {
		[self.defaults setObject:self.usernameTextField.stringValue forKey:kUsernameKey];
		[self.defaults synchronize];
		self.source = PhotosSourceUser;
	} else {
		self.source = PhotosSourceFeatured;
	}
}

- (IBAction)selectedSearch:(id)sender {
	if (self.searchQueryTextField.stringValue.length > 0) {
		[self.defaults setObject:self.searchQueryTextField.stringValue forKey:kSearchQueryKey];
		[self.defaults synchronize];
		self.source = PhotosSourceSearch;
	} else {
		self.source = PhotosSourceFeatured;
	}
}

- (IBAction)updateIntervalChanged:(id)sender {
	self.updateInterval = self.updateIntervalSlider.doubleValue;
	NSInteger minutes = ((NSInteger)round(self.updateInterval))/60;
	NSInteger seconds = ((NSInteger)self.updateInterval)%60;
	NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
	self.updateIntervalLabel.stringValue = [NSString stringWithFormat:@"Photos will update every %@", timeStr];
}

- (IBAction)close:(id)sender {
	[self.configSheet.sheetParent endSheet:self.configSheet];
	NSNumber *uid = [self collectionUIDFromTextField];
	NSString *url = [self collectionURLFromTextField];
	if (uid && url.length > 0) {
		[self.defaults setObject:uid forKey:kCollectionUIDKey];
		[self.defaults setObject:url forKey:kCollectionURLKey];
	} else if (self.source == PhotosSourceCollection) {
		[self.defaults removeObjectForKey:kCollectionUIDKey];
		[self.defaults removeObjectForKey:kCollectionURLKey];
		if (self.source == PhotosSourceCollection) {
			self.source = PhotosSourceFeatured;
		}
	}
	if (self.usernameTextField.stringValue.length > 0) {
		[self.defaults setObject:self.usernameTextField.stringValue forKey:kUsernameKey];
	} else {
		[self.defaults removeObjectForKey:kUsernameKey];
		if (self.source == PhotosSourceUser) {
			self.source = PhotosSourceFeatured;
		}
	}
	if (self.searchQueryTextField.stringValue.length > 0) {
		[self.defaults setObject:self.searchQueryTextField.stringValue forKey:kSearchQueryKey];
	} else {
		[self.defaults removeObjectForKey:kSearchQueryKey];
		if (self.source == PhotosSourceSearch) {
			self.source = PhotosSourceFeatured;
		}
	}
	[self.defaults synchronize];
	self.updateInterval = self.updateIntervalSlider.doubleValue;
    
    NSString *appId = self.appIdTextField.stringValue;
    [self.defaults setObject:appId forKey:kAppIdKey];
    [[LPUnsplashAPI sharedInstance] setUnsplashAppId:appId];
}

@end
