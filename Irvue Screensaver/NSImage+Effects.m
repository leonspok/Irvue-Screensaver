//
//  NSImage+Effects.m
//  Irvue
//
//  Created by Игорь Савельев on 26/10/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "NSImage+Effects.h"

@implementation NSImage (Effects)

- (NSImage *)resizeWithAspectFillToSize:(NSSize)size {
	return [self resizeWithAspectFillToSize:size rounded:NO];
}

- (NSImage *)resizeWithAspectFillToSize:(NSSize)size rounded:(BOOL)rounded {
	NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
	NSImage *targetImage = [[NSImage alloc] initWithSize:size];
	
	NSSize sourceSize = [self size];
	
	float ratioH = size.height/sourceSize.height;
	float ratioW = size.width/sourceSize.width;
	
	NSRect cropRect = NSZeroRect;
	if (ratioH >= ratioW) {
		cropRect.size.width = floor (size.width / ratioH);
		cropRect.size.height = sourceSize.height;
	} else {
		cropRect.size.width = sourceSize.width;
		cropRect.size.height = floor(size.height / ratioW);
	}
	
	cropRect.origin.x = floor((sourceSize.width - cropRect.size.width)/2);
	cropRect.origin.y = floor((sourceSize.height - cropRect.size.height)/2);
	
	[targetImage lockFocus];
	if (rounded) {
		[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, size.width, size.height) xRadius:size.width/2.0f yRadius:size.height/2.0f] addClip];
	}
	[self drawInRect:targetFrame
			fromRect:cropRect
		   operation:NSCompositingOperationCopy
			fraction:1.0
	  respectFlipped:YES
			   hints:@{NSImageHintInterpolation: [NSNumber numberWithInt:NSImageInterpolationLow]}];
	[targetImage unlockFocus];
	
	return targetImage;
}

- (NSBitmapImageRep *)bitmapImageRepresentation {
	int width = [self size].width;
	int height = [self size].height;
	
	if (width < 1 || height < 1) {
		return nil;
	}
	
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
							 initWithBitmapDataPlanes:NULL
							 pixelsWide:width
							 pixelsHigh:height
							 bitsPerSample:8
							 samplesPerPixel:4
							 hasAlpha:YES
							 isPlanar:NO
							 colorSpaceName:NSDeviceRGBColorSpace
							 bytesPerRow:width * 4
							 bitsPerPixel:32];
	
	NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep: rep];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext: ctx];
	[self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
	[ctx flushGraphics];
	[NSGraphicsContext restoreGraphicsState];
	
	return rep;
}

@end
