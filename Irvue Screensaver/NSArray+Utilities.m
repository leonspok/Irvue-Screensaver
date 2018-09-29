//
//  NSArray+Utilities.m
//  Music Sense
//
//  Created by Игорь Савельев on 01/10/15.
//  Copyright © 2015 10tracks. All rights reserved.
//

#import "NSArray+Utilities.h"

@implementation NSArray (Utilities)

- (NSArray *)mapWithBlock:(id (^)(id))mapBlock {
    NSMutableArray *newArray = [NSMutableArray array];
    for (id obj in self) {
        id newObj;
        if (mapBlock) {
            newObj = mapBlock(obj);
        }
        if (newObj) {
            [newArray addObject:newObj];
        }
    }
    return [NSArray arrayWithArray:newArray];
}

- (NSArray *)filterWithBlock:(BOOL (^)(id))filterBlock {
    NSMutableArray *newArray = [NSMutableArray array];
    for (id obj in self) {
        if (filterBlock && filterBlock(obj)) {
            [newArray addObject:obj];
        }
    }
    return [NSArray arrayWithArray:newArray];
}

@end
