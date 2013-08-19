//
//  PodcastURLViewController.h
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PodcastURLViewController : UIViewController

- (void) getURLForSeries:(NSString *)seriesName episodeNumber: (NSNumber *) number;

@end
