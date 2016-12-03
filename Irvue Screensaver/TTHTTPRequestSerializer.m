//
//  TTHTTPRequestSerializer.m
//  Music Sense
//
//  Created by Игорь Савельев on 24/06/16.
//  Copyright © 2016 10tracks. All rights reserved.
//

#import "TTHTTPRequestSerializer.h"
#import "NSCharacterSet+QueryParams.h"

@implementation TTHTTPRequestSerializer

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method url:(NSURL *)url params:(NSDictionary<NSString *, id> *)params {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:[method uppercaseString]];
    if (params.count > 0) {
        NSMutableString *queryString = [NSMutableString string];
        NSUInteger i = 0;
        for (NSString *key in params.allKeys) {
            NSString *valueString = nil;
            id value = [params objectForKey:key];
            if ([value isKindOfClass:NSString.class]) {
                valueString = value;
            } else if ([value isKindOfClass:NSNumber.class]) {
                NSNumber *number = value;
                if (strcmp([number objCType], @encode(BOOL)) == 0) {
                    valueString = [number boolValue]? @"true" : @"false";
                } else {
                    valueString = [number stringValue];
                }
            } else {
                valueString = [value description];
            }
            
            [queryString appendFormat:@"%@=%@", [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], [valueString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryParameterValueAllowedCharacterSet]]];
            if (i < params.count-1) {
                [queryString appendString:@"&"];
            }
            i++;
        }
        
        if ([[method uppercaseString] isEqualToString:@"GET"]) {
            request.URL = [NSURL URLWithString:[[request.URL absoluteString] stringByAppendingFormat:request.URL.query ? @"&%@" : @"?%@", queryString]];
        } else {
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return request;
}

@end
