//
//  PlayPodcastCell.h
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayPodcastCell : UITableViewCell
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UISlider *slider;
@end
