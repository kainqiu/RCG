//
//  PodcastUrl.h
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PodcastUrl : NSObject

- (NSArray *) getEpisodeList:(NSString *)seriesName;
- (NSString *) getURLForSeries:(NSString *)seriesName episodeNumber:(int)number;
- (NSArray *) getSeriesList;
- (NSString *) getDescription:(NSString *)seriesName;
@end
