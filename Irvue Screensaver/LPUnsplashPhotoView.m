//
//  LPUnsplashPhotoView.m
//  Irvue Screensaver
//
//  Created by Игорь Савельев on 30/11/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "LPUnsplashPhotoView.h"
#import "LPImageDownloadManager.h"
#import "NSImage+Effects.h"
#import "IVUser.h"
#import "IVPhotoLocation.h"
#import "NSScreen+MaxScaleFactor.h"
#import "NSImage+Luminance.h"

@import QuartzCore;

@implementation LPUnsplashPhotoView {
	NSImage *photoImage;
	CAGradientLayer *gradientLayer;
}

- (id)initWithPhoto:(IVPhoto *)photo {
	self = [self initWithFrame:NSMakeRect(0, 0, 1280, 800)];
	if (self) {
		self.photo = photo;
		[self setWantsLayer:YES];
		[self.layer setBackgroundColor:[NSColor blackColor].CGColor];
		
		self.photoImageView = [[NSImageView alloc] initWithFrame:[self bounds]];
		[self.photoImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
		[self.photoImageView setImageAlignment:NSImageAlignCenter];
		[self.photoImageView setImageFrameStyle:NSImageFrameNone];
		[self addSubview:self.photoImageView];
		
		self.avatarImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(20, 20, 70, 70)];
		[self.avatarImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
		[self.avatarImageView setImageAlignment:NSImageAlignCenter];
		[self.avatarImageView setImageFrameStyle:NSImageFrameNone];
		[self addSubview:self.avatarImageView];
		
		self.authorNameLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(105, 48, [self bounds].size.width-110, 30)];
		[self.authorNameLabel setEditable:NO];
		[self.authorNameLabel setBordered:NO];
		[self.authorNameLabel setFont:[NSFont systemFontOfSize:22.0f]];
		[self.authorNameLabel setTextColor:[NSColor colorWithWhite:1.0f alpha:0.8f]];
		[self.authorNameLabel setBackgroundColor:[NSColor clearColor]];
		[self addSubview:self.authorNameLabel];
		
		self.authorProfilePage = [[NSTextField alloc] initWithFrame:NSMakeRect(105, 32, [self bounds].size.width-110, 20)];
		[self.authorProfilePage setEditable:NO];
		[self.authorProfilePage setBordered:NO];
		[self.authorProfilePage setFont:[NSFont systemFontOfSize:14.0f]];
		[self.authorProfilePage setTextColor:[NSColor colorWithWhite:1 alpha:0.6f]];
		[self.authorProfilePage setBackgroundColor:[NSColor clearColor]];
		[self addSubview:self.authorProfilePage];
		
		gradientLayer = [CAGradientLayer layer];
		gradientLayer.colors = @[(id)[NSColor colorWithWhite:0 alpha:0.8f].CGColor,
								 (id)[NSColor clearColor].CGColor];
		[gradientLayer setFrame:CGRectMake(0, 0, self.photoImageView.frame.size.width, 200.0f)];
		[self.photoImageView.layer addSublayer:gradientLayer];
		
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];    
}

- (void)layoutSubtreeIfNeeded {
	[super layoutSubtreeIfNeeded];
	[self.photoImageView setFrame:[self bounds]];
	[gradientLayer setFrame:CGRectMake(0, 0, self.photoImageView.frame.size.width, 80.0f)];
	[self.avatarImageView setFrame:NSMakeRect(20, 20, 70, 70)];
	if (self.authorProfilePage.stringValue.length > 0) {
		[self.authorProfilePage setHidden:NO];
		[self.authorNameLabel setFrame:NSMakeRect(105, 48, [self bounds].size.width-110, 30)];
		[self.authorProfilePage setFrame:NSMakeRect(105, 32, [self bounds].size.width-110, 20)];
	} else {
		[self.authorProfilePage setHidden:YES];
		[self.authorNameLabel setFrame:NSMakeRect(105, 40, [self bounds].size.width-110, 30)];
	}
	if (photoImage) {
		NSImage *newImage = [photoImage resizeWithAspectFillToSize:NSMakeSize(self.photoImageView.frame.size.width * [NSScreen maxScaleFactor],
																			  self.photoImageView.frame.size.height * [NSScreen maxScaleFactor])];
		[self.photoImageView setImage:newImage];
	}
}

