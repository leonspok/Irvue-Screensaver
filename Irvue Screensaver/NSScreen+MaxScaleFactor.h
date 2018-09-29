//
//  NSScreen+MaxScaleFactor.h
//  Irvue
//
//  Created by Игорь Савельев on 30/11/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSScreen (MaxScaleFactor)

+ (CGFloat)maxScaleFactor;
+ (CGSize)maxScreenResolution;

@end
