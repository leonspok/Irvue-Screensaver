//
//  NSScreen+MaxScaleFactor.m
//  Irvue
//
//  Created by Игорь Савельев on 30/11/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "NSScreen+MaxScaleFactor.h"

@implementation NSScreen (MaxScaleFactor)

+ (CGFloat)maxScaleFactor {
	CGFloat factor = 0.0f;
	for (NSScreen *screen in [NSScreen screens]) {
		factor = MAX(factor, [screen backingScaleFactor]);
	}
	return factor;
}

+ (CGSize)maxScreenResolution {
	CGFloat width = 0.0f;
	CGFloat height = 0.0f;
	for (NSScreen *screen in [NSScreen screens]) {
		width = MAX(width, screen.frame.size.width*[screen backingScaleFactor]);
		height = MAX(height, screen.frame.size.height*[screen backingScaleFactor]);
	}
	return NSMakeSize(width, height);
}

@end
