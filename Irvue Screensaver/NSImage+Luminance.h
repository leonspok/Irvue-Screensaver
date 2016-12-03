//
//  NSImage+Luminance.h
//  Unsplash Wallpaper
//
//  Created by Игорь Савельев on 06/06/15.
//  Copyright (c) 2015 Leonspok. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Luminance)

@property (nonatomic, readonly) CGFloat luminance;

- (CGFloat)luminanceInRect:(NSRect)rect;

@end
