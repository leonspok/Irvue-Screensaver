//
//  NSDictionary+NSURL.m
//  tentracks-ios
//
//  Created by Игорь Савельев on 20/03/14.
//  Copyright (c) 2014 Music Sense. All rights reserved.
//

#import "NSDictionary+NSURL.h"

@implementation NSDictionary (NSURL)

+ (NSDictionary *)dictionaryWithURL:(NSURL *)URL {
    NSString *queryString = [URL query];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters) {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [[parts objectAtIndex:0] stringByRemovingPercentEncoding];
        if ([parts count] > 1) {
            id value = [[parts objectAtIndex:1] stringByRemovingPercentEncoding];
            if (key) {
                [result setObject:value forKey:key];
            }
        }
    }
    return result;
}

- (NSURL *)urlWithBase:(NSString *)base {
    NSMutableString *urlString = [NSMutableString stringWithString:base];
    [urlString appendString:@"?"];
    BOOL first = YES;
    for (NSString *key in self.allKeys) {
        if (!first) {
            [urlString appendString:@"&"];
        }
        [urlString appendFormat:@"%@=%@", key, [[self objectForKey:key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        first = NO;
    }
    return [NSURL URLWithString:urlString];
}

@end
