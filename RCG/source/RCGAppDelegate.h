//
//  RCGAppDelegate.h
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioStreamer.h"

// fb stuff
typedef void (^SuccessBlock)();
extern NSString *const FBTestSessionStateChangedNotification;

@class WatchSeriesTableViewController;

@interface RCGAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIWindow *window;
    WatchSeriesTableViewController *viewController;
	BOOL uiIsVisible;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WatchSeriesTableViewController *viewController;
@property (nonatomic) BOOL uiIsVisible;
@property (nonatomic, retain) AudioStreamer *audioStreamer;
@property (nonatomic, retain) NSIndexPath *streamPath;


@property (nonatomic) int episodeNumber;
@property (nonatomic) BOOL isPlaying;

@property (nonatomic, strong) NSMutableDictionary *podcastDictionary;
@property (nonatomic ,strong) NSArray *blogArray;
@property (nonatomic, strong) NSString *seriesName;
@property (nonatomic, strong) NSString *podcastName;
@property (nonatomic) int seriesNumber;

@property (nonatomic) BOOL fullScreenIsPlaying;
@property (nonatomic, assign) BOOL isInternetConnectionValid;

@property (strong, nonatomic) UITabBarController *tabBarController;

// fb stuff
//@property (strong, nonatomic) UIWindow *window;
//!!!!!!!!!!chek!!!!!!!
@property (strong, nonatomic) WatchSeriesTableViewController *mainViewController;

- (void)openSessionWithSuccessBlock:(SuccessBlock)successBlock;

@end
