//
//  WatchSeriesTableViewController.h
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayObj.h"
#import <MessageUI/MFMailComposeViewController.h>

@class AudioStreamer;

@interface WatchSeriesTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
{
	IBOutlet UITextField *downloadSourceField;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
	NSString *currentImageName;
    NSIndexPath *streamPath;
    BOOL isStreaming;
    BOOL sliderUsed;
}
@property (nonatomic, strong) NSString *seriesName;
@property (nonatomic, strong) NSArray *episodeList;
@property (nonatomic, strong) NSString *description;

@property (nonatomic, strong) NSArray *seriesInfo;
@property (nonatomic) int seriesNumber;

//- (IBAction)buttonPressed:(id)sender;
//- (IBAction)overlayButtonPressed:(id)sender;
//- (void)spinButton;
//- (void)updateProgress;
//- (IBAction)sliderMoved:(UISlider *)aSlider;

@end
