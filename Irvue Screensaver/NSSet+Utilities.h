//
//  NSSet+Utilities.h
//  Music Sense
//
//  Created by Игорь Савельев on 01/10/15.
//  Copyright © 2015 10tracks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (Utilities)

- (NSSet *)mapWithBlock:(id (^)(id obj))mapBlock;
- (NSSet *)filterWithBlock:(BOOL (^)(id obj))filterBlock;

@end
