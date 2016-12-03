//
//  NSBezierPath+CGPath.h
//  Irvue
//
//  Created by Игорь Савельев on 21/10/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (CGPath)

- (CGPathRef)CGPath;

@end
