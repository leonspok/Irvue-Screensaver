//
//  TTOfflineChecker.m
//  tentracks-ios
//
//  Created by Игорь Савельев on 15/01/14.
//  Copyright (c) 2014 10tracks. All rights reserved.
//

#import "TTOfflineChecker.h"
#import "Reachability.h"

@interface TTOfflineChecker()
@property (atomic, readwrite) BOOL offline;
@property (atomic, readwrite) TTNetworkConnection networkConnection;
@end

@implementation TTOfflineChecker {
    Reachability *reachibility;
}

+ (instancetype)defaultChecker {
    static TTOfflineChecker* _checker = nil;
    static dispatch_once_t oncePresicate;
    dispatch_once(&oncePresicate, ^{
        _checker = [[TTOfflineChecker alloc] init];
    });
    return _checker;
}

- (id)init {
    self = [super init];
    if (self) {
        _notificationCenter = [[NSNotificationCenter alloc] init];
		
		reachibility = [Reachability reachabilityForInternetConnection];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachibilityChanged) name:kReachabilityChangedNotification object:nil];
        [self setEnabled:YES];
    }
    return self;
}

- (void)reachibilityChanged {
	switch (reachibility.currentReachabilityStatus) {
		case NotReachable: {
			self.offline = YES;
			self.networkConnection = TTNetworkConnectionNone;
		}
			break;
		case ReachableViaWiFi: {
			self.networkConnection = TTNetworkConnectionWIFI;
			self.offline = NO;
		}
			break;
		case ReachableViaWWAN: {
			self.networkConnection = TTNetworkConnectionCellular;
			self.offline = NO;
		}
			break;
	}
	[self.notificationCenter postNotificationName:kOfflineStatusChangedNotification object:nil];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled) {
        [reachibility startNotifier];
    } else {
        [reachibility stopNotifier];
    }
}

@end
