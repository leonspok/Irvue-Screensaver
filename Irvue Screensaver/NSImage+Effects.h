//
//  NSImage+Effects.h
//  Irvue
//
//  Created by Игорь Савельев on 26/10/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Effects)

- (NSImage *)resizeWithAspectFillToSize:(NSSize)size;
- (NSImage *)resizeWithAspectFillToSize:(NSSize)size rounded:(BOOL)rounded;
- (NSBitmapImageRep *)bitmapImageRepresentation;

@end
