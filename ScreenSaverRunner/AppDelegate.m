//
//  AppDelegate.m
//  ScreenSaverRunner
//
//  Created by Игорь Савельев on 30/11/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import "AppDelegate.h"
#import "Irvue_ScreensaverView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) Irvue_ScreensaverView *screenSaver;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.screenSaver = [[Irvue_ScreensaverView alloc] initWithFrame:self.window.contentView.bounds isPreview:YES];
	[self.screenSaver setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
//	[self.screenSaver setSource:PhotosSourceSearch];
//	[self.screenSaver.defaults setObject:@"city" forKey:@"search_query"];
//	[self.screenSaver.defaults synchronize];
//	[self.screenSaver setUpdateInterval:5.0f];
	[self.window.contentView addSubview:self.screenSaver];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
