//
//  TTHTTPRequestSerializer.h
//  Music Sense
//
//  Created by Игорь Савельев on 24/06/16.
//  Copyright © 2016 10tracks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTHTTPRequestSerializer : NSObject

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method url:(NSURL *)url params:(NSDictionary<NSString *, id> *)params;

@end
