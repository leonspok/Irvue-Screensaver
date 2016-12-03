//
//  NSArray+Utilities.h
//  Music Sense
//
//  Created by Игорь Савельев on 01/10/15.
//  Copyright © 2015 10tracks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utilities)

- (NSArray *)mapWithBlock:(id (^)(id obj))mapBlock;
- (NSArray *)filterWithBlock:(BOOL (^)(id obj))filterBlock;

@end
