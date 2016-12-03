//
//  LPUnsplashPhotoView.h
//  Irvue Screensaver
//
//  Created by Игорь Савельев on 30/11/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IVPhoto.h"

@interface LPUnsplashPhotoView : NSView

@property (nonatomic, strong) NSImageView *photoImageView;
@property (nonatomic, strong) NSImageView *avatarImageView;
@property (nonatomic, strong) NSTextField *authorNameLabel;
@property (nonatomic, strong) NSTextField *authorProfilePage;

@property (nonatomic, strong) IVPhoto *photo;

- (id)initWithPhoto:(IVPhoto *)photo;

- (void)setupCompletion:(void (^)(BOOL success))completion;

@end
