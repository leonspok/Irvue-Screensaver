//
//  NSDictionary+NSURL.h
//  tentracks-ios
//
//  Created by Игорь Савельев on 20/03/14.
//  Copyright (c) 2014 Music Sense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSURL)

+ (instancetype)dictionaryWithURL:(NSURL *)url;
- (NSURL *)urlWithBase:(NSString *)base;

@end
