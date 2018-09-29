//
//  NSBezierPath+CGPath.m
//  Irvue
//
//  Created by Игорь Савельев on 21/10/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "NSBezierPath+CGPath.h"

@implementation NSBezierPath (CGPath)

- (CGPathRef)CGPath {
	NSUInteger i, elementCount;
	CGPathRef immutablePath = NULL;
	elementCount = [self elementCount];
	if (elementCount > 0) {
		CGMutablePathRef path = CGPathCreateMutable();
		NSPoint points[3];
		BOOL didClosePath = YES;
		
		for (i = 0; i < elementCount; i++) {
			switch ([self elementAtIndex:i associatedPoints:points]) {
				case NSMoveToBezierPathElement:
					CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
					break;
				case NSLineToBezierPathElement:
					CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
					didClosePath = NO;
					break;
				case NSCurveToBezierPathElement:
					CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
										  points[1].x, points[1].y,
										  points[2].x, points[2].y);
					didClosePath = NO;
					break;
				case NSClosePathBezierPathElement:
					CGPathCloseSubpath(path);
					didClosePath = YES;
					break;
			}
		}
		
		if (!didClosePath) {
			CGPathCloseSubpath(path);
		}
		immutablePath = CGPathCreateCopy(path);
		CGPathRelease(path);
	}
	
	return immutablePath;
}

@end
