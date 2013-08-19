//
//  ViewPodcastTableViewController.h
//  RCG
//
//  Created by Daniel Ho on 7/26/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewPodcastTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic) BOOL isCurrentPodcast;
@property (nonatomic, strong) NSString *podcastName;
@property (nonatomic) int episodeNumber;
@property (nonatomic, strong) NSString *seriesName;
@property (nonatomic) int seriesNumber;

@end
