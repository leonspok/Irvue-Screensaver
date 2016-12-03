//
//  NSSet+Utilities.m
//  Music Sense
//
//  Created by Игорь Савельев on 01/10/15.
//  Copyright © 2015 10tracks. All rights reserved.
//

#import "NSSet+Utilities.h"

@implementation NSSet (Utilities)

- (NSSet *)mapWithBlock:(id (^)(id))mapBlock {
    NSMutableSet *newSet = [NSMutableSet set];
    for (id obj in self) {
        id newObj;
        if (mapBlock) {
            newObj = mapBlock(obj);
        }
        if (newObj) {
            [newSet addObject:newObj];
        }
    }
    return [NSMutableSet setWithSet:newSet];
}

- (NSSet *)filterWithBlock:(BOOL (^)(id))filterBlock {
    NSMutableSet *newSet = [NSMutableSet set];
    for (id obj in self) {
        if (filterBlock && filterBlock(obj)) {
            [newSet addObject:obj];
        }
    }
    return [NSSet setWithSet:newSet];
}


@end
