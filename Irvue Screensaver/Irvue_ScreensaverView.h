//
//  Irvue_ScreensaverView.h
//  Irvue Screensaver
//
//  Created by Игорь Савельев on 30/11/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

typedef enum {
	PhotosSourceFeatured	= 0,
	PhotosSourceCollection	= 1,
	PhotosSourceUser		= 2,
	PhotosSourceSearch		= 3
} PhotosSource;

@interface Irvue_ScreensaverView : ScreenSaverView

@property (nonatomic, strong) ScreenSaverDefaults *defaults;
@property (nonatomic) NSTimeInterval updateInterval;
@property (nonatomic) PhotosSource source;

@end