- (void)setupCompletion:(void (^)(BOOL))completion {
	NSString *author;
	if (self.photo.author.firstName.length > 0 && self.photo.author.lastName.length > 0) {
		author = [NSString stringWithFormat:@"%@ %@", self.photo.author.firstName, self.photo.author.lastName];
	} else if (self.photo.author.name.length > 0) {
		author = self.photo.author.name;
	}
	[self.authorNameLabel setStringValue:author];
	
	self.authorProfilePage.stringValue = [NSString stringWithFormat:@"unsplash.com/@%@", self.photo.author.username];

	__block NSInteger imageLoaded = 0;
	__block NSInteger avatarLoaded = 0;
	
	void (^completionBlock)() = ^{
		if (imageLoaded == 1 && avatarLoaded == 1) {
			if (completion) {
				completion(YES);
			}
			return;
		} else if (imageLoaded != 0 && avatarLoaded != 0) {
			if (completion) {
				completion(NO);
			}
			return;
		}
	};
	
	if (![self.photo isPlaceholder]) {
		NSURL *imageURL = [self.photo imageURLForSize:[NSScreen maxScreenResolution]];
		if ([[LPImageDownloadManager defaultManager] hasImageForURL:[imageURL absoluteString]]) {
			photoImage = [[LPImageDownloadManager defaultManager] getImageForURL:[imageURL absoluteString]];
			if (photoImage) {
				[self.photoImageView setImage:photoImage];
				[self setNeedsLayout:YES];
				imageLoaded = 1;
			} else {
				imageLoaded = -1;
			}
			completionBlock();
		} else {
			[[LPImageDownloadManager defaultManager] getImageForURL:[imageURL absoluteString] completion:^(NSImage *image) {
				photoImage = image;
				if (photoImage) {
					[self.photoImageView setImage:photoImage];
					[self setNeedsLayout:YES];
					imageLoaded = 1;
				} else {
					imageLoaded = -1;
				}
				completionBlock();
			}];
		}
	} else {
		photoImage = [NSImage imageNamed:@"placeholder"];
		if (photoImage) {
			[self.photoImageView setImage:photoImage];
			[self setNeedsLayout:YES];
			imageLoaded = 1;
		} else {
			imageLoaded = -1;
		}
		completionBlock();
	}
	
	NSURL *authorImageURL = self.photo.author.largeProfileImage;
	if (!authorImageURL) {
		authorImageURL = self.photo.author.mediumProfileImage;
	}
	if (!authorImageURL) {
		authorImageURL = self.photo.author.smallProfileImage;
	}
	
	if (authorImageURL) {
		if ([[LPImageDownloadManager defaultManager] hasImageForURL:[authorImageURL absoluteString] size:TTImageSize300px rounded:YES]) {
			[self.avatarImageView setImage:[[LPImageDownloadManager defaultManager] getImageForURL:[authorImageURL absoluteString] size:TTImageSize300px rounded:YES]];
			avatarLoaded = 1;
			completionBlock();
		} else {
			[[LPImageDownloadManager defaultManager] getImageForURL:[authorImageURL absoluteString] size:TTImageSize300px rounded:YES completion:^(NSImage *image) {
				if (image) {
					[self.avatarImageView setImage:image];
					avatarLoaded = 1;
				} else {
					avatarLoaded = -1;
				}
				completionBlock();
			}];
		}
	} else {
		if ([self.photo isPlaceholder]) {
			[self.avatarImageView setImage:[[NSImage imageNamed:@"placeholderProfileImage"] resizeWithAspectFillToSize:NSMakeSize(300, 300) rounded:YES]];
		}
		avatarLoaded = 1;
		completionBlock();
	}
}

@end
